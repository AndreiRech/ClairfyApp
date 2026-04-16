//
//  LocalModelCatalog.swift
//  ClairfyApp
//
//  URLs: repositórios comunitários GGUF (bartowski). Modelos Google podem exigir aceite de licença no Hugging Face.
//

import Foundation

enum LocalModelCatalog: Sendable {
    static let shared: [LocalModelDescriptor] = [
        LocalModelDescriptor(
            id: .e2b,
            displayName: LocalModelBundleID.e2b.displayName,
            downloadURL: URL(string: "https://huggingface.co/bartowski/google_gemma-4-E2B-it-GGUF/resolve/main/google_gemma-4-E2B-it-Q4_K_M.gguf")!,
            expectedArtifactSizeBytes: 3_462_677_760
        ),
        LocalModelDescriptor(
            id: .e4b,
            displayName: LocalModelBundleID.e4b.displayName,
            downloadURL: URL(string: "https://huggingface.co/bartowski/google_gemma-4-E4B-it-GGUF/resolve/main/google_gemma-4-E4B-it-Q4_K_M.gguf")!,
            expectedArtifactSizeBytes: 5_405_167_904
        )
    ]

    static func descriptor(for id: LocalModelBundleID) -> LocalModelDescriptor? {
        shared.first { $0.id == id }
    }
}
