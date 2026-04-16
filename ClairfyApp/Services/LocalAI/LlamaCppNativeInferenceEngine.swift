//
//  LlamaCppNativeInferenceEngine.swift
//  ClairfyApp
//
//  Áudio → PCM (AVFoundation) → pipeline Gemma multimodal (requer mtmd + mmproj no disco).
//

import Foundation

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
        guard let desc = LocalModelCatalog.descriptor(for: model), let mm = desc.mmproj else {
            throw LocalInferenceError.mmprojMissing(model)
        }
        let mmprojURL = LocalModelStorage.mmprojURL(storedFileName: mm.storedFileName)
        guard FileManager.default.fileExists(atPath: mmprojURL.path) else {
            throw LocalInferenceError.mmprojMissing(model)
        }
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            throw LocalInferenceError.audioFileUnavailable
        }

        let pcm = try AudioPCMExtractor.floatPCMMono(url: audioURL, targetSampleRate: 16_000)

        return try await Task.detached(priority: .userInitiated) {
            try LlamaCppRunner.summarizeFromAudioPCM(
                model: model,
                modelWeightsPath: weights.path,
                mmprojPath: mmprojURL.path,
                pcmMonoFloat32: pcm,
                sampleRate: 16_000,
                localeIdentifier: localeIdentifier
            )
        }.value
    }
}
