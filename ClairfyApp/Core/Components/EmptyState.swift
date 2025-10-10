//
//  EmptyState.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import SwiftUI

struct EmptyState: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(Color(.label))
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(.label))
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(.label))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}
