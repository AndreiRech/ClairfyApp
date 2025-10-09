//
//  TimeIntervalExtension.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import Foundation

extension TimeInterval {
    func formatTime() -> String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
