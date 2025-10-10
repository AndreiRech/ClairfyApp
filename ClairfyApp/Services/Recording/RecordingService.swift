//
//  RecordingService.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import Foundation
import AVFoundation

class RecordingService: NSObject, RecordingServiceProtocol, AVAudioRecorderDelegate {
    
    private var audioRecorder: AVAudioRecorder?
    private var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    private var wasRecordingBeforeInterruption = false
    
    var isRecording = false
    var recordingURL: URL?
    
    var currentTime: TimeInterval {
        return audioRecorder?.currentTime ?? 0
    }
    
    var averagePower: Float {
        audioRecorder?.updateMeters()
        let decibels = audioRecorder?.averagePower(forChannel: 0) ?? -160
        let normalizedPower = pow(10, decibels / 20)
        return normalizedPower
    }
    
    override init() {
        super.init()
        setupSession()
        setupInterruptionNotifications()
    }
    
    // MARK: - Setup
    
    private func setupSession() {
        do {
            try recordingSession.setCategory(.playAndRecord,
                                             mode: .default,
                                             options: [.duckOthers])
            try recordingSession.setActive(true)
        } catch {
            print("❌ Failed to set up recording session: \(error.localizedDescription)")
        }
    }
    
    private func setupInterruptionNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }
    
    // MARK: - Recording Controls
    
    func startRecording() {
        let fileName = "recording-\(Date().timeIntervalSince1970).m4a"
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentPath.appendingPathComponent(fileName)
        self.recordingURL = audioURL
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            isRecording = true
            ///print("🎙️ Recording started.")
        } catch {
            finishRecording()
            print("❌ Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func finishRecording() {
        audioRecorder?.stop()
        isRecording = false
        audioRecorder = nil
        ///print("🛑 Recording finished.")
    }
    
    func pauseRecording() {
        guard isRecording else { return }
        audioRecorder?.pause()
        isRecording = false
        ///print("⏸️ Recording paused.")
    }
    
    func resumeRecording() {
        guard let recorder = audioRecorder, !recorder.isRecording else { return }
        recorder.record()
        isRecording = true
        ///print("▶️ Recording resumed.")
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording()
        }
    }
    
    // MARK: - Handle Interruptions
    
    @objc private func handleAudioSessionInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // Interrupção começou (ex: ligação, Siri, alarme etc.)
            if isRecording {
                wasRecordingBeforeInterruption = true
                pauseRecording()
                ///print("⚠️ Interruption began — recording paused.")
            }
            
        case .ended:
            // Interrupção terminou
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            
            if options.contains(.shouldResume), wasRecordingBeforeInterruption {
                resumeRecording()
                wasRecordingBeforeInterruption = false
                ///print("✅ Interruption ended — recording resumed automatically.")
            } else {
                ///print("ℹ️ Interruption ended — not resuming automatically.")
            }
            
        @unknown default:
            break
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
