//
//  LocalModelBundleID.swift
//  ClairfyApp
//

import Foundation

/// Identificadores estáveis para os dois pesos edge da POC (Gemma 4).
enum LocalModelBundleID: String, CaseIterable, Identifiable, Codable, Sendable {
    case e2b
    case e4b

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .e2b: return "Gemma 4 E2B (edge)"
        case .e4b: return "Gemma 4 E4B (edge)"
        }
    }

    /// Nome do ficheiro no disco (Application Support / ClairfyModels).
    var storedFileName: String {
        switch self {
        case .e2b: return "google_gemma-4-E2B-it-Q4_K_M.gguf"
        case .e4b: return "google_gemma-4-E4B-it-Q4_K_M.gguf"
        }
    }
}
