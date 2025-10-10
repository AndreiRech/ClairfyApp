import Foundation

public enum AIServiceError: Error, LocalizedError {
    case missingEdgeFunctionURL
    case missingDeviceId
    case serverError(status: Int, body: String)
    case invalidResponse
    case decodingError(Error)
    case encodingError(Error)
    case quotaExceeded
    case timeout
    case other(Error)

    public var errorDescription: String? {
        switch self {
        case .missingEdgeFunctionURL: return "Edge Function URL não configurada."
        case .missingDeviceId:        return "Device ID indisponível."
        case .quotaExceeded:          return "Limite de requisições atingido. Entre em contato com o suporte ou aguarde para tentar novamente."
        case .timeout:                return "A requisição demorou muito. Tente novamente ou use um áudio mais curto."
        case .serverError(let s, let b): return "Servidor retornou \(s): \(b)"
        case .invalidResponse:        return "Resposta inválida do servidor."
        case .decodingError(let e):   return "Falha ao decodificar: \(e.localizedDescription)"
        case .encodingError(let e):   return "Falha ao codificar: \(e.localizedDescription)"
        case .other(let e):           return e.localizedDescription
        }
    }
}

public protocol AIServiceProtocol {
    /// Envia um arquivo de áudio para transcrição (Edge Function -> OpenAI Whisper)
    func transcribe(audioFileURL: URL, model: String) async throws -> String

    /// Faz análise/resumo via Responses API usando prompts do Supabase (por tipo e categoria)
    func analyze(
        text: String,
        promptType: String,
        category: String?,
        model: String,
        temperature: Double,
        maxOutputTokens: Int?
    ) async throws -> String
}
