//
//  OnboardingRepositoryService.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

protocol OnboardingRepositoryProtocol {
    func fetchOnboardingPages() -> [OnboardingPage]
    func fetchTerms() -> String
}
