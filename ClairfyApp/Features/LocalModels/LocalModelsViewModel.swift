//
//  LocalModelsViewModel.swift
//  ClairfyApp
//

import Foundation
import SwiftUI

enum LocalModelInstallationDisplayPhase: Equatable {
    case notInstalled
    case downloading(progress: Double)
    case verifying
    case ready
    case failed(String)
}

struct LocalModelRowModel: Identifiable, Equatable {
    let id: LocalModelBundleID
    let displayName: String
    let expectedSizeDescription: String
    var phase: LocalModelInstallationDisplayPhase
}

@MainActor
@Observable
final class LocalModelsViewModel {
    private let catalog: [LocalModelDescriptor]
    private let downloadService: ModelDownloadServing
    private let verificationService: ModelVerifying
    private let inferenceEngine: LocalInferenceEngine
    private let recordingLocator: LatestRecordingLocating

    private(set) var rows: [LocalModelRowModel] = []

    var lastTestSummary: String?
    var lastTestActions: String?
    var bannerMessage: String?

    init(
        catalog: [LocalModelDescriptor] = LocalModelCatalog.shared,
        downloadService: ModelDownloadServing = ModelDownloadService(),
        verificationService: ModelVerifying = ModelVerificationService(),
        inferenceEngine: LocalInferenceEngine = StubLocalInferenceEngine(),
        recordingLocator: LatestRecordingLocating = LatestRecordingLocator()
    ) {
        self.catalog = catalog
        self.downloadService = downloadService
        self.verificationService = verificationService
        self.inferenceEngine = inferenceEngine
        self.recordingLocator = recordingLocator
        rebuildRowsFromDisk()
    }

    func rebuildRowsFromDisk() {
        rows = catalog.map { desc in
            let url = LocalModelStorage.fileURL(for: desc.id)
            let phase: LocalModelInstallationDisplayPhase
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    try verificationService.verifyArtifact(at: url, expectedSizeBytes: desc.expectedArtifactSizeBytes)
                    phase = .ready
                } catch {
                    phase = .failed(error.localizedDescription)
                }
            } else {
                phase = .notInstalled
            }
            return LocalModelRowModel(
                id: desc.id,
                displayName: desc.displayName,
                expectedSizeDescription: ByteCountFormatter.string(fromByteCount: desc.expectedArtifactSizeBytes, countStyle: .file),
                phase: phase
            )
        }
    }

    private func updateRow(id: LocalModelBundleID, phase: LocalModelInstallationDisplayPhase) {
        guard let idx = rows.firstIndex(where: { $0.id == id }) else { return }
        rows[idx].phase = phase
    }

    func startDownload(for id: LocalModelBundleID) {
        guard let desc = LocalModelCatalog.descriptor(for: id) else { return }
        let dest = LocalModelStorage.fileURL(for: id)

        if let free = LocalModelStorage.freeDiskBytes() {
            let headroom: Int64 = 512 * 1_024 * 1_024
            if free < desc.expectedArtifactSizeBytes + headroom {
                bannerMessage = "Espaço insuficiente. Livre aprox. \(ByteCountFormatter.string(fromByteCount: desc.expectedArtifactSizeBytes + headroom, countStyle: .memory))."
                updateRow(id: id, phase: .failed("Espaço insuficiente"))
                return
            }
        }

        bannerMessage = nil
        try? FileManager.default.removeItem(at: dest)
        updateRow(id: id, phase: .downloading(progress: 0))

        downloadService.download(
            descriptor: desc,
            destinationURL: dest,
            onProgress: { [weak self] p in
                Task { @MainActor in
                    self?.updateRow(id: id, phase: .downloading(progress: p))
                }
            },
            onComplete: { [weak self] result in
                Task { @MainActor in
                    guard let self else { return }
                    switch result {
                    case .success:
                        self.updateRow(id: id, phase: .verifying)
                        do {
                            try self.verificationService.verifyArtifact(at: dest, expectedSizeBytes: desc.expectedArtifactSizeBytes)
                            self.updateRow(id: id, phase: .ready)
                            self.bannerMessage = "\(desc.displayName) instalado com sucesso."
                        } catch {
                            self.updateRow(id: id, phase: .failed(error.localizedDescription))
                            self.bannerMessage = error.localizedDescription
                        }
                    case .failure(let error):
                        let ns = error as NSError
                        if ns.code == NSURLErrorCancelled {
                            self.rebuildRowsFromDisk()
                            self.bannerMessage = "Download cancelado."
                            return
                        }
                        self.updateRow(id: id, phase: .failed(error.localizedDescription))
                        self.bannerMessage = error.localizedDescription
                    }
                }
            }
        )
    }

    func cancelDownload(for id: LocalModelBundleID) {
        downloadService.cancelDownload(for: id)
        rebuildRowsFromDisk()
    }

    func deleteModel(for id: LocalModelBundleID) {
        downloadService.cancelDownload(for: id)
        let url = LocalModelStorage.fileURL(for: id)
        try? FileManager.default.removeItem(at: url)
        lastTestSummary = nil
        lastTestActions = nil
        rebuildRowsFromDisk()
        bannerMessage = "Modelo removido."
    }

    func verifyOnly(for id: LocalModelBundleID) {
        guard let desc = LocalModelCatalog.descriptor(for: id) else { return }
        let url = LocalModelStorage.fileURL(for: id)
        updateRow(id: id, phase: .verifying)
        do {
            try verificationService.verifyArtifact(at: url, expectedSizeBytes: desc.expectedArtifactSizeBytes)
            updateRow(id: id, phase: .ready)
            bannerMessage = "Verificação OK."
        } catch {
            updateRow(id: id, phase: .failed(error.localizedDescription))
            bannerMessage = error.localizedDescription
        }
    }

    func runSmokeTest(for id: LocalModelBundleID) async {
        lastTestSummary = nil
        lastTestActions = nil
        guard let desc = LocalModelCatalog.descriptor(for: id) else { return }
        let weightsURL = LocalModelStorage.fileURL(for: id)
        do {
            try verificationService.verifyArtifact(at: weightsURL, expectedSizeBytes: desc.expectedArtifactSizeBytes)
        } catch {
            bannerMessage = "Instale ou verifique o modelo antes do teste."
            updateRow(id: id, phase: .failed(error.localizedDescription))
            return
        }

        guard let audio = recordingLocator.latestRecordingURL() else {
            bannerMessage = "Grave um áudio (≥30s) na lista de consultas para existir um .m4a de teste."
            return
        }

        do {
            let result = try await inferenceEngine.summarize(
                model: id,
                audioURL: audio,
                localeIdentifier: Locale.current.identifier
            )
            lastTestSummary = result.summary
            lastTestActions = result.actionPoints
            bannerMessage = "Teste concluído (motor: \(inferenceEngine.useStubResponses ? "simulação" : "nativo"))."
            updateRow(id: id, phase: .ready)
        } catch {
            bannerMessage = error.localizedDescription
            updateRow(id: id, phase: .failed(error.localizedDescription))
        }
    }
}
