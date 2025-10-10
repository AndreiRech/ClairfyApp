import Foundation

public final class AIService: AIServiceProtocol {
    private let session: URLSession
    private var functionURL: URL { SupabaseManager.shared.edgeFunctionURL }

    public init(session: URLSession = .shared) {
        // Cria uma session com timeout maior para análises longas
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120  // 2 minutos por requisição
        config.timeoutIntervalForResource = 300 // 5 minutos total
        self.session = URLSession(configuration: config)
    }

    // MARK: - Public API

    public func transcribe(audioFileURL: URL, model: String = "whisper-1") async throws -> String {
        print("🎙️ Starting transcription for file: \(audioFileURL.lastPathComponent)")
        
        var request = URLRequest(url: functionURL)
        request.httpMethod = "POST"

        // Primeiro define os headers de autenticação
        setAuthHeaders(on: &request)
        
        // Depois define o Content-Type (multipart)
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpBody = try createTranscribeBody(boundary: boundary, fileURL: audioFileURL, model: model)
        
        print("📤 Sending request to: \(functionURL.absoluteString)")

        let (data, response) = try await session.data(for: request)
        
        print("📥 Response received for transcribe:")
        if let httpResponse = response as? HTTPURLResponse {
            print("   Status: \(httpResponse.statusCode)")
        }
        if let responseString = String(data: data, encoding: .utf8) {
            print("   Body: \(responseString.prefix(500))")
        }
        
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
        // Sempre envia a anon key do Supabase
        let anonKey = SupabaseManager.shared.anonKey
        print("🔑 Setting anon key: \(anonKey.prefix(20))...")
        
        // Envia o header apikey (sempre necessário)
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        
        // Se não estiver em modo debug, envia também o Authorization
        if !SupabaseManager.shared.skipAuthorizationHeader {
            // Supabase Edge Functions aceitam tanto Authorization quanto apikey
            request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
            
            // Se houver token de usuário autenticado, sobrescreve o Authorization
            if let userToken = SupabaseManager.shared.getAccessToken(), !userToken.isEmpty {
                print("🔑 Overriding Authorization with user token")
                request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
            }
        } else {
            print("⚠️ Skipping Authorization header (debug mode)")
        }
        
        // Envia device ID para identificação do dispositivo
        let deviceId = SupabaseManager.shared.getOrCreateDeviceId()
        print("📱 Setting x-device-id: \(deviceId)")
        request.setValue(deviceId, forHTTPHeaderField: "x-device-id")
        
        // Opcional (apenas se você configurar para DEV no server):
        if let appSecret = SupabaseManager.shared.appSecret, !appSecret.isEmpty {
            print("🔐 Setting x-app-secret")
            request.setValue(appSecret, forHTTPHeaderField: "x-app-secret")
        }
        
        // Debug: mostra todos os headers
        print("📋 All headers being sent:")
        request.allHTTPHeaderFields?.forEach { key, value in
            print("   \(key): \(value.prefix(50))")
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
            
            // Detectar erro de quota exceeded
            if http.statusCode == 402 || body.lowercased().contains("quota") {
                print("❌ Quota exceeded detected")
                throw AIServiceError.quotaExceeded
            }
            
            // Detectar timeout
            if http.statusCode == 504 || http.statusCode == 408 {
                print("❌ Timeout detected")
                throw AIServiceError.timeout
            }
            
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
