//
//  ClairfyApp.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 07/10/25.
//

import SwiftUI
import SwiftData

@main
struct ClairfyApp: App {
    @AppStorage("onboarding") var isOnboardingDone: Bool = false
    @State private var isSplashScreenActive = true
    
    var body: some Scene {
        WindowGroup {
            if !isSplashScreenActive {
                SplashScreenView()
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                self.isSplashScreenActive = false
                            }
                        }
                    }
            } else {
                if isOnboardingDone {
                    ConsultationListView(viewModel: ConsultationListViewModel(
                        repository: ConsultationListRepository(
                            service: ConsultationService()
                        )))
                } else {
                    OnboardingView(viewModel: OnboardingViewModel())
                }
            }
        }
        .modelContainer(for: [Consultation.self, Transcription.self, AudioFile.self])
    }
}
