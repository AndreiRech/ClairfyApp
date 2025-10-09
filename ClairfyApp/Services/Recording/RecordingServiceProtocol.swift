//
//  RecordingServiceProtocol.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import Foundation

protocol RecordingServiceProtocol {
    var isRecording: Bool { get set }
    var recordingURL: URL? { get set }
    var currentTime: TimeInterval { get }
    var averagePower: Float { get }
    
    func startRecording()
    func finishRecording()
    func pauseRecording()
    func resumeRecording()
}
