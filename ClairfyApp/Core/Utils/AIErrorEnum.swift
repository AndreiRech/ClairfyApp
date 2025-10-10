//
//  AIErrorEnum.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 10/10/25.
//

import Foundation

enum AIServiceError: Error, LocalizedError {
    case missingEdgeFunctionURL
    case missingDeviceId
    case serverError(status: Int, body: String)
    case invalidResponse
    case decodingError(Error)
    case encodingError(Error)
    case quotaExceeded
    case timeout
    case other(Error)

    var errorDescription: String? {
        switch self {
        case .missingEdgeFunctionURL: return "Edge Function URL não configurada."
        case .missingDeviceId:        return "Device ID indisponível."
        case .quotaExceeded:          return "Limite de requisições atingido. Entre em contato com o suporte ou aguarde para tentar novamente."
        case .timeout:                return "A requisição demorou muito. Tente novamente ou use um áudio mais curto."
        case .serverError(let s, let b): return "Servidor retornou \(s): \(b)"
        case .invalidResponse:        return "Resposta inválida do servidor."
        case .decodingError(let e):   return "Falha ao decodificar: \(e.localizedDescription)"
        case .encodingError(let e):   return "Falha ao codificar: \(e.localizedDescription)"
        case .other(let e):           return e.localizedDescription
        }
    }
}
