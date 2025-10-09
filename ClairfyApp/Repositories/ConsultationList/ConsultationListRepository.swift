//
//  ConsultationListRepository.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import Foundation

class ConsultationListRepository: ConsultationListRepositoryProtocol {
    private let service: ConsultationServiceProtocol

    init(service: ConsultationServiceProtocol) {
        self.service = service
    }

    func fetchConsultations() throws -> [Consultation] {
        return try service.fetchConsultations()
    }
    
    func deleteConsultation(by id: UUID) throws {
        return try service.deleteConsultation(by: id)
    }
    
}
