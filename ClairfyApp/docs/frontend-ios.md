# Front-end iOS (SwiftUI)

## Stack de UI

- **SwiftUI** para todas as superfícies.
- **View models** com **`@Observable`** (macro Swift), por exemplo [`ConsultationListViewModel`](../ClairfyApp/Features/ConsultationList/ConsultationListViewModel.swift) e [`VoiceRecordingViewModel`](../ClairfyApp/Features/VoiceRecording/VoiceRecordingViewModel.swift).
- **Navegação** com `NavigationStack` e `navigationDestination`.

## Fonte no repositório

| Feature | Ficheiros principais |
|---------|----------------------|
| Entrada do app | [`ClairfyApp.swift`](../ClairfyApp/App/ClairfyApp.swift) |
| Splash | [`SplashScreenView.swift`](../ClairfyApp/Features/SplashScreen/SplashScreenView.swift) |
| Onboarding | [`OnboardingView.swift`](../ClairfyApp/Features/Onboarding/OnboardingView.swift), [`OnboardingViewModel.swift`](../ClairfyApp/Features/Onboarding/OnboardingViewModel.swift) |
| Lista de consultas | [`ConsultationListView.swift`](../ClairfyApp/Features/ConsultationList/ConsultationListView.swift), [`ConsultationListViewModel.swift`](../ClairfyApp/Features/ConsultationList/ConsultationListViewModel.swift) |
| Gravação | [`VoiceRecordingView.swift`](../ClairfyApp/Features/VoiceRecording/VoiceRecordingView.swift), [`VoiceRecordingViewModel.swift`](../ClairfyApp/Features/VoiceRecording/VoiceRecordingViewModel.swift) |
| Modelos IA locais (POC) | [`ModelManagementView.swift`](../Features/LocalModels/ModelManagementView.swift), [`LocalModelsViewModel.swift`](../Features/LocalModels/LocalModelsViewModel.swift) — entrada na toolbar de consultas; ver [poc-gemma-local.md](poc-gemma-local.md) |

## Fluxo de arranque (`ClairfyApp`)

- `@AppStorage("onboarding")` controla se o onboarding já foi concluído.
- `@State private var isSplashScreenActive` interage com a ordem de apresentação do splash vs. conteúdo principal. **Comportamento atual:** com o valor inicial `true` de `isSplashScreenActive`, a expressão `if !isSplashScreenActive` mostra primeiro o ramo “conteúdo” (onboarding ou lista) e o splash noutro ramo; convém validar em dispositivo se a ordem corresponde ao desejado pelo design.

## Onboarding

- `TabView` com estilo página; dados vêm de [`OnboardingRepository`](../ClairfyApp/Repositories/Onboarding/OnboardingRepository.swift) / [`OnboardingService`](../ClairfyApp/Services/Onboarding/OnboardingService.swift).
- Alerta de consentimento com texto longo antes de marcar onboarding como concluído.

## Lista de consultas

- Lista com `searchable` para filtrar por título.
- `swipeActions` para eliminar.
- Botão **REC** abre [`VoiceRecordingView`](../ClairfyApp/Features/VoiceRecording/VoiceRecordingView.swift) via `navigationDestination(isPresented:)`.
- Toolbar **Modelos IA** (`NavigationLink`) abre a gestão de descarga Gemma E2B/E4B (POC).
- **WIP:** toque num item define `selectedConsultation`, mas o destino de navegação está vazio (comentário “navegar para tela de visualizar consulta”).

## Gravação

- Pedido de permissão de microfone no `VoiceRecordingViewModel`.
- Estados em [`RecordingStateEnum`](../ClairfyApp/Core/Utils/RecordingStateEnum.swift).
- Duração mínima de **30 segundos** para concluir gravação (`stopRecordingTapped`); abaixo disso mostra alerta “too short”.
- Indicador visual: [`PulsatingRecordingIndicator`](../ClairfyApp/Core/Components/PulsatingRecordingIndicator.swift).

## Componentes partilhados

Ver [`ClairfyApp/Core/Components/`](../ClairfyApp/Core/Components/): `ListComponent`, `EmptyState`, `OnboardingPageView`, `AudioForm`, etc.

## Fora do escopo do código

- Testes de UI automatizados (não referenciados nesta documentação).
- Design no Figma — ver [design-system.md](design-system.md) para tokens no código.
