//
//  TrasncriptionServiceProtocol.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import Foundation

protocol TranscriptionServiceProtocol {
    func fetchTranscriptions() throws -> [Transcription]
    func fetchTranscription(by id: UUID) throws -> Transcription?
    func createTranscription(with transcription: Transcription) throws
    func updateTranscription(by id: UUID, with updatedTranscription: Transcription) throws
    func deleteTranscription(by id: UUID) throws
}
