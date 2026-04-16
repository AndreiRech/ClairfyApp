//
//  LocalInferenceEngine.swift
//  ClairfyApp
//

import Foundation

struct LocalSummaryResult: Sendable, Equatable {
    var summary: String
    var actionPoints: String
    /// Texto auxiliar (ex.: transcrição interna ou nota do motor).
    var rawNotes: String?
}

enum LocalInferenceError: LocalizedError {
    case nativeEngineNotLinked
    case modelWeightsMissing(LocalModelBundleID)
    case mmprojMissing(LocalModelBundleID)
    case audioFileUnavailable
    case audioDecodeFailed
    /// Áudio em PCM + mmproj prontos; falta **libmtmd** (não incluída no pacote LlamaSwift) para tokens multimodais.
    case gemmaMultimodalInferenceNotLinkedInBuild

    var errorDescription: String? {
        switch self {
        case .nativeEngineNotLinked:
            return "Motor de inferência nativo ainda não ligado (veja docs/poc-gemma-local.md). Esta build usa resposta simulada ou falha explícita."
        case .modelWeightsMissing(let id):
            return "Pesos não encontrados para \(id.displayName). Descarregue o modelo primeiro."
        case .mmprojMissing(let id):
            return "Falta o ficheiro mmproj multimodal para \(id.displayName). Descarregue o pacote completo (GGUF + mmproj)."
        case .audioFileUnavailable:
            return "Não foi encontrado ficheiro de áudio para teste."
        case .audioDecodeFailed:
            return "Não foi possível descodificar o áudio para PCM (formato ou ficheiro inválido)."
        case .gemmaMultimodalInferenceNotLinkedInBuild:
            return """
            O áudio foi convertido para PCM e os ficheiros GGUF + mmproj estão no disco; a inferência directa no Gemma 4 exige a biblioteca **mtmd** de llama.cpp (`mtmd_init_from_file`), que não faz parte do binário LlamaSwift actual. Veja `docs/gemma-audio-mtmd-ios.md`.
            """
        }
    }
}

/// Contrato para áudio local → resumo + pontos de ação (POC).
protocol LocalInferenceEngine: AnyObject {
    /// Quando `useStubResponses` é true, devolve texto fixo útil para validar UI sem llama.cpp/Core ML.
    var useStubResponses: Bool { get }

    func summarize(
        model: LocalModelBundleID,
        audioURL: URL,
        localeIdentifier: String
    ) async throws -> LocalSummaryResult
}
