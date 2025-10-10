//
//  AnalysisRepository.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import Foundation

class AnalysisRepository: AnalysisRepositoryProtocol {
    private let consultationService: ConsultationServiceProtocol
    private let aiService: AIServiceProtocol
    
    init(consultationService: ConsultationServiceProtocol, aiService: AIServiceProtocol) {
        self.consultationService = consultationService
        self.aiService = aiService
    }
    
    func updateConsultationTranscription(_ consultation: Consultation, transcription: Transcription) throws {
        consultation.transcription = transcription
        try consultationService.updateConsultation(by: consultation.id, with: consultation)
    }
    
    func transcribe(audioFileURL: URL, model: String) async throws -> String {
        try await aiService.transcribe(audioFileURL: audioFileURL, model: model)
    }
    
    func analyze(
        text: String,
        promptType: String,
        category: String?,
        model: String,
        temperature: Double,
        maxOutputTokens: Int?
    ) async throws -> String {
        try await aiService.analyze(text: text, promptType: promptType, category: category, model: model, temperature: temperature, maxOutputTokens: maxOutputTokens)
    }
}
