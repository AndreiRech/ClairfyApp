//
//  VoiceRecordingRepository.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import Foundation

class VoiceRecordingRepository: VoiceRecordingRepositoryProtocol {
    private let audioService: AudioServiceProtocol
    private let recordingService: RecordingServiceProtocol
    private let consultationService: ConsultationServiceProtocol
    
    var isRecording: Bool { recordingService.isRecording }
    var recordingURL: URL? { recordingService.recordingURL }
    var currentTime: TimeInterval { recordingService.currentTime }
    var averagePower: Float { recordingService.averagePower }
    
    init(audioService: AudioServiceProtocol, recordingService: RecordingServiceProtocol, consultationSerevice: ConsultationServiceProtocol) {
        self.audioService = audioService
        self.recordingService = recordingService
        self.consultationService = consultationSerevice
    }
    
    func createAudio(with audio: AudioFile) throws {
        try audioService.createAudio(with: audio)
    }
    
    func createConsultation(with consultation: Consultation) throws {
        try consultationService.createConsultation(with: consultation)
    }
    
    func startRecording() {
        recordingService.startRecording()
    }
    
    func finishRecording() {
        recordingService.finishRecording()
    }
    
    func pauseRecording() {
        recordingService.pauseRecording()
    }
    
    func resumeRecording() {
        recordingService.resumeRecording()
    }
}
