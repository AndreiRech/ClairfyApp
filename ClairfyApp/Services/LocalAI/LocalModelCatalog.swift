//
//  LocalModelCatalog.swift
//  ClairfyApp
//
//  URLs: repositórios comunitários GGUF (bartowski). Modelos Google podem exigir aceite de licença no Hugging Face.
//

import Foundation

enum LocalModelCatalog: Sendable {
    /// Resolve URL com `download=1` (recomendado pela Hugging Face para binários LFS).
    private static func hfDownloadURL(repoPath: String, fileName: String) -> URL {
        var c = URLComponents(string: "https://huggingface.co/\(repoPath)/resolve/main/\(fileName)")!
        c.queryItems = [URLQueryItem(name: "download", value: "1")]
        return c.url!
    }

    static let shared: [LocalModelDescriptor] = [
        LocalModelDescriptor(
            id: .e2b,
            displayName: LocalModelBundleID.e2b.displayName,
            downloadURL: hfDownloadURL(
                repoPath: "bartowski/google_gemma-4-E2B-it-GGUF",
                fileName: "google_gemma-4-E2B-it-Q4_K_M.gguf"
            ),
            expectedArtifactSizeBytes: 3_462_677_760
        ),
        LocalModelDescriptor(
            id: .e4b,
            displayName: LocalModelBundleID.e4b.displayName,
            downloadURL: hfDownloadURL(
                repoPath: "bartowski/google_gemma-4-E4B-it-GGUF",
                fileName: "google_gemma-4-E4B-it-Q4_K_M.gguf"
            ),
            expectedArtifactSizeBytes: 5_405_167_904
        )
    ]

    static func descriptor(for id: LocalModelBundleID) -> LocalModelDescriptor? {
        shared.first { $0.id == id }
    }
}
