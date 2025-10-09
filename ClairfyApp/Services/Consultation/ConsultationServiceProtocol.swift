//
//  ConsultationServiceProtocol.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import Foundation

protocol ConsultationServiceProtocol {
    func fetchConsultations() throws -> [Consultation]
    func fetchConsultation(by id: UUID) throws -> Consultation?
    func createConsultation(with consultation: Consultation) throws
    func updateConsultation(by id: UUID, with updatedConsultation: Consultation) throws
    func deleteConsultation(by id: UUID) throws
}
