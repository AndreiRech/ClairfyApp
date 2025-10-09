//
//  AudioFile.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import Foundation
import SwiftData

@Model
final class AudioFile: Identifiable {
    var id: UUID = UUID()
    var audioPath: String = ""
    
    var consultation: Consultation?
    
    init(id: UUID = UUID(), audioPath: String) {
        self.id = id
        self.audioPath = audioPath
    }
}
