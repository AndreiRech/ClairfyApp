//
//  ModelDownloadArtifact.swift
//  ClairfyApp
//

import Foundation

/// Parte do pacote de um modelo (pesos principais vs. mmproj multimodal).
enum ModelDownloadArtifact: String, Sendable {
    case weights
    case mmproj
}
