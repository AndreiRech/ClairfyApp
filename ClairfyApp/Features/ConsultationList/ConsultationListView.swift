//
//  ConsultationListView.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

import SwiftUI

struct ConsultationListView: View {
    @State var viewModel: ConsultationListViewModelProtocol
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.filteredConsultations.isEmpty {
                    Spacer()
                    
                    EmptyState()
                } else {
                    List(viewModel.filteredConsultations) { consultation in
                        ListComponent(title: consultation.title, date: consultation.date)
                            .listRowInsets(EdgeInsets())
                            .background(Color(.tertiarySystemBackground))
                            .swipeActions(edge: .trailing) {
                                Button("Excluir", systemImage: "trash", role: .destructive) {
                                    viewModel.deleteConsultation(by: consultation.id)
                                }
                            }
                            .onTapGesture {
                                viewModel.selectedConsultation = consultation
                            }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.insetGrouped)
                    .searchable(text: $viewModel.searchText, prompt: "Filtrar")
                }
                
                Spacer()
                
                Button {
                    viewModel.shouldRecordAudio = true
                } label: {
                    HStack(alignment: .center, spacing: 0) {
                        Image(systemName: "circle.fill")
                            .foregroundStyle(Color(.label))
                        
                        Text("REC")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(.label))
                    }
                }
                .frame(width: 94, height: 94)
                .glassEffect()
                .padding(.bottom, 16)
            }
            .background(Color(.secondarySystemBackground))
            .navigationTitle("Consultas")
            .navigationDestination(item: $viewModel.selectedConsultation) { consultation in
                // navegar para tela de visualizar consulta
            }
            .navigationDestination(isPresented: $viewModel.shouldRecordAudio) {
                VoiceRecordingView(viewModel: VoiceRecordingViewModel(
                    repository: VoiceRecordingRepository(
                        audioService: AudioService(),
                        recordingService: RecordingService(), consultationSerevice: ConsultationService())))
            }
        }
        .onAppear {
            viewModel.fetchConsultations()
        }
    }
}
