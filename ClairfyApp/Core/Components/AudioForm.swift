//
//  AudioForm.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import SwiftUI

struct AudioForm: View {
    let samples: [Float]
    let maxSamples = 85

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                let displaySamples = Array(samples.suffix(maxSamples))
                
                ForEach(0..<maxSamples, id: \.self) { index in
                    let sampleIndex = displaySamples.count - maxSamples + index
                    let sample: Float = sampleIndex >= 0 ? displaySamples[sampleIndex] : 0
                    
                    let barHeight = CGFloat(max(0.05, sample)) * geometry.size.height * 2
                    
                    Capsule()
                        .fill(.clairBlue)
                        .frame(width: 2, height: barHeight)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
    }
}
