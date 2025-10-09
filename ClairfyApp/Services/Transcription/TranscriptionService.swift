//
//  TranscriptionService.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import Foundation
import SwiftData

final class TranscriptionService: TranscriptionServiceProtocol {
    private let context: ModelContext
    
    @MainActor
    init() {
        self.context = Persistence.shared.modelContext
    }
    
    func fetchTranscriptions() throws -> [Transcription] {
        do {
            let fetchDescriptor = FetchDescriptor<Transcription>()
            return try context.fetch(fetchDescriptor)
        } catch {
            throw error
        }
    }
    
    func fetchTranscription(by id: UUID) throws -> Transcription? {
        do {
            let predicate = #Predicate<Transcription> { $0.id == id }
            var fetchDescriptor = FetchDescriptor<Transcription>(predicate: predicate)
            fetchDescriptor.fetchLimit = 1
            
            let transcriptions = try context.fetch(fetchDescriptor)
            return transcriptions.first
        } catch {
            throw error
        }
    }
    
    func createTranscription(with transcription: Transcription) throws {
        context.insert(transcription)
        try save()
    }
    
    func updateTranscription(by id: UUID, with updatedTranscription: Transcription) throws {
        if let transcriptionToUpdate = try fetchTranscription(by: id) {
            transcriptionToUpdate.actionPoints = updatedTranscription.actionPoints
            transcriptionToUpdate.keyWords = updatedTranscription.keyWords
            transcriptionToUpdate.summary = updatedTranscription.summary
            transcriptionToUpdate.transcription = updatedTranscription.transcription
            transcriptionToUpdate.didactic = updatedTranscription.didactic
            transcriptionToUpdate.consultation = updatedTranscription.consultation
            
            try save()
        }
    }
    
    func deleteTranscription(by id: UUID) throws {
        if let transcriptionToDelete = try fetchTranscription(by: id) {
            context.delete(transcriptionToDelete)
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
