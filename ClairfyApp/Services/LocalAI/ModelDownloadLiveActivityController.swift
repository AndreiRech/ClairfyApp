//
//  ModelDownloadLiveActivityController.swift
//  ClairfyApp
//
//  Live Activity (Dynamic Island + Lock Screen) + notificações locais actualizáveis como fallback.
//

import ActivityKit
import Foundation
import UserNotifications

@MainActor
final class ModelDownloadLiveActivityController {
    static let shared = ModelDownloadLiveActivityController()

    private var activities: [String: Activity<ModelDownloadLiveAttributes>] = [:]
    private var notificationObserverBag = NotificationObserverBag()

    private init() {}

    func beginObserving() {
        notificationObserverBag.insert(
            NotificationCenter.default.addObserver(forName: .localModelDownloadProgress, object: nil, queue: .main) { [weak self] note in
                Task { @MainActor in
                    await self?.handleProgress(note)
                }
            }
        )
        notificationObserverBag.insert(
            NotificationCenter.default.addObserver(forName: .localModelDownloadCompleted, object: nil, queue: .main) { [weak self] note in
                Task { @MainActor in
                    await self?.handleCompleted(note)
                }
            }
        )
    }

    private func handleProgress(_ note: Notification) async {
        guard let raw = note.userInfo?["modelId"] as? String,
              let id = LocalModelBundleID(rawValue: raw),
              let snap = note.userInfo?["snapshot"] as? DownloadProgressSnapshot,
              let desc = LocalModelCatalog.descriptor(for: id) else { return }

        let phase = snap.phaseLabel ?? "Download"
        let pct = Int(snap.fractionComplete * 100)
        let detail = "\(snap.formattedDownloaded()) · \(snap.speedDescription())"

        await updateLiveActivity(
            modelKey: raw,
            displayName: desc.displayName,
            phaseLabel: phase,
            progress: snap.fractionComplete,
            detail: detail
        )

        await postOrUpdateNotification(
            modelKey: raw,
            title: "Clairfy — \(desc.displayName)",
            subtitle: "\(phase) · \(pct)%",
            body: detail
        )
    }

    private func handleCompleted(_ note: Notification) async {
        guard let raw = note.userInfo?["modelId"] as? String,
              let id = LocalModelBundleID(rawValue: raw),
              let desc = LocalModelCatalog.descriptor(for: id) else { return }

        let cancelled = (note.userInfo?["cancelled"] as? Bool) == true
        let success = (note.userInfo?["success"] as? Bool) == true

        await endLiveActivity(modelKey: raw)

        if cancelled {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notificationId(for: raw)])
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId(for: raw)])
            return
        }

        if success {
            let artifact = note.userInfo?["artifactKind"] as? String
            let doneText: String
            if artifact == ModelDownloadArtifact.mmproj.rawValue {
                doneText = "Multimodal (mmproj) concluído."
            } else if desc.mmproj != nil, artifact != ModelDownloadArtifact.mmproj.rawValue {
                doneText = "Pesos GGUF concluídos. A seguir: mmproj…"
            } else {
                doneText = "Download concluído."
            }
            await postOrUpdateNotification(
                modelKey: raw,
                title: "Clairfy — \(desc.displayName)",
                subtitle: doneText,
                body: "Pode voltar à app para verificar."
            )
            // Remove após breve tempo para não poluir
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [self.notificationId(for: raw)])
            }
        } else {
            let err = (note.userInfo?["errorDescription"] as? String) ?? "Falha"
            await postOrUpdateNotification(
                modelKey: raw,
                title: "Clairfy — \(desc.displayName)",
                subtitle: "Download falhou",
                body: err
            )
        }
    }

    // MARK: - Live Activity

    private func updateLiveActivity(
        modelKey: String,
        displayName: String,
        phaseLabel: String,
        progress: Double,
        detail: String
    ) async {
        guard #available(iOS 16.2, *) else { return }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let state = ModelDownloadLiveAttributes.ContentState(
            phaseLabel: phaseLabel,
            progress: min(1, max(0, progress)),
            detail: detail
        )

        if let existing = activities[modelKey] {
            await existing.update(using: state)
            return
        }

        let attributes = ModelDownloadLiveAttributes(modelDisplayName: displayName)
        do {
            let act = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
            activities[modelKey] = act
        } catch {
            activities[modelKey] = nil
        }
    }

    private func endLiveActivity(modelKey: String) async {
        guard #available(iOS 16.2, *) else { return }
        guard let act = activities.removeValue(forKey: modelKey) else { return }
        await act.end(nil, dismissalPolicy: .immediate)
    }

    // MARK: - Notificações (fallback / reforço)

    private func notificationId(for modelKey: String) -> String {
        "com.clairfy.modeldownload.\(modelKey)"
    }

    private func postOrUpdateNotification(modelKey: String, title: String, subtitle: String, body: String) async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = .default

        let req = UNNotificationRequest(
            identifier: notificationId(for: modelKey),
            content: content,
            trigger: nil
        )
        try? await center.add(req)
    }

    /// Pedir autorização (chamar no arranque ou antes do primeiro download).
    func requestNotificationAuthorizationIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .notDetermined else { return }
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }
}

// MARK: - Mini bag para observadores (evita deinit @MainActor)

private final class NotificationObserverBag: @unchecked Sendable {
    private var tokens: [NSObjectProtocol] = []
    private let lock = NSLock()

    func insert(_ token: NSObjectProtocol) {
        lock.lock()
        tokens.append(token)
        lock.unlock()
    }

    deinit {
        lock.lock()
        let copy = tokens
        tokens = []
        lock.unlock()
        copy.forEach { NotificationCenter.default.removeObserver($0) }
    }
}
