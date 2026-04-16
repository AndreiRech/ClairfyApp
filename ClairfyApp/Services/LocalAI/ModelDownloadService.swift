//
//  ModelDownloadService.swift
//  ClairfyApp
//

import Foundation

protocol ModelDownloadServing: AnyObject {
    func cancelDownload(for model: LocalModelBundleID)
    func startDownload(descriptor: LocalModelDescriptor, destinationURL: URL)
}

enum HuggingFaceDownloadError: LocalizedError {
    case httpStatus(Int)
    case receivedLFSPointerFile
    case invalidDownloadPayload

    var errorDescription: String? {
        switch self {
        case .httpStatus(let code):
            return "Servidor devolveu HTTP \(code). Se o modelo for gated, aceite a licença no Hugging Face e configure um token na app."
        case .receivedLFSPointerFile:
            return "Recebemos um ficheiro LFS pointer em vez do GGUF (falta token Hugging Face ou URL incorreta)."
        case .invalidDownloadPayload:
            return "Resposta de download inválida (HTML ou corpo vazio). Verifique a ligação e os termos do repositório."
        }
    }
}

/// Encaminha para o coordenador singleton (sessão background + notificações).
final class ModelDownloadService: ModelDownloadServing {
    func cancelDownload(for model: LocalModelBundleID) {
        ModelDownloadCoordinator.shared.cancelDownload(for: model)
    }

    func startDownload(descriptor: LocalModelDescriptor, destinationURL: URL) {
        ModelDownloadCoordinator.shared.startDownload(descriptor: descriptor, destinationURL: destinationURL)
    }
}
