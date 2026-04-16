//
//  LlamaCppNativeInferenceEngine.swift
//  ClairfyApp
//
//  Placeholder para o spike: carregar GGUF via llama.cpp (ou equivalente) e correr multimodal áudio+texto.
//  Quando integrado, definir useStubResponses = false e implementar summarize com o bridge C++/Swift.
//

import Foundation

/// Motor “real” ainda não ligado — falha de forma explícita para builds que desligam o stub.
final class LlamaCppNativeInferenceEngine: LocalInferenceEngine {
    let useStubResponses: Bool = false

    func summarize(
        model: LocalModelBundleID,
        audioURL: URL,
        localeIdentifier: String
    ) async throws -> LocalSummaryResult {
        _ = localeIdentifier
        let weights = LocalModelStorage.fileURL(for: model)
        guard FileManager.default.fileExists(atPath: weights.path) else {
            throw LocalInferenceError.modelWeightsMissing(model)
        }
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            throw LocalInferenceError.audioFileUnavailable
        }
        throw LocalInferenceError.nativeEngineNotLinked
    }
}
