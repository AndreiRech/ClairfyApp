//
//  OnboardingPageView.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage
    var onNext: () -> Void
    var onSkip: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .padding(.top, 24)

            VStack(spacing: 24) {
                Text(page.title.highlight(substring: page.highlight, with: .clairBlue))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text(page.description.highlight(substring: page.highlight, with: .clairBlue))
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 14)
            .padding(.bottom)

            VStack(spacing: 16) {
                Button(action: onNext) {
                    Text("Continuar")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundColor(.clairBlue)
                        .glassEffect()
                }
                
                Button("Pular", action: onSkip)
                    .font(.body)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
            
            Spacer()
        }
    }
}
