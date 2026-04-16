//
//  LatestRecordingLocator.swift
//  ClairfyApp
//

import Foundation

protocol LatestRecordingLocating: Sendable {
    /// Último ficheiro `.m4a` em Documents por data de modificação (gravador usa esta pasta).
    func latestRecordingURL() -> URL?
}

struct LatestRecordingLocator: LatestRecordingLocating {
    func latestRecordingURL() -> URL? {
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let urls = (try? FileManager.default.contentsOfDirectory(
            at: docs,
            includingPropertiesForKeys: [.contentModificationDateKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        )) ?? []

        var best: (url: URL, date: Date)?
        for url in urls where url.pathExtension.lowercased() == "m4a" {
            guard let values = try? url.resourceValues(forKeys: [.contentModificationDateKey, .isRegularFileKey]),
                  values.isRegularFile == true,
                  let date = values.contentModificationDate else { continue }
            if best == nil || date > best!.date {
                best = (url, date)
            }
        }
        return best?.url
    }
}
