//
//  LocalModelStorage.swift
//  ClairfyApp
//

import Foundation

enum LocalModelStorage {
    private static let folderName = "ClairfyModels"

    static var rootDirectory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent(folderName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    static func fileURL(for model: LocalModelBundleID) -> URL {
        rootDirectory.appendingPathComponent(model.storedFileName, isDirectory: false)
    }

    static func freeDiskBytes() -> Int64? {
        let values = try? rootDirectory.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
        if let n = values?.volumeAvailableCapacityForImportantUsage {
            return Int64(n)
        }
        return nil
    }
}
