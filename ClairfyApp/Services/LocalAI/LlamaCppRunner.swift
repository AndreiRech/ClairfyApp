//
//  LlamaCppRunner.swift
//  ClairfyApp
//
//  Caminho para inferência **áudio → Gemma** via llama.cpp **mtmd** (`mtmd_init_from_file`).
//  O pacote SPM **LlamaSwift** (mattt) só inclui o binário `llama` base — **sem** libmtmd.
//  Este módulo valida PCM + ficheiros e falha com `LocalInferenceError.gemmaMultimodalInferenceNotLinkedInBuild`
//  até o projeto ligar um binário com mtmd.
//

import Foundation

enum LlamaCppRunner {
    /// Valida pré-requisitos e indica que falta a ligação **mtmd** (fora do LlamaSwift).
    static func summarizeFromAudioPCM(
        model: LocalModelBundleID,
        modelWeightsPath: String,
        mmprojPath: String,
        pcmMonoFloat32: [Float],
        sampleRate: Int,
        localeIdentifier: String
    ) throws -> LocalSummaryResult {
        _ = localeIdentifier
        guard !pcmMonoFloat32.isEmpty else {
            throw LocalInferenceError.audioDecodeFailed
        }
        guard FileManager.default.fileExists(atPath: modelWeightsPath) else {
            throw LocalInferenceError.modelWeightsMissing(model)
        }
        guard FileManager.default.fileExists(atPath: mmprojPath) else {
            throw LocalInferenceError.mmprojMissing(model)
        }
        guard sampleRate > 0 else {
            throw LocalInferenceError.audioDecodeFailed
        }
        // Quando libmtmd estiver ligada: mtmd_init_from_file(mmproj, …) + chunks MTMD_INPUT_CHUNK_TYPE_AUDIO.
        throw LocalInferenceError.gemmaMultimodalInferenceNotLinkedInBuild
    }
}
