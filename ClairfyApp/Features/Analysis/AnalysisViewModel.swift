//
//  AnalysisViewModel.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import Foundation

@Observable
class AnalysisViewModel: AnalysisViewModelProtocol {
    var consultation: Consultation
    var isLoading: Bool = false
    var selectedSegment: Int = 0
    var errorMessage: String? = nil
    
    private let aiService: AIServiceProtocol
    private let repository: AnalysisRepositoryProtocol
    
    init(consultation: Consultation, aiService: AIServiceProtocol, repository: AnalysisRepositoryProtocol) {
        self.consultation = consultation
        self.aiService = aiService
        self.repository = repository
    }
    
    @MainActor
    func generateAnalysis() async {
        // Verifica se tem áudio
        guard let audioPathString = consultation.audio?.audioPath else {
            errorMessage = "Áudio não encontrado para esta consulta."
            return
        }
        
        // Converte o caminho do áudio para URL
        let audioURL = URL(fileURLWithPath: audioPathString)
        
        // Verifica se o arquivo existe
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            errorMessage = "Arquivo de áudio não encontrado no dispositivo."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Passo 1: Transcrever o áudio
            let transcriptionText = try await aiService.transcribe(audioFileURL: audioURL, model: "whisper-1")
            
            // Passo 2: Gerar análises em paralelo (2 prompts: health/doctor e health/patient)
            async let doctorAnalysisTask = aiService.analyze(
                text: transcriptionText,
                promptType: "health",
                category: "doctor",
                model: "gpt-4o-mini",
                temperature: 0.2,
                maxOutputTokens: 1600
            )
            
            async let patientAnalysisTask = aiService.analyze(
                text: transcriptionText,
                promptType: "health",
                category: "patient",
                model: "gpt-4o-mini",
                temperature: 0.2,
                maxOutputTokens: 1600
            )
            
            // Aguarda as 2 análises
            let (doctorAnalysis, patientAnalysis) = try await (
                doctorAnalysisTask,
                patientAnalysisTask
            )
            
            // Parse das respostas JSON
            let (summary, keyWords) = try parseDoctorAnalysis(doctorAnalysis)
            let (didactic, actionPoints) = try parsePatientAnalysis(patientAnalysis)
            
            // Passo 3: Criar objeto Transcription (SEM salvar o texto da transcrição)
            let transcription = Transcription(
                transcription: nil,  // Não salvamos a transcrição
                summary: summary,
                didactic: didactic,
                keyWords: keyWords,
                actionPoints: actionPoints
            )
            
            // Passo 4: Salvar no SwiftData
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
    
    // MARK: - Parse Helper Functions
    
    private func parseDoctorAnalysis(_ text: String) throws -> (summary: String, keywords: String) {
        // Resposta esperada: {"summary": "...", "keyWords": ["...", "..."]}
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            // Fallback: se não for JSON, retorna texto completo
            print("⚠️ Doctor analysis não é JSON válido, usando texto completo")
            return (text, "")
        }
        
        let summary = json["summary"] as? String ?? ""
        let keyWordsArray = json["keyWords"] as? [String] ?? []
        let keywords = keyWordsArray.joined(separator: ", ")
        
        print("✅ Doctor analysis parsed: summary=\(summary.prefix(50))..., keywords=\(keywords)")
        
        return (summary, keywords)
    }
    
    private func parsePatientAnalysis(_ text: String) throws -> (didactic: String, actionPoints: String) {
        // Resposta esperada: {"didctarized": "...", "actionPoints": ["...", "..."]}
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            // Fallback: se não for JSON, retorna texto completo
            print("⚠️ Patient analysis não é JSON válido, usando texto completo")
            return (text, "")
        }
        
        let didactic = json["didctarized"] as? String ?? ""
        let actionPointsArray = json["actionPoints"] as? [String] ?? []
        let actionPoints = actionPointsArray.joined(separator: "\n\n")
        
        print("✅ Patient analysis parsed: didactic=\(didactic.prefix(50))..., actionPoints=\(actionPoints.prefix(50))...")
        
        return (didactic, actionPoints)
    }
}
