//
//  VoiceRecordingViewModel.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import Foundation
import SwiftUI
import AVFoundation

@Observable
class VoiceRecordingViewModel: VoiceRecordingViewModelProtocol {
    var recordingState: RecordingState = .idle
    var audioSamples: [Float] = []
    var recordingTime: TimeInterval = 0
    var hasMicrophonePermission = false
    var currentAudioLevel: CGFloat = 0.0
    var shouldDismiss = false
    
    private let repository: VoiceRecordingRepositoryProtocol
    private var timer: Timer?
    
    init(repository: VoiceRecordingRepositoryProtocol) {
        self.repository = repository
        checkMicrophonePermission()
    }
    
    func startRecordingTapped() {
        guard hasMicrophonePermission else {
            return
        }
        
        repository.startRecording()
        recordingState = .recording
        startTimer()
    }
    
    func pauseRecordingTapped() {
        repository.pauseRecording()
        recordingState = .paused
        stopTimer()
    }
    
    func resumeRecordingTapped() {
        repository.resumeRecording()
        recordingState = .recording
        startTimer()
    }
    
    func stopRecordingTapped() {
        repository.finishRecording()
        recordingState = .idle
        stopTimer()
        saveRecording()
        resetRecording()
    }
    
    func deleteRecordingTapped() {
        repository.finishRecording() 
        recordingState = .idle
        stopTimer()
        resetRecording()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.recordingTime = self.repository.currentTime
            
            let power = self.repository.averagePower
            self.audioSamples.append(power)
            
            self.currentAudioLevel = self.normalizeAudioPower(level: power)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        currentAudioLevel = 0.0
    }
    
    private func saveRecording() {
        guard let url = repository.recordingURL else {
            print("Recording URL not found.")
            return
        }
        
        // Cria o AudioFile com o caminho do arquivo gravado
        let newAudioFile = AudioFile(audioPath: url.path)
        
        // Cria uma Consultation com título baseado na data e hora
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let title = "Consulta \(dateFormatter.string(from: Date()))"
        
        let newConsultation = Consultation(
            title: title,
            date: Date(),
            audio: newAudioFile
        )
        
        do {
            try repository.createConsultation(with: newConsultation)
            print("Recording saved successfully!")
            shouldDismiss = true
        } catch {
            print("Failed to save recording: \(error.localizedDescription)")
        }
    }
    
    private func resetRecording() {
        recordingTime = 0
        audioSamples = []
    }
    
    private func normalizeAudioPower(level: Float) -> CGFloat {
        let minDb: Float = -160.0
        let maxDb: Float = 0.0
        
        let clampedLevel = max(min(level, maxDb), minDb)
        
        let normalized = (clampedLevel - minDb) / (maxDb - minDb)
        
        return CGFloat(normalized)
    }
    
    private func checkMicrophonePermission() {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            hasMicrophonePermission = true
        case .denied:
            hasMicrophonePermission = false
        case .undetermined:
            AVAudioApplication.requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    self?.hasMicrophonePermission = granted
                }
            }
        @unknown default:
            hasMicrophonePermission = false
        }
    }
}
