//
//  OnboardingView.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import SwiftUI

struct OnboardingView: View {
    @State var viewModel: OnboardingViewModelProtocol
    
    var body: some View {
        VStack {
            TabView(selection: $viewModel.currentPageIndex) {
                ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                    OnboardingPageView(
                        page: page,
                        onNext: viewModel.goToNextPage,
                        onSkip: viewModel.skipOnboarding
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.default, value: viewModel.currentPageIndex)
        }
        .onAppear {
            viewModel.loadInfo()
        }
        .background(Color(.secondarySystemBackground))
        .alert("Seu Compromisso de Uso", isPresented: $viewModel.showConsentAlert) {
            Button("Estou Ciente e Concordo", role: .none, action: viewModel.agreeToTerms)
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text(viewModel.termsAndConditions)
        }
    }
}

