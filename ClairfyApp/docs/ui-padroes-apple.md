# UI e padrões Apple (HIG)

Este documento liga o código do Clairfy a **boas práticas** alinhadas às **Human Interface Guidelines** da Apple e APIs de sistema. Não substitui a documentação oficial da Apple.

## Fonte no repositório

| Padrão | Onde aparece |
|--------|----------------|
| `NavigationStack` | [`ConsultationListView`](../ClairfyApp/Features/ConsultationList/ConsultationListView.swift) |
| `searchable` | Lista de consultas (filtro por título) |
| `listStyle`, `scrollContentBackground` | Lista de consultas |
| `swipeActions` | Eliminar consulta |
| Cores adaptativas | `Color(.label)`, `Color(.secondaryLabel)`, `Color(.secondarySystemBackground)`, `Color(.tertiarySystemBackground)` em lista, gravação e empty state |
| SF Symbols | Ex.: `circle.fill` no botão REC; ícones no splash em [`SplashScreenView`](../ClairfyApp/Features/SplashScreen/SplashScreenView.swift) |
| `TabView` + estilo página | [`OnboardingView`](../ClairfyApp/Features/Onboarding/OnboardingView.swift) |

## Princípios HIG relevantes

1. **Legibilidade** — Uso de `.primary` e cores de etiqueta do sistema no onboarding para texto longo sobre fundos de sistema.
2. **Consistência** — Navegação e lista seguem padrões iOS modernos (`NavigationStack`, grupos inset).
3. **Feedback** — Estados de gravação/pausa e alertas de duração mínima no fluxo de voz.

## Acessibilidade

- **Dinâmico:** Cores de sistema (`label`, `secondaryLabel`, fundos) ajudam **Dark Mode** e **Increase Contrast** quando usadas em conjunto com conteúdo semântico.
- **A validar:** `accessibilityLabel` / `accessibilityHint` em botões críticos (REC, eliminar), **VoiceOver** em lista e gravação, **Dynamic Type** em textos longos do onboarding — não há inventário completo no código; recomenda-se auditoria dedicada antes de release.

## Áudio em segundo plano

[`Info.plist`](../ClairfyApp/Info.plist) declara `UIBackgroundModes` com `audio`, coerente com gravação/reprodução prolongada conforme requisitos do projeto no Xcode.

## Fora do escopo do código

- Diretrizes de revisão da App Store (ver [app-store-connect.md](app-store-connect.md)).
- Certificações de acessibilidade formal (VPAT, etc.).
