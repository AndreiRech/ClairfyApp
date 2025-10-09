import Foundation

public final class AIService: AIServiceProtocol {
    private let session: URLSession
    private var functionURL: URL { SupabaseManager.shared.edgeFunctionURL }

    public init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Public API

    public func transcribe(audioFileURL: URL, model: String = "whisper-1") async throws -> String {
        var request = URLRequest(url: functionURL)
        request.httpMethod = "POST"

        // multipart
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        setAuthHeaders(on: &request) // Authorization (futuro) ou x-device-id (atual)

        request.httpBody = try createTranscribeBody(boundary: boundary, fileURL: audioFileURL, model: model)

        let (data, response) = try await session.data(for: request)
        try handleHTTPErrorIfNeeded(response: response, data: data)

        // Whisper costuma retornar { "text": "..." } — mas tratamos fallback texto
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let text = json["text"] as? String {
            return text
        }
        if let plain = String(data: data, encoding: .utf8), !plain.isEmpty {
            return plain
        }
        throw AIServiceError.invalidResponse
    }

    public func analyze(
        text: String,
        promptType: String,
        category: String? = nil,
        model: String = "gpt-4o-mini",
        temperature: Double = 0.1,
        maxOutputTokens: Int? = 800
    ) async throws -> String {
        var request = URLRequest(url: functionURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        setAuthHeaders(on: &request)

        var payload: [String: Any] = [
            "action": "chat",
            "prompt_type": promptType,
            "user_text": text,
            "model": model,
            "temperature": temperature
        ]
        if let category { payload["category"] = category }
        if let maxOutputTokens { payload["max_tokens"] = maxOutputTokens } // edge aceita e converte para max_output_tokens

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            throw AIServiceError.encodingError(error)
        }

        let (data, response) = try await session.data(for: request)
        try handleHTTPErrorIfNeeded(response: response, data: data)

        // Responses API pode ter vários formatos. Extraímos texto de forma robusta.
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let extracted = extractText(from: json) {
            return extracted
        }

        // fallback: retorna JSON como string (útil para debug)
        if let debug = String(data: data, encoding: .utf8) { return debug }
        throw AIServiceError.invalidResponse
    }

    // MARK: - Private helpers

    private func setAuthHeaders(on request: inout URLRequest) {
        // Fase atual: sem autenticação de usuário -> usa x-device-id
        if let token = SupabaseManager.shared.getAccessToken(), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            let deviceId = SupabaseManager.shared.getOrCreateDeviceId()
            request.setValue(deviceId, forHTTPHeaderField: "x-device-id")
        }
        // Opcional (apenas se você configurar para DEV no server):
        if let appSecret = SupabaseManager.shared.appSecret, !appSecret.isEmpty {
            request.setValue(appSecret, forHTTPHeaderField: "x-app-secret")
        }
    }

    private func createTranscribeBody(boundary: String, fileURL: URL, model: String) throws -> Data {
        var data = Data()
        let lb = "\r\n"

        func append(_ s: String) {
            data.append(Data(s.utf8))
        }

        // action
        append("--\(boundary)\(lb)")
        append("Content-Disposition: form-data; name=\"action\"\(lb)\(lb)")
        append("transcribe\(lb)")

        // model
        append("--\(boundary)\(lb)")
        append("Content-Disposition: form-data; name=\"model\"\(lb)\(lb)")
        append("\(model)\(lb)")

        // file
        let filename = fileURL.lastPathComponent
        let mime = mimeType(for: filename)

        append("--\(boundary)\(lb)")
        append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\(lb)")
        append("Content-Type: \(mime)\(lb)\(lb)")
        let fileData = try Data(contentsOf: fileURL)
        data.append(fileData)
        append(lb)

        // end
        append("--\(boundary)--\(lb)")
        return data
    }

    private func mimeType(for filename: String) -> String {
        switch (filename as NSString).pathExtension.lowercased() {
        case "m4a": return "audio/m4a"
        case "mp3": return "audio/mpeg"
        case "wav": return "audio/wav"
        case "caf": return "audio/x-caf"
        default:    return "application/octet-stream"
        }
    }

    private func handleHTTPErrorIfNeeded(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "<non-utf8 body>"
            throw AIServiceError.serverError(status: http.statusCode, body: body)
        }
    }

    /// Tenta extrair o texto útil do JSON retornado pela Responses API / Chat (várias formas)
    private func extractText(from json: [String: Any]) -> String? {
        // 1) Novo Responses API – 'output' array com 'content' contendo 'text'/'output_text'
        if let output = json["output"] as? [[String: Any]] {
            var acc = ""
            for part in output {
                if let contentArr = part["content"] as? [[String: Any]] {
                    for c in contentArr {
                        if let t = c["text"] as? String { acc += t }
                        else if let t = c["output_text"] as? String { acc += t }
                        else if let t = c["content"] as? String { acc += t }
                    }
                } else if let t = part["text"] as? String {
                    acc += t
                }
            }
            if !acc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return acc.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        // 2) Algumas variantes retornam 'responses' array
        if let responses = json["responses"] as? [[String: Any]] {
            for r in responses {
                if let out = r["output"] as? [[String: Any]] {
                    var acc = ""
                    for part in out {
                        if let contentArr = part["content"] as? [[String: Any]] {
                            for c in contentArr {
                                if let t = c["text"] as? String { acc += t }
                                else if let t = c["output_text"] as? String { acc += t }
                            }
                        } else if let t = part["text"] as? String {
                            acc += t
                        }
                    }
                    if !acc.isEmpty { return acc.trimmingCharacters(in: .whitespacesAndNewlines) }
                }
                if let t = r["text"] as? String, !t.isEmpty { return t }
                if let c = r["content"] as? String, !c.isEmpty { return c }
            }
        }

        // 3) Formato antigo (chat completions): choices[0].message.content
        if let choices = json["choices"] as? [[String: Any]],
           let first = choices.first,
           let message = first["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        // 4) fallbacks
        if let t = json["output_text"] as? String { return t }
        if let t = json["text"] as? String { return t }

        return nil
    }
}
