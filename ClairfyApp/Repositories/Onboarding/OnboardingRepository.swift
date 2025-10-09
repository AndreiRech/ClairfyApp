//
//  OnboardingRepository.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import Foundation

class OnboardingRepository: OnboardingRepositoryProtocol {
    private let service: OnboardingServiceProtocol

    init(service: OnboardingServiceProtocol = OnboardingService()) {
        self.service = service
    }

    func fetchOnboardingPages() -> [OnboardingPage] {
        return service.getOnboardingData()
    }
    
    func fetchTerms() -> String {
        return service.getTermsAndConditions()
    }
}
