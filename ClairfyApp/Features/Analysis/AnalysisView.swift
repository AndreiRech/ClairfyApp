//
//  AnalysisView.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import SwiftUI

struct AnalysisView: View {
    @State var viewModel: AnalysisViewModelProtocol
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Segmental controll com [Medicos, Pacientes]
                    
                    // Card de audio (AudioCard)
                }
                
                // Espaco para colocar as informacoes (serao dois cards InfoCard)
                //  Se estiver na parte de medicos, mostrar os 2 cards com as informacoes referentes ao medico (Resumo e palavras chaves)
                //  Se estiver na parte de pacientes, mostrar os 2 cards com as informacoes referentes ao paciente (Resumo simplificado e pontos de açao)
            }
            
            Button {
                // funcao para gerar uma analise
            } label: {
                Text("Gerar Análise")
                    .font(.title)
                    .foregroundColor(.clairBlue)
                    .padding(.vertical, 10)
                    .glassEffect()
            }
            .padding(.bottom, 10)
        }
        .padding(.horizontal, 16)
        .background(Color(.secondarySystemBackground))
        .navigationTitle("Análise")
        .navigationBarTitleDisplayMode(.large)
    }
}
