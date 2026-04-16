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
    case audioFileUnavailable

    var errorDescription: String? {
        switch self {
        case .nativeEngineNotLinked:
            return "Motor de inferência nativo ainda não ligado (veja docs/poc-gemma-local.md). Esta build usa resposta simulada ou falha explícita."
        case .modelWeightsMissing(let id):
            return "Pesos não encontrados para \(id.displayName). Descarregue o modelo primeiro."
        case .audioFileUnavailable:
            return "Não foi encontrado ficheiro de áudio para teste."
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
