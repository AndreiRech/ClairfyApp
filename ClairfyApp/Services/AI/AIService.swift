import Foundation

final class AIService: AIServiceProtocol {
    private let session: URLSession
    private var functionURL: URL { SupabaseService.shared.edgeFunctionURL }

    init(session: URLSession = .shared) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }

    func transcribe(audioFileURL: URL, model: String = "whisper-1") async throws -> String {
        var request = URLRequest(url: functionURL)
        request.httpMethod = "POST"

        setAuthHeaders(on: &request)
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpBody = try createTranscribeBody(boundary: boundary, fileURL: audioFileURL, model: model)
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("   Status: \(httpResponse.statusCode)")
        }
        if let responseString = String(data: data, encoding: .utf8) {
            print("   Body: \(responseString.prefix(500))")
        }
        
        try handleHTTPErrorIfNeeded(response: response, data: data)

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let text = json["text"] as? String {
            return text
        }
        if let plain = String(data: data, encoding: .utf8), !plain.isEmpty {
            return plain
        }
        throw AIServiceError.invalidResponse
    }

    func analyze(
        text: String,
        promptType: String,
        category: String? = nil,
        model: String = "gpt-5-mini",
        temperature: Double = 0.2,
        maxOutputTokens: Int? = 2000
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
        if let maxOutputTokens { payload["max_tokens"] = maxOutputTokens }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            throw AIServiceError.encodingError(error)
        }

        let (data, response) = try await session.data(for: request)
        try handleHTTPErrorIfNeeded(response: response, data: data)

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let extracted = extractText(from: json) {
            return extracted
        }

        if let debug = String(data: data, encoding: .utf8) { return debug }
        throw AIServiceError.invalidResponse
    }

    private func setAuthHeaders(on request: inout URLRequest) {
        let anonKey = SupabaseService.shared.anonKey
        
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        
        if !SupabaseService.shared.skipAuthorizationHeader {
            request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
            
            if let userToken = SupabaseService.shared.getAccessToken(), !userToken.isEmpty {
                request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
            }
        } else {
            print("Skipping Authorization header (debug mode)")
        }
        
        let deviceId = SupabaseService.shared.getOrCreateDeviceId()
        request.setValue(deviceId, forHTTPHeaderField: "x-device-id")
        
        if let appSecret = SupabaseService.shared.appSecret, !appSecret.isEmpty {
            request.setValue(appSecret, forHTTPHeaderField: "x-app-secret")
        }
    }

    private func createTranscribeBody(boundary: String, fileURL: URL, model: String) throws -> Data {
        var data = Data()
        let lb = "\r\n"

        func append(_ s: String) {
            data.append(Data(s.utf8))
        }

        append("--\(boundary)\(lb)")
        append("Content-Disposition: form-data; name=\"action\"\(lb)\(lb)")
        append("transcribe\(lb)")

        append("--\(boundary)\(lb)")
        append("Content-Disposition: form-data; name=\"model\"\(lb)\(lb)")
        append("\(model)\(lb)")

        let filename = fileURL.lastPathComponent
        let mime = mimeType(for: filename)

        append("--\(boundary)\(lb)")
        append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\(lb)")
        append("Content-Type: \(mime)\(lb)\(lb)")
        let fileData = try Data(contentsOf: fileURL)
        data.append(fileData)
        append(lb)

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
            
            if http.statusCode == 402 || body.lowercased().contains("quota") {
                print("Quota exceeded detected")
                throw AIServiceError.quotaExceeded
            }
            
            if http.statusCode == 504 || http.statusCode == 408 {
                print("Timeout detected")
                throw AIServiceError.timeout
            }
            
            throw AIServiceError.serverError(status: http.statusCode, body: body)
        }
    }

    private func extractText(from json: [String: Any]) -> String? {
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

        if let choices = json["choices"] as? [[String: Any]],
           let first = choices.first,
           let message = first["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let t = json["output_text"] as? String { return t }
        if let t = json["text"] as? String { return t }

        return nil
    }
}
