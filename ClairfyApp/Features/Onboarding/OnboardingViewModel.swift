//
//  OnboardingViewModel.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import Foundation
import Combine
import SwiftUI

@Observable
class OnboardingViewModel: OnboardingViewModelProtocol {
    private let repository: OnboardingRepositoryProtocol
    
    var pages: [OnboardingPage] = []
    var termsAndConditions: String = ""
    var currentPageIndex: Int = 0
    var showConsentAlert: Bool = false
    var didCompleteOnboarding: Bool = false
    var isOnboardingDone: Bool = false {
        didSet {
            UserDefaults.standard.set(isOnboardingDone, forKey: "onboarding")
        }
    }
    
    init(repository: OnboardingRepositoryProtocol = OnboardingRepository()) {
        self.repository = repository
        self.isOnboardingDone = UserDefaults.standard.bool(forKey: "onboarding")
    }

    func loadInfo() {
        self.pages = repository.fetchOnboardingPages()
        self.termsAndConditions = repository.fetchTerms()
    }

    func goToNextPage() {
        if currentPageIndex < pages.count - 1 {
            currentPageIndex += 1
        } else {
            showConsentAlert = true
        }
    }

    func skipOnboarding() {
        currentPageIndex = 2
        showConsentAlert = true
    }
    
    func agreeToTerms() {
        isOnboardingDone = true
        didCompleteOnboarding = true
    }
}
