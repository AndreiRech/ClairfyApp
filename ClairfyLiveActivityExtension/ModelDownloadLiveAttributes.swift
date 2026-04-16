//
//  ModelDownloadLiveAttributes.swift
//  ClairfyLiveActivityExtension
//
//  Deve ser **idêntico** a `ClairfyApp/Services/LocalAI/ModelDownloadLiveAttributes.swift`
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
