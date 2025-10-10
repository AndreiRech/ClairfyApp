//
//  AnalysisRepository.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import Foundation

class AnalysisRepository: AnalysisRepositoryProtocol {
    private let consultationService: ConsultationServiceProtocol
    
    init(consultationService: ConsultationServiceProtocol) {
        self.consultationService = consultationService
    }
    
    func updateConsultationTranscription(_ consultation: Consultation, transcription: Transcription) throws {
        consultation.transcription = transcription
        try consultationService.updateConsultation(by: consultation.id, with: consultation)
    }
}
