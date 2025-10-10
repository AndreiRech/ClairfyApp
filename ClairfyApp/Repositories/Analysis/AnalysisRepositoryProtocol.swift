//
//  AnalysisRepositoryProtocol.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import Foundation

protocol AnalysisRepositoryProtocol {
    func updateConsultationTranscription(_ consultation: Consultation, transcription: Transcription) throws
}
