//
//  VoiceRecordingRepositoryProtocol.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import Foundation

protocol VoiceRecordingRepositoryProtocol {
    var isRecording: Bool { get }
    var recordingURL: URL? { get }
    var currentTime: TimeInterval { get }
    var averagePower: Float { get }
    
    func createAudio(with audio: AudioFile) throws
    
    func startRecording()
    func finishRecording()
    func pauseRecording()
    func resumeRecording()
    func createConsultation(with consultation: Consultation) throws
}
