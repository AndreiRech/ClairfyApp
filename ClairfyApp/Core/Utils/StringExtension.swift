//
//  StringExtension.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import SwiftUI

extension String {
    func highlight(substring: String, with color: Color) -> AttributedString {
        var attributedString = AttributedString(self)
        
        if let range = attributedString.range(of: substring, options: .caseInsensitive) {
            attributedString[range].foregroundColor = color
        }
        
        return attributedString
    }
}
