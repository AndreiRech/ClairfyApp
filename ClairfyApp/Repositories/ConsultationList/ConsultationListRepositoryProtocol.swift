//
//  ConsultationListRepositoryProtocols.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import Foundation

protocol ConsultationListRepositoryProtocol {
    func fetchConsultations() throws -> [Consultation]
    func deleteConsultation(by id: UUID) throws
}
