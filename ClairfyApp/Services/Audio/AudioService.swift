//
//  AudioService.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import Foundation
import SwiftData

final class AudioService: AudioServiceProtocol {
    private let context: ModelContext
    
    @MainActor
    init() {
        self.context = Persistence.shared.modelContext
    }
    
    func fetchAudios() throws -> [AudioFile] {
        do {
            let fetchDescriptor = FetchDescriptor<AudioFile>()
            return try context.fetch(fetchDescriptor)
        } catch {
            throw error
        }
    }
    
    func fetchAudio(by id: UUID) throws -> AudioFile? {
        do {
            let predicate = #Predicate<AudioFile> { $0.id == id }
            var fetchDescriptor = FetchDescriptor<AudioFile>(predicate: predicate)
            fetchDescriptor.fetchLimit = 1
            
            let audios = try context.fetch(fetchDescriptor)
            return audios.first
        } catch {
            throw error
        }
    }
    
    func createAudio(with audio: AudioFile) throws {
        context.insert(audio)
        try save()
    }
    
    func updateAudio(by id: UUID, with updatedAudio: AudioFile) throws {
        if let audioToUpdate = try fetchAudio(by: id) {
            audioToUpdate.audioPath = updatedAudio.audioPath
            audioToUpdate.consultation = updatedAudio.consultation
            
            try save()
        }
    }
    
    func deleteAudio(by id: UUID) throws {
        if let audioToDelete = try fetchAudio(by: id) {
            context.delete(audioToDelete)
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
