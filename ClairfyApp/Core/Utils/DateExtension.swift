//
//  DateExtension.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import Foundation

extension Date {
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.timeZone = TimeZone.current
        
        return formatter.string(from: self)
    }
}
