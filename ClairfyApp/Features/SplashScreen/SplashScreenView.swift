//
//  SplashScreenView.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import SwiftUI
import Combine

struct SplashScreenView: View {
    @State private var currentSymbolIndex = 0
    
    let symbols = [
        "camera",
        "arrow.trianglehead.2.clockwise.rotate.90.icloud",
        "graph.3d",
        "map",
        "hourglass",
        "exclamationmark.bubble"
    ]
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color(.clairBlue)
                .ignoresSafeArea()
            
            Image(systemName: symbols[currentSymbolIndex])
                .font(.largeTitle)
                .foregroundColor(.white)
                .transition(.scale.combined(with: .opacity))
                .id(currentSymbolIndex)
            
        }
        .onReceive(timer) { _ in
            if currentSymbolIndex < symbols.count - 1 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    currentSymbolIndex += 1
                }
            } else {
                timer.upstream.connect().cancel()
            }
        }
    }
}
