//
//  VoiceRecordingViewModelProtocol.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import Foundation

protocol VoiceRecordingViewModelProtocol {
    var recordingState: RecordingState { get set }
    var audioSamples: [Float] { get set }
    var recordingTime: TimeInterval { get set }
    var hasMicrophonePermission: Bool { get set }
    var currentAudioLevel: CGFloat { get set }
    var shouldNavigate: Bool { get set }
    var titleConsultation: String { get set }
    var showDeleteConfirmation: Bool { get set }
    var showTooShortAlert: Bool { get set }
    
    var onDismiss: () -> Void { get }
    
    func startRecordingTapped()
    func pauseRecordingTapped()
    func resumeRecordingTapped()
    func stopRecordingTapped()
    func deleteRecordingTapped()
    func createConsultation()
    func confirmDeleteRecording()
}
