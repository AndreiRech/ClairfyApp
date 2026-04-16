//
//  MmprojArtifact.swift
//  ClairfyApp
//
//  Metadados do ficheiro **mmproj** (projeção multimodal) necessário para áudio no Gemma 4 via llama.cpp / mtmd.
//

import Foundation

struct MmprojArtifact: Sendable {
    let downloadURL: URL
    let expectedSizeBytes: Int64
    /// Nome do ficheiro em `LocalModelStorage.rootDirectory`.
    let storedFileName: String
}
