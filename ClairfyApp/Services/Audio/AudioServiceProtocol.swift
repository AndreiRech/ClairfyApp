//
//  AudioServiceProtocol.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import Foundation

protocol AudioServiceProtocol {
    func fetchAudios() throws -> [AudioFile]
    func fetchAudio(by id: UUID) throws -> AudioFile?
    func createAudio(with audio: AudioFile) throws
    func updateAudio(by id: UUID, with updatedAudio: AudioFile) throws
    func deleteAudio(by id: UUID) throws
}
