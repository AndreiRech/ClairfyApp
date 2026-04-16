//
//  LocalModelDescriptor.swift
//  ClairfyApp
//

import Foundation

/// Metadados de um peso GGUF remoto (POC). Tamanhos alinhados ao LFS no Hugging Face (bartowski).
struct LocalModelDescriptor: Identifiable, Sendable {
    let id: LocalModelBundleID
    let displayName: String
    let downloadURL: URL
    /// Tamanho esperado em bytes do artefacto GGUF (validação pós-download).
    let expectedArtifactSizeBytes: Int64
    /// Projeção multimodal (áudio/imagem) — obrigatória para inferência com áudio directo no Gemma 4.
    let mmproj: MmprojArtifact?

    var storedFileName: String { id.storedFileName }
}
