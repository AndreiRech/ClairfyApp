//
//  ClairfyLiveActivityBundle.swift
//  ClairfyLiveActivityExtension
//
//  Live Activity UI: Lock Screen + Dynamic Island (compact / expanded / minimal).
//

import ActivityKit
import SwiftUI
import WidgetKit

@main
struct ClairfyLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        ModelDownloadLiveActivityWidget()
    }
}

struct ModelDownloadLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ModelDownloadLiveAttributes.self) { context in
            VStack(alignment: .leading, spacing: 6) {
                Text(context.attributes.modelDisplayName)
                    .font(.headline)
                ProgressView(value: context.state.progress) {
                    Text(context.state.phaseLabel)
                        .font(.subheadline)
                }
                .tint(.accentColor)
                Text(context.state.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.15))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.modelDisplayName)
                            .font(.caption.weight(.semibold))
                            .lineLimit(1)
                        Text(context.state.phaseLabel)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(Int((context.state.progress * 100).rounded()))%")
                        .font(.caption.monospacedDigit().weight(.semibold))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        ProgressView(value: context.state.progress)
                            .tint(.accentColor)
                        Text(context.state.detail)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } compactLeading: {
                Image(systemName: "arrow.down.circle.fill")
                    .symbolRenderingMode(.hierarchical)
            } compactTrailing: {
                Text("\(Int((context.state.progress * 100).rounded()))%")
                    .font(.caption2.monospacedDigit())
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            } minimal: {
                ProgressView(value: context.state.progress)
                    .tint(.accentColor)
            }
        }
    }
}
