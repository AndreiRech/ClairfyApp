import Foundation

public protocol AIServiceProtocol {
    func transcribe(audioFileURL: URL, model: String) async throws -> String

    func analyze(
        text: String,
        promptType: String,
        category: String?,
        model: String,
        temperature: Double,
        maxOutputTokens: Int?
    ) async throws -> String
}
