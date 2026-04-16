//
//  ModelManagementView.swift
//  ClairfyApp
//

import SwiftUI

struct ModelManagementView: View {
    @State private var viewModel = LocalModelsViewModel()

    var body: some View {
        List {
            if let banner = viewModel.bannerMessage {
                Section {
                    Text(banner)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Text("Os pesos são descarregados para Application Support / ClairfyModels. Podem exigir aceite de licença no Hugging Face e ligação Wi‑Fi estável.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            ForEach(viewModel.rows) { row in
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(row.displayName)
                                .font(.headline)
                            Spacer()
                            statusBadge(for: row.phase)
                        }
                        Text("Tamanho esperado: \(row.expectedSizeDescription)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        switch row.phase {
                        case .downloading(let p):
                            ProgressView(value: p, total: 1.0)
                                .progressViewStyle(.linear)
                        default:
                            EmptyView()
                        }

                        HStack(spacing: 12) {
                            switch row.phase {
                            case .notInstalled:
                                Button("Descarregar") {
                                    viewModel.startDownload(for: row.id)
                                }
                                .buttonStyle(.borderedProminent)
                            case .failed:
                                Button("Descarregar de novo") {
                                    viewModel.startDownload(for: row.id)
                                }
                                .buttonStyle(.borderedProminent)
                                Button("Eliminar", role: .destructive) {
                                    viewModel.deleteModel(for: row.id)
                                }
                                .buttonStyle(.bordered)
                            case .downloading:
                                Button("Cancelar") {
                                    viewModel.cancelDownload(for: row.id)
                                }
                                .buttonStyle(.bordered)
                            case .verifying:
                                EmptyView()
                            case .ready:
                                Button("Reverificar") {
                                    viewModel.verifyOnly(for: row.id)
                                }
                                .buttonStyle(.bordered)
                                Button("Testar inferência") {
                                    Task { await viewModel.runSmokeTest(for: row.id) }
                                }
                                .buttonStyle(.bordered)
                                Button("Eliminar", role: .destructive) {
                                    viewModel.deleteModel(for: row.id)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
            }

            if viewModel.lastTestSummary != nil || viewModel.lastTestActions != nil {
                Section("Último teste") {
                    if let s = viewModel.lastTestSummary {
                        Text("Resumo").font(.caption).foregroundStyle(.secondary)
                        Text(s)
                    }
                    if let a = viewModel.lastTestActions {
                        Text("Pontos de ação").font(.caption).foregroundStyle(.secondary)
                        Text(a)
                    }
                }
            }
        }
        .navigationTitle("Modelos locais")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            viewModel.rebuildRowsFromDisk()
        }
    }

    @ViewBuilder
    private func statusBadge(for phase: LocalModelInstallationDisplayPhase) -> some View {
        switch phase {
        case .notInstalled:
            Text("Não instalado").font(.caption).padding(6).background(.quaternary, in: Capsule())
        case .downloading:
            Text("A descarregar").font(.caption).padding(6).background(.yellow.opacity(0.35), in: Capsule())
        case .verifying:
            Text("A verificar").font(.caption).padding(6).background(.orange.opacity(0.35), in: Capsule())
        case .ready:
            Text("Pronto").font(.caption).padding(6).background(.green.opacity(0.35), in: Capsule())
        case .failed(let msg):
            Text("Erro")
                .font(.caption)
                .padding(6)
                .background(.red.opacity(0.25), in: Capsule())
                .help(msg)
        }
    }
}

#Preview {
    NavigationStack {
        ModelManagementView()
    }
}
