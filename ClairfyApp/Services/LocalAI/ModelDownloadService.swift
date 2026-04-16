//
//  ModelDownloadService.swift
//  ClairfyApp
//

import Foundation

protocol ModelDownloadServing: AnyObject {
    func cancelDownload(for model: LocalModelBundleID)
    func download(
        descriptor: LocalModelDescriptor,
        destinationURL: URL,
        onProgress: @escaping @Sendable (Double) -> Void,
        onComplete: @escaping @Sendable (Result<Void, Error>) -> Void
    )
}

final class ModelDownloadService: NSObject, ModelDownloadServing, URLSessionDownloadDelegate {
    override init() {
        super.init()
    }

    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60 * 30
        configuration.timeoutIntervalForResource = 60 * 60 * 24
        return URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
    }()

    private struct Pending {
        let destinationURL: URL
        let onProgress: (Double) -> Void
        let onComplete: (Result<Void, Error>) -> Void
        var didFinishToURL = false
    }

    private var pendingByTaskID: [Int: (model: LocalModelBundleID, pending: Pending)] = [:]
    private var taskByModel: [LocalModelBundleID: URLSessionDownloadTask] = [:]

    func cancelDownload(for model: LocalModelBundleID) {
        taskByModel[model]?.cancel()
        taskByModel[model] = nil
    }

    func download(
        descriptor: LocalModelDescriptor,
        destinationURL: URL,
        onProgress: @escaping @Sendable (Double) -> Void,
        onComplete: @escaping @Sendable (Result<Void, Error>) -> Void
    ) {
        cancelDownload(for: descriptor.id)

        let task = session.downloadTask(with: descriptor.downloadURL)
        let pending = Pending(
            destinationURL: destinationURL,
            onProgress: onProgress,
            onComplete: onComplete
        )
        pendingByTaskID[task.taskIdentifier] = (descriptor.id, pending)
        taskByModel[descriptor.id] = task
        task.resume()
    }

    // MARK: URLSessionDownloadDelegate

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard var entry = pendingByTaskID[downloadTask.taskIdentifier] else { return }
        let p: Double
        if totalBytesExpectedToWrite > 0 {
            p = min(1.0, max(0, Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)))
        } else {
            p = totalBytesWritten > 0 ? 0.02 : 0
        }
        entry.pending.onProgress(p)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard var entry = pendingByTaskID[downloadTask.taskIdentifier] else { return }
        entry.pending.didFinishToURL = true
        pendingByTaskID[downloadTask.taskIdentifier] = entry

        let dest = entry.pending.destinationURL
        let fm = FileManager.default
        do {
            if fm.fileExists(atPath: dest.path) {
                try fm.removeItem(at: dest)
            }
            try fm.moveItem(at: location, to: dest)
            entry.pending.onComplete(.success(()))
        } catch {
            entry.pending.onComplete(.failure(error))
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let downloadTask = task as? URLSessionDownloadTask,
              var entry = pendingByTaskID[downloadTask.taskIdentifier] else { return }

        defer {
            pendingByTaskID.removeValue(forKey: downloadTask.taskIdentifier)
            taskByModel[entry.model] = nil
        }

        if let error {
            let ns = error as NSError
            if ns.code == NSURLErrorCancelled {
                entry.pending.onComplete(.failure(error))
                return
            }
            if entry.pending.didFinishToURL { return }
            entry.pending.onComplete(.failure(error))
            return
        }

        if entry.pending.didFinishToURL { return }

        if let http = downloadTask.response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            entry.pending.onComplete(.failure(URLError(.badServerResponse)))
        }
    }
}
