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
    @State private var title: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // Campo de título
                HStack(spacing: 8) {
                    Text("Título")
                        .font(.system(size: 17))
                        .foregroundColor(.primary)
                    
                    TextField("Digite o título", text: $title)
                        .font(.system(size: 17))
                        .focused($isTextFieldFocused)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(Color.white)
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
                // Botão de fechar
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                
                // Botão de confirmar
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        //ação do botão aqui
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

#Preview {
    RenameSheet()
}
