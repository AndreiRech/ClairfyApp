//
//  AudioCard.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import SwiftUI

struct AudioCard: View {
    let title: String
    let description: String
    let totalTime: String
    var isPlaying: Bool = false
    var audio: AudioFile
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 8) {
                
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color(.clairBlue))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    HStack{
                        Text(description)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(totalTime)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(24)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview("AudioCard Preview") {
    let sampleAudio = AudioFile(audioPath: "/tmp/fake.m4a")
    return AudioCard(
        title: "Consulta de Rotina",
        description: "09/10/2025 · 14:32",
        totalTime: "12:45",
        isPlaying: false,
        audio: sampleAudio
    )
    .padding()
    .background(Color(.systemBackground))
}
