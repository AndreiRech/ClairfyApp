//
//  VoiceRecordingView.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import SwiftUI

struct VoiceRecordingView: View {
    @State var viewModel: VoiceRecordingViewModelProtocol
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            PulsatingRecordingIndicator(
                recordingState: viewModel.recordingState,
            )
            .frame(width: 328, height: 328)
            
            Text(viewModel.recordingTime.formatTime())
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(Color(.label))
            
            AudioWaveformView(samples: viewModel.audioSamples)
                .frame(height: 80)
            
                HStack(alignment: .center, spacing: 20) {
                    Button {
                        viewModel.deleteRecordingTapped()
                    } label: {
                        Image(systemName: "trash.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 67, height: 67)
                            .foregroundColor(Color(.label))
                    }
                    
                    Button {
                        switch viewModel.recordingState {
                        case .idle:
                            viewModel.startRecordingTapped()
                        case .recording:
                            viewModel.pauseRecordingTapped()
                        case .paused:
                            viewModel.resumeRecordingTapped()
                        }
                    } label: {
                        Image(systemName: viewModel.recordingState == .recording ? "pause.circle.fill" : (viewModel.recordingState == .paused ? "play.circle.fill" : "mic.circle.fill"))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 110)
                            .foregroundColor(Color(.clairBlue))
                    }
                    
                    Button {
                        viewModel.stopRecordingTapped()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 67, height: 67)
                            .foregroundColor(Color(.label))
                    }
                }
            
            Spacer()
        }
        .background(Color(.secondarySystemBackground))
        .navigationTitle("Gravação de Áudio")
        .navigationBarTitleDisplayMode(.inline)
    }
}
