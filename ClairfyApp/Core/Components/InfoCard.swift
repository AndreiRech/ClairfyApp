//
//  InfoCard.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import SwiftUI

struct InfoCard: View {
    let title: String
    let description: String
    
    var onEditTap: () -> Void
    var onCopyTap: () -> Void
    
    var body: some View { 
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 8) {
                Spacer()
                
                Button(action: onEditTap) {
                    Label("Editar", systemImage: "pencil")
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .foregroundStyle(Color(.label))
                        .glassEffect(.regular.interactive())
                }
                
                Button(action: onCopyTap) {
                    Label("Compartilhar", systemImage: "square.and.arrow.up.fill")
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .foregroundStyle(Color(.label))
                        .glassEffect(.regular.interactive())
                }
            }
        }
        .padding(.leading, 24)
        .padding(.trailing, 16)
        .padding(.top, 24)
        .padding(.bottom, 16)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))

    }
}

#Preview("InfoCard Preview") {
    InfoCard(
        title: "Título de Exemplo",
        description: "Esta é uma descrição de exemplo para demonstrar a aparência do InfoCard em diferentes tamanhos e temas.",
        onEditTap: {},
        onCopyTap: {}
    )
    .padding()
    .background(Color(.systemBackground))
}
