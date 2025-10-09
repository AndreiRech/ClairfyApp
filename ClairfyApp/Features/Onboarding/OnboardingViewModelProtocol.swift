//
//  OnboardingViewModelProtocol.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import Foundation

protocol OnboardingViewModelProtocol {
    var pages: [OnboardingPage] { get }
    var termsAndConditions: String { get }
    var currentPageIndex: Int { get set }
    var showConsentAlert: Bool { get set }
    var didCompleteOnboarding: Bool { get set }

    func loadInfo()
    func goToNextPage()
    func skipOnboarding()
    func agreeToTerms()
}
