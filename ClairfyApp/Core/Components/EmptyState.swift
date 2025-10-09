//
//  EmptyState.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import SwiftUI

struct EmptyState: View {
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: "microphone.fill")
                .font(.title)
                .foregroundStyle(Color(.label))
            
            Text("Ainda não há áudios.")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(.label))
            
            Text("Construa o histórico do paciente desde a primeira conversa.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(.label))
        }
        .frame(maxWidth: .infinity)
    }
}
