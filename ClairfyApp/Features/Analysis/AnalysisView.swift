//
//  AnalysisView.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 09/10/25.
//

import SwiftUI

struct AnalysisView: View {
    @State var viewModel: AnalysisViewModelProtocol
    @State private var showErrorAlert = false
    @State private var showRegenerateConfirmation = false
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    VStack(spacing: 16) {
                        // Segmented Control
                        Picker("Tipo", selection: $viewModel.selectedSegment) {
                            Text("Médicos").tag(0)
                            Text("Pacientes").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding(.top, 8)
                        
                        // Card de áudio
                        if let audio = viewModel.consultation.audio {
                            AudioCard(
                                title: viewModel.consultation.title,
                                description: viewModel.consultation.date.formatted(date: .abbreviated, time: .shortened),
                                totalTime: "00:00", // Pode ser calculado depois
                                isPlaying: false,
                                audio: audio
                            )
                        }
                        
                        // Cards de informação baseado no segmento selecionado
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
                            // Mostrar placeholder quando não há análise
                            VStack(spacing: 12) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 60))
                                    .foregroundColor(.secondary)
                                
                                Text("Nenhuma análise gerada")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Clique no botão abaixo para gerar a análise desta consulta")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                            .padding(.vertical, 60)
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                Button {
                    // Se já existe análise, mostra confirmação
                    if viewModel.consultation.transcription != nil {
                        showRegenerateConfirmation = true
                    } else {
                        // Primeira análise, gera direto
                        Task {
                            await viewModel.generateAnalysis()
                            if viewModel.errorMessage != nil {
                                showErrorAlert = true
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
            
            // Loading overlay
            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    
                    Text("Gerando análise...")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Isso pode levar alguns minutos")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(40)
                .background(Color(.systemGray6).opacity(0.95))
                .cornerRadius(20)
            }
        }
        .padding(.horizontal, 16)
        .background(Color(.secondarySystemBackground))
        .navigationTitle("Análise")
        .navigationBarTitleDisplayMode(.large)
        .alert("Erro", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "Erro desconhecido")
        }
        .alert("Gerar Nova Análise?", isPresented: $showRegenerateConfirmation) {
            Button("Cancelar", role: .cancel) { }
            Button("Gerar", role: .destructive) {
                Task {
                    await viewModel.generateAnalysis()
                    if viewModel.errorMessage != nil {
                        showErrorAlert = true
                    }
                }
            }
        } message: {
            Text("Esta ação irá substituir a análise atual. Deseja continuar?")
        }
    }
}
