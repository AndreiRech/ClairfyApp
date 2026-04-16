//
//  ModelDownloadLiveAttributes.swift
//  ClairfyApp
//
//  Deve ser **idêntico** ao ficheiro homónimo na extensão `ClairfyLiveActivityExtension`
//  (requisito ActivityKit).
//

import ActivityKit
import Foundation

struct ModelDownloadLiveAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Sendable {
        var phaseLabel: String
        /// 0...1
        var progress: Double
        var detail: String
    }

    var modelDisplayName: String
}
