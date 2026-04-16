//
//  ModelDownloadCoordinator.swift
//  ClairfyApp
//
//  URLSession em background + telemetria. Singleton para o sistema reassociar tarefas após suspender a app.
//

import Foundation

private final class PendingBox {
    let destinationURL: URL
    let modelId: LocalModelBundleID
    let expectedArtifactSizeBytes: Int64
    var didDeliverCompletion = false
    var lastBytes: Int64 = 0
    var lastTick: Date?
    var smoothedBytesPerSecond: Double = 0

    init(destinationURL: URL, modelId: LocalModelBundleID, expectedArtifactSizeBytes: Int64) {
        self.destinationURL = destinationURL
        self.modelId = modelId
        self.expectedArtifactSizeBytes = expectedArtifactSizeBytes
    }
}

final class ModelDownloadCoordinator: NSObject, URLSessionDownloadDelegate {
    static let shared = ModelDownloadCoordinator()

    private let stateLock = NSLock()
    private var backgroundEventsCompletion: (() -> Void)?

    private let sessionIdentifier: String

    private lazy var session: URLSession = {
        var configuration = URLSessionConfiguration.background(withIdentifier: sessionIdentifier)
        configuration.isDiscretionary = false
        configuration.sessionSendsLaunchEvents = true
        configuration.shouldUseExtendedBackgroundIdleMode = true
        configuration.timeoutIntervalForRequest = 60 * 60
        configuration.timeoutIntervalForResource = 60 * 60 * 72
        configuration.waitsForConnectivity = true
        configuration.allowsCellularAccess = true
        configuration.httpMaximumConnectionsPerHost = 1
        return URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
    }()

    private var pendingByTaskID: [Int: PendingBox] = [:]
    private var taskByModel: [LocalModelBundleID: URLSessionDownloadTask] = [:]

    private override init() {
        let bundleId = Bundle.main.bundleIdentifier ?? "ClairfyApp"
        self.sessionIdentifier = bundleId + ".modelWeightsBackground"
        super.init()
    }

    /// Garante que a sessão background fica registada (útil no arranque e após `handleEventsForBackgroundURLSession`).
    func ensureSessionWired() {
        _ = session
    }

    func setBackgroundSessionEventsCompletionHandler(_ handler: @escaping () -> Void) {
        stateLock.lock()
        backgroundEventsCompletion = handler
        stateLock.unlock()
        ensureSessionWired()
    }

    func cancelDownload(for model: LocalModelBundleID) {
        stateLock.lock()
        let task = taskByModel[model]
        taskByModel[model] = nil
        stateLock.unlock()
        task?.cancel()
    }

    func startDownload(descriptor: LocalModelDescriptor, destinationURL: URL) {
        cancelDownload(for: descriptor.id)
        ensureSessionWired()

        var request = URLRequest(url: descriptor.downloadURL)
        request.httpMethod = "GET"
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148",
            forHTTPHeaderField: "User-Agent"
        )
        request.setValue("*/*", forHTTPHeaderField: "Accept")

        let task = session.downloadTask(with: request)
        let box = PendingBox(
            destinationURL: destinationURL,
            modelId: descriptor.id,
            expectedArtifactSizeBytes: descriptor.expectedArtifactSizeBytes
        )

        stateLock.lock()
        pendingByTaskID[task.taskIdentifier] = box
        taskByModel[descriptor.id] = task
        stateLock.unlock()

        task.resume()
    }

    // MARK: URLSessionDownloadDelegate

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        stateLock.lock()
        guard let box = pendingByTaskID[downloadTask.taskIdentifier] else {
            stateLock.unlock()
            return
        }
        if box.didDeliverCompletion {
            stateLock.unlock()
            return
        }

        let expectedTotal: Int64 = totalBytesExpectedToWrite > 0 ? totalBytesExpectedToWrite : box.expectedArtifactSizeBytes
        let now = Date()
        let instBps: Double
        if let prevT = box.lastTick {
            let dt = now.timeIntervalSince(prevT)
            let db = totalBytesWritten - box.lastBytes
            instBps = dt > 0.01 ? Double(db) / dt : 0
        } else {
            instBps = 0
        }
        box.lastBytes = totalBytesWritten
        box.lastTick = now

        if instBps > 0 {
            if box.smoothedBytesPerSecond <= 0 {
                box.smoothedBytesPerSecond = instBps
            } else {
                let alpha = 0.22
                box.smoothedBytesPerSecond = alpha * instBps + (1 - alpha) * box.smoothedBytesPerSecond
            }
        }

        let fraction: Double
        if expectedTotal > 0 {
            fraction = min(1, max(0, Double(totalBytesWritten) / Double(expectedTotal)))
        } else {
            fraction = totalBytesWritten > 0 ? 0.02 : 0
        }

        let eta: TimeInterval?
        if box.smoothedBytesPerSecond > 100, expectedTotal > totalBytesWritten {
            eta = Double(expectedTotal - totalBytesWritten) / box.smoothedBytesPerSecond
        } else {
            eta = nil
        }

        let modelId = box.modelId
        let snap = DownloadProgressSnapshot(
            fractionComplete: fraction,
            bytesWritten: totalBytesWritten,
            expectedTotalBytes: expectedTotal,
            instantaneousBytesPerSecond: instBps,
            smoothedBytesPerSecond: max(0, box.smoothedBytesPerSecond),
            estimatedSecondsRemaining: eta
        )
        stateLock.unlock()

        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .localModelDownloadProgress,
                object: nil,
                userInfo: ["modelId": modelId.rawValue, "snapshot": snap]
            )
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        stateLock.lock()
        guard let box = pendingByTaskID[downloadTask.taskIdentifier] else {
            stateLock.unlock()
            return
        }

        let modelId = box.modelId

        func finishLockAndNotify(success: Bool, errorDescription: String?) {
            box.didDeliverCompletion = true
            stateLock.unlock()
            let mid = modelId.rawValue
            DispatchQueue.main.async {
                var info: [String: Any] = ["modelId": mid, "success": success]
                if let errorDescription {
                    info["errorDescription"] = errorDescription
                }
                NotificationCenter.default.post(name: .localModelDownloadCompleted, object: nil, userInfo: info)
            }
        }

        if let http = downloadTask.response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            finishLockAndNotify(
                success: false,
                errorDescription: HuggingFaceDownloadError.httpStatus(http.statusCode).localizedDescription
            )
            return
        }

        let fm = FileManager.default
        guard let attrs = try? fm.attributesOfItem(atPath: location.path),
              let size = attrs[.size] as? NSNumber else {
            finishLockAndNotify(success: false, errorDescription: HuggingFaceDownloadError.invalidDownloadPayload.localizedDescription)
            return
        }
        let byteCount = size.int64Value

        if byteCount < 50_000,
           let head = try? Data(contentsOf: location, options: [.mappedIfSafe]),
           let text = String(data: head.prefix(400), encoding: .utf8) {
            if text.contains("git-lfs.github.com") || text.hasPrefix("version https://git-lfs") {
                finishLockAndNotify(success: false, errorDescription: HuggingFaceDownloadError.receivedLFSPointerFile.localizedDescription)
                return
            }
            if text.contains("<!DOCTYPE html") || text.contains("<html") {
                finishLockAndNotify(success: false, errorDescription: HuggingFaceDownloadError.invalidDownloadPayload.localizedDescription)
                return
            }
        }

        let dest = box.destinationURL
        do {
            if fm.fileExists(atPath: dest.path) {
                try fm.removeItem(at: dest)
            }
            try fm.moveItem(at: location, to: dest)
            finishLockAndNotify(success: true, errorDescription: nil)
        } catch {
            finishLockAndNotify(success: false, errorDescription: error.localizedDescription)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        stateLock.lock()
        guard let downloadTask = task as? URLSessionDownloadTask,
              let box = pendingByTaskID[downloadTask.taskIdentifier] else {
            stateLock.unlock()
            return
        }

        let modelId = box.modelId
        defer {
            pendingByTaskID.removeValue(forKey: downloadTask.taskIdentifier)
            taskByModel[modelId] = nil
            stateLock.unlock()
        }

        if let error {
            let ns = error as NSError
            if ns.code == NSURLErrorCancelled {
                if !box.didDeliverCompletion {
                    box.didDeliverCompletion = true
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(
                            name: .localModelDownloadCompleted,
                            object: nil,
                            userInfo: [
                                "modelId": modelId.rawValue,
                                "success": false,
                                "cancelled": true,
                                "errorDescription": ns.localizedDescription
                            ]
                        )
                    }
                }
                return
            }
            if box.didDeliverCompletion { return }
            box.didDeliverCompletion = true
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .localModelDownloadCompleted,
                    object: nil,
                    userInfo: ["modelId": modelId.rawValue, "success": false, "errorDescription": error.localizedDescription]
                )
            }
            return
        }

        if box.didDeliverCompletion { return }

        if let http = downloadTask.response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            box.didDeliverCompletion = true
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .localModelDownloadCompleted,
                    object: nil,
                    userInfo: [
                        "modelId": modelId.rawValue,
                        "success": false,
                        "errorDescription": HuggingFaceDownloadError.httpStatus(http.statusCode).localizedDescription
                    ]
                )
            }
        }
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        stateLock.lock()
        let handler = backgroundEventsCompletion
        backgroundEventsCompletion = nil
        stateLock.unlock()
        DispatchQueue.main.async {
            handler?()
        }
    }
}
