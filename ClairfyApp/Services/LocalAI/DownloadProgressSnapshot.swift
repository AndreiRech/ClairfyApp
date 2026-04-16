//
//  DownloadProgressSnapshot.swift
//  ClairfyApp
//

import Foundation

/// Estado de UI para um download activo (foreground ou background).
struct DownloadProgressSnapshot: Equatable, Sendable {
    var fractionComplete: Double
    var bytesWritten: Int64
    /// Total esperado para a barra (Content-Length ou tamanho do catálogo).
    var expectedTotalBytes: Int64
    /// Velocidade instantânea (último intervalo).
    var instantaneousBytesPerSecond: Double
    /// EMA para exibição estável.
    var smoothedBytesPerSecond: Double
    var estimatedSecondsRemaining: TimeInterval?

    private static let byteFormatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.allowedUnits = [.useGB, .useMB, .useKB]
        f.countStyle = .file
        f.includesUnit = true
        f.isAdaptive = true
        return f
    }()

    func formattedDownloaded(locale: Locale = Locale(identifier: "pt_BR")) -> String {
        Self.byteFormatter.string(fromByteCount: bytesWritten)
    }

    func formattedTotal(locale: Locale = Locale(identifier: "pt_BR")) -> String {
        Self.byteFormatter.string(fromByteCount: max(expectedTotalBytes, 1))
    }

    func speedDescription(locale: Locale = Locale(identifier: "pt_BR")) -> String {
        guard smoothedBytesPerSecond > 1 else { return "A calcular velocidade…" }
        let mbps = smoothedBytesPerSecond / (1024 * 1024)
        let nf = NumberFormatter()
        nf.locale = locale
        nf.maximumFractionDigits = 1
        nf.minimumFractionDigits = 1
        if mbps >= 0.05 {
            let n = nf.string(from: NSNumber(value: mbps)) ?? String(format: "%.1f", mbps)
            return "\(n) MB/s"
        }
        let kbps = smoothedBytesPerSecond / 1024
        let n = nf.string(from: NSNumber(value: kbps)) ?? String(format: "%.0f", kbps)
        return "\(n) KB/s"
    }

    func etaDescription(locale: Locale = Locale(identifier: "pt_BR")) -> String {
        guard let eta = estimatedSecondsRemaining, eta.isFinite, eta > 0 else {
            return expectedTotalBytes > bytesWritten ? "A estimar tempo…" : "—"
        }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = eta >= 3600 ? [.hour, .minute] : [.minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        formatter.calendar = calendar
        if let s = formatter.string(from: eta) {
            return "Tempo restante estimado: ~\(s)"
        }
        return "Tempo restante estimado: ~\(Int(eta)) s"
    }

    static func == (lhs: DownloadProgressSnapshot, rhs: DownloadProgressSnapshot) -> Bool {
        lhs.bytesWritten == rhs.bytesWritten
            && abs(lhs.fractionComplete - rhs.fractionComplete) < 0.0001
            && abs(lhs.smoothedBytesPerSecond - rhs.smoothedBytesPerSecond) < 128
    }
}

extension Notification.Name {
    /// `userInfo`: `"modelId"` (String rawValue), `"snapshot"` (DownloadProgressSnapshot)
    static let localModelDownloadProgress = Notification.Name("com.clairfy.localModelDownloadProgress")
    /// `userInfo`: `"modelId"` (String), `"success"` (Bool), `"errorDescription"` (String?, se falhou)
    static let localModelDownloadCompleted = Notification.Name("com.clairfy.localModelDownloadCompleted")
}
