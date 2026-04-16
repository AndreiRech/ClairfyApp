//
//  StubLocalInferenceEngine.swift
//  ClairfyApp
//
//  Respostas determinísticas para validar o fluxo da POC sem binário llama.cpp/MediaPipe.
//

import Foundation

final class StubLocalInferenceEngine: LocalInferenceEngine {
    let useStubResponses: Bool = true

    func summarize(
        model: LocalModelBundleID,
        audioURL: URL,
        localeIdentifier: String
    ) async throws -> LocalSummaryResult {
        _ = localeIdentifier
        let exists = FileManager.default.fileExists(atPath: audioURL.path)
        if !exists {
            throw LocalInferenceError.audioFileUnavailable
        }
        let modelTag = model == .e2b ? "E2B" : "E4B"
        return LocalSummaryResult(
            summary: "[POC \(modelTag)] Resumo simulado a partir do ficheiro \(audioURL.lastPathComponent). Locale=\(localeIdentifier).",
            actionPoints: "1. Revisar manualmente este texto (inferência ainda não nativa).\n2. Integrar llama.cpp ou MediaPipe conforme docs/poc-gemma-local.md.",
            rawNotes: "stub"
        )
    }
}
