//
//  ViewExtension.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import SwiftUI

extension View {
    func glassEffect() -> some View {
        self
            .background(.ultraThinMaterial)
            .cornerRadius(12)
    }
}

