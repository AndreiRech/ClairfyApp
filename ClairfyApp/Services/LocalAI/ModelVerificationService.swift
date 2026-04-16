//
//  ModelVerificationService.swift
//  ClairfyApp
//

import Foundation

protocol ModelVerifying {
    func verifyArtifact(at url: URL, expectedSizeBytes: Int64) throws
}

enum ModelVerificationError: LocalizedError {
    case fileMissing
    case sizeMismatch(expected: Int64, actual: Int64)

    var errorDescription: String? {
        switch self {
        case .fileMissing:
            return "Ficheiro do modelo não encontrado."
        case .sizeMismatch(let expected, let actual):
            return "Tamanho incorreto (esperado \(expected) bytes, obtido \(actual) bytes). O download pode estar incompleto ou corrompido."
        }
    }
}

final class ModelVerificationService: ModelVerifying {
    func verifyArtifact(at url: URL, expectedSizeBytes: Int64) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ModelVerificationError.fileMissing
        }
        let values = try url.resourceValues(forKeys: [.fileSizeKey])
        guard let size = values.fileSize else {
            throw ModelVerificationError.fileMissing
        }
        let actual = Int64(size)
        guard actual == expectedSizeBytes else {
            throw ModelVerificationError.sizeMismatch(expected: expectedSizeBytes, actual: actual)
        }
    }
}
