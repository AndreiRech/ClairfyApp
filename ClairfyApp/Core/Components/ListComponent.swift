//
//  ListComponent.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import SwiftUI

struct ListComponent: View {
    let title: String
    let date: Date
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .foregroundStyle(Color(.label))
                
                Text(date.formatDate())
                    .font(.subheadline)
                    .foregroundStyle(Color(.secondaryLabel))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.clairBlue)
                .frame(width: 12, height: 16)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
