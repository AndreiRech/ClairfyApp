//
//  OnboardingServiceProtocol.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

protocol OnboardingServiceProtocol {
    func getOnboardingData() -> [OnboardingPage]
    func getTermsAndConditions() -> String
}
