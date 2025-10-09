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
    }
    
    private func setupSession() {
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session: \(error.localizedDescription)")
        }
    }
    
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
        } catch {
            finishRecording()
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func finishRecording() {
        audioRecorder?.stop()
        isRecording = false
        audioRecorder = nil
    }
    
    func pauseRecording() {
        guard isRecording else { return }
        audioRecorder?.pause()
        isRecording = false
    }
    
    func resumeRecording() {
        guard let recorder = audioRecorder, !recorder.isRecording else { return }
        recorder.record()
        isRecording = true
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording()
        }
    }
}
