//
//  PulsatingRecordingIndicator.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import SwiftUI

struct PulsatingRecordingIndicator: View {
    let recordingState: RecordingState
    @State private var isAnimating = false
    private let activeColor = Color.clairBlue

    var body: some View {
        let shouldAnimate = recordingState == .recording || recordingState == .paused
        let animationDuration = recordingState == .recording ? 1.0 : 2.0

        ZStack {
            ForEach(0..<3) { index in
                Circle()
                    .stroke(activeColor, lineWidth: 8)
                    .opacity(shouldAnimate && isAnimating ? 0.1 : 0.5)
                    .frame(width: 220 + CGFloat(index * 50), height: 220 + CGFloat(index * 50))
                    .animation(
                        shouldAnimate ?
                            .easeInOut(duration: animationDuration)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * (animationDuration / 3))
                            : .default,
                        value: isAnimating
                    )
            }
            
            ZStack {
                Circle()
                    .fill(activeColor)
                
                switch recordingState {
                case .idle:
                    Image(systemName: "mic.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(.secondarySystemBackground))
                case .recording:
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color(.secondarySystemBackground))
                            .frame(width: 8, height: 8)
                        Text("REC")
                            .font(.system(size: 22))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(.secondarySystemBackground))
                    }
                case .paused:
                    Image(systemName: "pause.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(.secondarySystemBackground))
                }
            }
            .frame(width: 166, height: 166)
        }
        .onAppear {
            isAnimating = true
        }
    }
}
