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
        ZStack {
            VStack {
                ScrollView {
                    VStack(spacing: 16) {
                        Picker("Tipo", selection: $viewModel.selectedSegment) {
                            Text("Médicos").tag(0)
                            Text("Pacientes").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding(.top, 8)
                        
                        if let audio = viewModel.consultation.audio {
                            AudioCard(
                                title: viewModel.consultation.title,
                                description: viewModel.consultation.date.formatted(date: .abbreviated, time: .shortened),
                                totalTime: "00:00", // TODO: Calcular tamanho do audio
                                isPlaying: false,
                                audio: audio
                            )
                        }
                        
                        if viewModel.isLoading {
                            Color.black.opacity(0.4)
                                .ignoresSafeArea()
                            
                            VStack(spacing: 20) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.primary)
                                
                                Text("Gerando análise...")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Isso pode levar alguns minutos")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(40)
                        } else {
                            if let transcription = viewModel.consultation.transcription {
                                if viewModel.selectedSegment == 0 {
                                    // Médicos: Resumo e Palavras-chave
                                    InfoCard(
                                        title: "Resumo Médico",
                                        description: transcription.summary.isEmpty ? "Nenhum resumo disponível" : transcription.summary,
                                        onEditTap: {
                                            // TODO: Implementar edição
                                        },
                                        onCopyTap: {
                                            UIPasteboard.general.string = transcription.summary
                                        }
                                    )
                                    
                                    InfoCard(
                                        title: "Palavras-chave",
                                        description: transcription.keyWords.isEmpty ? "Nenhuma palavra-chave disponível" : transcription.keyWords,
                                        onEditTap: {
                                            // TODO: Implementar edição
                                        },
                                        onCopyTap: {
                                            UIPasteboard.general.string = transcription.keyWords
                                        }
                                    )
                                } else {
                                    // Pacientes: Resumo Didático e Pontos de Ação
                                    InfoCard(
                                        title: "Resumo Simplificado",
                                        description: transcription.didactic.isEmpty ? "Nenhum resumo simplificado disponível" : transcription.didactic,
                                        onEditTap: {
                                            // TODO: Implementar edição
                                        },
                                        onCopyTap: {
                                            UIPasteboard.general.string = transcription.didactic
                                        }
                                    )
                                    
                                    InfoCard(
                                        title: "Pontos de Ação",
                                        description: transcription.actionPoints.isEmpty ? "Nenhum ponto de ação disponível" : transcription.actionPoints,
                                        onEditTap: {
                                            // TODO: Implementar edição
                                        },
                                        onCopyTap: {
                                            UIPasteboard.general.string = transcription.actionPoints
                                        }
                                    )
                                }
                            } else {
                                Spacer()

                                EmptyState(icon: "doc.text.magnifyingglass", title: "Nenhuma análise gerada", description: "Clique no botão abaixo para gerar a análise da consulta")
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                Button {
                    if viewModel.consultation.transcription != nil {
                        viewModel.showRegenerateConfirmation = true
                    } else {
                        Task {
                            await viewModel.generateAnalysis()
                            if viewModel.errorMessage != nil {
                                viewModel.showErrorAlert = true
                            }
                        }
                    }
                } label: {
                    let buttonText = viewModel.isLoading ? "Gerando..." : 
                                   (viewModel.consultation.transcription != nil ? "Gerar Nova Análise" : "Gerar Análise")
                    Text(buttonText)
                        .font(.title)
                        .foregroundColor(viewModel.isLoading ? .gray : .clairBlue)
                        .padding(.vertical, 10)
                        .glassEffect()
                }
                .disabled(viewModel.isLoading)
                .padding(.bottom, 10)
            }
        }
        .padding(.horizontal, 16)
        .background(Color(.secondarySystemBackground))
        .navigationTitle("Análise")
        .navigationBarTitleDisplayMode(.large)
        .alert("Erro", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "Erro desconhecido")
        }
        .alert("Gerar Nova Análise?", isPresented: $viewModel.showRegenerateConfirmation) {
            Button("Cancelar", role: .cancel) { }
            Button("Gerar", role: .destructive) {
                Task {
                    await viewModel.generateAnalysis()
                    if viewModel.errorMessage != nil {
                        viewModel.showErrorAlert = true
                    }
                }
            }
        } message: {
            Text("Esta ação irá substituir a análise atual. Deseja continuar?")
        }
    }
}
