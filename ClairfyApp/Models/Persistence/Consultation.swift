//
//  Consultation.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import Foundation
import SwiftData

@Model
final class Consultation: Identifiable {
    var id: UUID = UUID()
    var title: String = ""
    var date: Date = Date()
    
    @Relationship(deleteRule: .cascade, inverse: \AudioFile.consultation)
    var audio: AudioFile?
    
    @Relationship(deleteRule: .cascade, inverse: \Transcription.consultation)
    var transcription: Transcription?
    
    init(id: UUID = UUID(), title: String, date: Date = Date(), audio: AudioFile? = nil, transcription: Transcription? = nil) {
        self.id = id
        self.title = title
        self.date = date
        self.audio = audio
        self.transcription = transcription
    }
}
