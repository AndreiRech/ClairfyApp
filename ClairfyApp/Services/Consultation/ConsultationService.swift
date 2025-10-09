//
//  ConsultationService.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import Foundation
import SwiftData

final class ConsultationService: ConsultationServiceProtocol {
    private let context: ModelContext
    
    @MainActor
    init() {
        self.context = Persistence.shared.modelContext
    }
    
    func fetchConsultations() throws -> [Consultation] {
        do {
            let fetchDescriptor = FetchDescriptor<Consultation>()
            return try context.fetch(fetchDescriptor)
        } catch {
            throw error
        }
    }
    
    func fetchConsultation(by id: UUID) throws -> Consultation? {
        do {
            let predicate = #Predicate<Consultation> { $0.id == id }
            var fetchDescriptor = FetchDescriptor<Consultation>(predicate: predicate)
            fetchDescriptor.fetchLimit = 1
            
            let consultations = try context.fetch(fetchDescriptor)
            return consultations.first
        } catch {
            throw error
        }
    }
    
    func createConsultation(with consultation: Consultation) throws {
        context.insert(consultation)
        try save()
    }
    
    func updateConsultation(by id: UUID, with updatedConsultation: Consultation) throws {
        if let consultationToUpdate = try fetchConsultation(by: id) {
            consultationToUpdate.title = updatedConsultation.title
            consultationToUpdate.audio = updatedConsultation.audio
            consultationToUpdate.date = updatedConsultation.date
            consultationToUpdate.transcription = updatedConsultation.transcription
            
            try save()
        }
    }
    
    func deleteConsultation(by id: UUID) throws {
        if let consultationToDelete = try fetchConsultation(by: id) {
            context.delete(consultationToDelete)
            try save()
        }
    }
    
    private func save() throws {
        do {
            try context.save()
        } catch {
            throw error
        }
    }
}
