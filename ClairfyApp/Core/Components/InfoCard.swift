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
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                Spacer()
                
                Button(action: onEditTap) {
                    Label("Editar", systemImage: "pencil")
                        .font(.subheadline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(.clairBlue)
                        .foregroundStyle(Color(.tertiarySystemBackground))
                        .clipShape(Capsule())
                }
                
                Button(action: onCopyTap) {
                    Label("Compartilhar", systemImage: "doc.on.doc")
                        .font(.subheadline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 5)
                        .background(.clairBlue)
                        .foregroundStyle(Color(.tertiarySystemBackground))
                        .clipShape(Capsule())
                }
            }
            
        }
        .padding(24)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .background(Color(.tertiarySystemBackground))
    }
}
