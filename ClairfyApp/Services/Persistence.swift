import SwiftData

final class Persistence {
    @MainActor
    static let shared = Persistence()
    
    let modelContainer: ModelContainer
    let modelContext: ModelContext
    
    @MainActor
    init() {
        self.modelContainer = try! ModelContainer(
            for: Consultation.self, Transcription.self, AudioFile.self
        )
        self.modelContext = modelContainer.mainContext
    }
}
