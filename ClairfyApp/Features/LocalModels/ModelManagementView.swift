//
//  ModelManagementView.swift
//  ClairfyApp
//

import SwiftUI
import UIKit

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
                Text("Os ficheiros (GGUF + mmproj para áudio no Gemma) vão para Application Support / ClairfyModels. O download corre em segundo plano; o estado actualiza-se ao voltar à app.")
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
                        case .downloading(let snap):
                            VStack(alignment: .leading, spacing: 8) {
                                if let phase = snap.phaseLabel {
                                    Text(phase)
                                        .font(.caption2.weight(.medium))
                                        .foregroundStyle(.secondary)
                                }
                                ProgressView(value: snap.fractionComplete, total: 1.0)
                                    .progressViewStyle(.linear)
                                Text("\(snap.formattedDownloaded()) de \(snap.formattedTotal())")
                                    .font(.caption.monospacedDigit())
                                    .foregroundStyle(.primary)
                                HStack {
                                    Label(snap.speedDescription(), systemImage: "arrow.down.circle")
                                    Spacer()
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                Text(snap.etaDescription())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        case .verifying:
                            HStack(spacing: 8) {
                                ProgressView()
                                    .scaleEffect(0.85)
                                Text("A verificar integridade do ficheiro…")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        default:
                            EmptyView()
                        }

                        HStack(spacing: 10) {
                            switch row.phase {
                            case .notInstalled:
                                Button("Descarregar") {
                                    viewModel.startDownload(for: row.id)
                                }
                                .buttonStyle(LocalModelPrimaryButtonStyle())
                            case .failed:
                                Button("Descarregar de novo") {
                                    viewModel.startDownload(for: row.id)
                                }
                                .buttonStyle(LocalModelPrimaryButtonStyle())
                                Button("Eliminar") {
                                    viewModel.deleteModel(for: row.id)
                                }
                                .buttonStyle(LocalModelSecondaryOutlineButtonStyle(isDestructive: true))
                            case .downloading:
                                Button("Cancelar") {
                                    viewModel.cancelDownload(for: row.id)
                                }
                                .buttonStyle(LocalModelSecondaryOutlineButtonStyle(isDestructive: false))
                            case .verifying:
                                EmptyView()
                            case .ready:
                                Button("Reverificar") {
                                    viewModel.verifyOnly(for: row.id)
                                }
                                .buttonStyle(LocalModelSecondaryOutlineButtonStyle(isDestructive: false))
                                Button("Testar inferência") {
                                    Task { await viewModel.runSmokeTest(for: row.id) }
                                }
                                .buttonStyle(LocalModelSecondaryOutlineButtonStyle(isDestructive: false))
                                Button("Eliminar") {
                                    viewModel.deleteModel(for: row.id)
                                }
                                .buttonStyle(LocalModelSecondaryOutlineButtonStyle(isDestructive: true))
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
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
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

// MARK: - Estilos de botão (List + AccentColor legado corrigido no asset; estes garantem contraste)

private struct LocalModelPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Color(.clairBlue).opacity(configuration.isPressed ? 0.85 : 1.0),
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
    }
}

private struct LocalModelSecondaryOutlineButtonStyle: ButtonStyle {
    var isDestructive: Bool

    func makeBody(configuration: Configuration) -> some View {
        let stroke = isDestructive ? Color.red : Color(.clairBlue)
        let fg = isDestructive ? Color.red : Color(.clairBlue)
        return configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundStyle(fg)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(stroke.opacity(configuration.isPressed ? 0.5 : 1.0), lineWidth: 1.5)
            )
    }
}
