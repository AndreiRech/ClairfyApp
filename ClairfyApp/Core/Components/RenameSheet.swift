//
//  RenameSheet.swift
//  ClairfyApp
//
//  Created by Eduardo Ferrari on 09/10/25.
//

import SwiftUI

struct RenameSheet: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    @Binding var title: String   
    var onSave: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                HStack(spacing: 8) {
                    Text("Título")
                        .font(.system(size: 17))
                        .foregroundColor(.primary)
                    
                    TextField("Digite o título", text: $title)
                        .font(.system(size: 17))
                        .foregroundColor(.primary)
                        .focused($isTextFieldFocused)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .padding(.horizontal, 20)
                .padding(.top, 32)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemGray6))
            .navigationTitle("Novo Áudio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    isTextFieldFocused = true
                }
            }
        }
    }
}
