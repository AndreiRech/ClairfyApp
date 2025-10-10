//
//  AnalysisViewModel.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import Foundation

@Observable
class AnalysisViewModel: AnalysisViewModelProtocol {
    private let repository: AnalysisRepositoryProtocol
    
    var consultation: Consultation
    var isLoading: Bool = false
    var selectedSegment: Int = 0
    var errorMessage: String? = nil
    var showRegenerateConfirmation: Bool = false
    var showErrorAlert: Bool = false
    
    init(consultation: Consultation, repository: AnalysisRepositoryProtocol) {
        self.consultation = consultation
        self.repository = repository
    }
    
    @MainActor
    func generateAnalysis() async {
        guard let audioPathString = consultation.audio?.audioPath else {
            errorMessage = "Áudio não encontrado para esta consulta."
            return
        }
        
        let audioURL = URL(fileURLWithPath: audioPathString)
        
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            errorMessage = "Arquivo de áudio não encontrado no dispositivo."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let transcriptionText = try await repository.transcribe(audioFileURL: audioURL, model: "whisper-1")
            
            async let doctorAnalysisTask = repository.analyze(
                text: transcriptionText,
                promptType: "health",
                category: "doctor",
                model: "gpt-4o-mini",
                temperature: 0.2,
                maxOutputTokens: 1600
            )
            
            async let patientAnalysisTask = repository.analyze(
                text: transcriptionText,
                promptType: "health",
                category: "patient",
                model: "gpt-4o-mini",
                temperature: 0.2,
                maxOutputTokens: 1600
            )
            
            let (doctorAnalysis, patientAnalysis) = await (
                try doctorAnalysisTask,
                try patientAnalysisTask
            )
            
            let (summary, keyWords) = try parseDoctorAnalysis(doctorAnalysis)
            let (didactic, actionPoints) = try parsePatientAnalysis(patientAnalysis)
            
            let transcription = Transcription(
                transcription: nil,
                summary: summary,
                didactic: didactic,
                keyWords: keyWords,
                actionPoints: actionPoints
            )
            
            try repository.updateConsultationTranscription(consultation, transcription: transcription)
            
            isLoading = false
        } catch let error as AIServiceError {
            isLoading = false
            errorMessage = error.errorDescription ?? "Erro ao gerar análise."
        } catch let error as URLError where error.code == .timedOut {
            isLoading = false
            errorMessage = "A requisição demorou muito. Tente novamente ou use um áudio mais curto."
        } catch {
            isLoading = false
            errorMessage = "Erro desconhecido: \(error.localizedDescription)"
        }
    }
    
    private func parseDoctorAnalysis(_ text: String) throws -> (summary: String, keywords: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return (text, "")
        }
        
        let summary = json["summary"] as? String ?? ""
        let keyWordsArray = json["keyWords"] as? [String] ?? []
        let keywords = keyWordsArray.joined(separator: ", ")
                
        return (summary, keywords)
    }
    
    private func parsePatientAnalysis(_ text: String) throws -> (didactic: String, actionPoints: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return (text, "")
        }
        
        let didactic = json["didctarized"] as? String ?? ""
        let actionPointsArray = json["actionPoints"] as? [String] ?? []
        let actionPoints = actionPointsArray.joined(separator: "\n\n")
                
        return (didactic, actionPoints)
    }
}
