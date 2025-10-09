//
//  Transcription.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import Foundation
import SwiftData

@Model
final class Transcription: Identifiable {
    var id: UUID = UUID()
    var transcription: String = ""
    var summary: String = ""
    var didactic: String = ""
    var keyWords: String = ""
    var actionPoints: String = ""
    
    var consultation: Consultation?

    
    init(id: UUID = UUID(), transcription: String, summary: String, didactic: String, keyWords: String, actionPoints: String) {
        self.id = id
        self.transcription = transcription
        self.summary = summary
        self.didactic = didactic
        self.keyWords = keyWords
        self.actionPoints = actionPoints
    }
}
