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
    var shouldNavigate: Bool = false
    var titleConsultation: String = ""
    private var newAudioFile: AudioFile?
    
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
        shouldNavigate = true
    }
    
    func deleteRecordingTapped() {
        repository.finishRecording() 
        recordingState = .idle
        stopTimer()
        resetRecording()
    }
    
    func createConsultation() {
      
        do {
            guard let newAudioFile = newAudioFile else { return }
            let consultation = Consultation(id: UUID(), title: titleConsultation, date: Date(), audio: newAudioFile, transcription: nil)
            
            try repository.createConsultation(with: consultation)
        } catch {
            print("Failed to save recording: \(error.localizedDescription)")
        }
        
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
        
        newAudioFile = AudioFile(audioPath: url.absoluteString)
        do {
            guard let newAudioFile = newAudioFile else { return }
            try repository.createAudio(with: newAudioFile)
            print("Recording saved successfully!")
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
