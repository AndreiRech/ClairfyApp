//
//  AnalysisRepositoryProtocol.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import Foundation

protocol AnalysisRepositoryProtocol {
    func updateConsultationTranscription(_ consultation: Consultation, transcription: Transcription) throws
    
    func transcribe(audioFileURL: URL, model: String) async throws -> String
    func analyze(
        text: String,
        promptType: String,
        category: String?,
        model: String,
        temperature: Double,
        maxOutputTokens: Int?
    ) async throws -> String
}
