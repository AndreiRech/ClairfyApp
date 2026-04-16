//
//  LocalModelsViewModel.swift
//  ClairfyApp
//

import Foundation
import SwiftUI

enum LocalModelInstallationDisplayPhase: Equatable {
    case notInstalled
    case downloading(DownloadProgressSnapshot)
    case verifying
    case ready
    case failed(String)
}

struct LocalModelRowModel: Identifiable {
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

    /// Progresso em tempo real (também quando o ecrã não está visível).
    private var liveProgressSnapshots: [LocalModelBundleID: DownloadProgressSnapshot] = [:]

    private var notificationTokens: [NSObjectProtocol] = []

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

        notificationTokens.append(
            NotificationCenter.default.addObserver(forName: .localModelDownloadProgress, object: nil, queue: .main) { [weak self] note in
                guard let self else { return }
                self.handleDownloadProgress(note)
            }
        )
        notificationTokens.append(
            NotificationCenter.default.addObserver(forName: .localModelDownloadCompleted, object: nil, queue: .main) { [weak self] note in
                guard let self else { return }
                self.handleDownloadCompleted(note)
            }
        )
    }

    deinit {
        notificationTokens.forEach { NotificationCenter.default.removeObserver($0) }
    }

    func rebuildRowsFromDisk() {
        rows = catalog.map { desc in
            if let snap = liveProgressSnapshots[desc.id] {
                return LocalModelRowModel(
                    id: desc.id,
                    displayName: desc.displayName,
                    expectedSizeDescription: ByteCountFormatter.string(fromByteCount: desc.expectedArtifactSizeBytes, countStyle: .file),
                    phase: .downloading(snap)
                )
            }

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

    private func handleDownloadProgress(_ note: Notification) {
        guard let raw = note.userInfo?["modelId"] as? String,
              let id = LocalModelBundleID(rawValue: raw),
              let snap = note.userInfo?["snapshot"] as? DownloadProgressSnapshot else { return }
        liveProgressSnapshots[id] = snap
        updateRow(id: id, phase: .downloading(snap))
    }

    private func handleDownloadCompleted(_ note: Notification) {
        guard let raw = note.userInfo?["modelId"] as? String,
              let id = LocalModelBundleID(rawValue: raw),
              let success = note.userInfo?["success"] as? Bool else { return }

        let cancelled = (note.userInfo?["cancelled"] as? Bool) == true
        liveProgressSnapshots[id] = nil

        if cancelled {
            rebuildRowsFromDisk()
            bannerMessage = "Download cancelado."
            return
        }

        guard let desc = LocalModelCatalog.descriptor(for: id) else {
            rebuildRowsFromDisk()
            return
        }

        let dest = LocalModelStorage.fileURL(for: id)

        if success {
            updateRow(id: id, phase: .verifying)
            do {
                try verificationService.verifyArtifact(at: dest, expectedSizeBytes: desc.expectedArtifactSizeBytes)
                updateRow(id: id, phase: .ready)
                bannerMessage = "\(desc.displayName) instalado. Pode usar o teste de inferência."
            } catch {
                updateRow(id: id, phase: .failed(error.localizedDescription))
                bannerMessage = error.localizedDescription
            }
        } else {
            let err = (note.userInfo?["errorDescription"] as? String) ?? "Download falhou."
            updateRow(id: id, phase: .failed(err))
            bannerMessage = err
        }
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

        bannerMessage = "Download em segundo plano: pode bloquear o telemóvel ou sair deste ecrã. O progresso actualiza-se automaticamente."
        try? FileManager.default.removeItem(at: dest)

        let initial = DownloadProgressSnapshot(
            fractionComplete: 0,
            bytesWritten: 0,
            expectedTotalBytes: desc.expectedArtifactSizeBytes,
            instantaneousBytesPerSecond: 0,
            smoothedBytesPerSecond: 0,
            estimatedSecondsRemaining: nil
        )
        liveProgressSnapshots[id] = initial
        updateRow(id: id, phase: .downloading(initial))

        downloadService.startDownload(descriptor: desc, destinationURL: dest)
    }

    func cancelDownload(for id: LocalModelBundleID) {
        liveProgressSnapshots[id] = nil
        downloadService.cancelDownload(for: id)
        rebuildRowsFromDisk()
    }

    func deleteModel(for id: LocalModelBundleID) {
        liveProgressSnapshots[id] = nil
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
