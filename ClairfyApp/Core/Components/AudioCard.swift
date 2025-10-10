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
                
                VStack(spacing: 0) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(totalTime)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            // audioForm
            // .frame(height: 50)
        }
        .padding(24)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .background(Color(.tertiarySystemBackground))
    }
}
