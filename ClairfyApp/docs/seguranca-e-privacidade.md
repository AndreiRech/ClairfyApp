# Segurança e privacidade

## Fonte no repositório

| Tópico | Local |
|--------|--------|
| Dados estruturados | SwiftData (`Consultation`, `Transcription`, `AudioFile`) — [`Models/Persistence/`](../ClairfyApp/Models/Persistence/) |
| Ficheiros de áudio | Caminho guardado em `AudioFile.audioPath`; gravação em Documents via [`RecordingService`](../ClairfyApp/Services/Recording/RecordingService.swift) |
| Consentimento do utilizador | Texto em [`OnboardingService.getTermsAndConditions()`](../ClairfyApp/Services/Onboarding/OnboardingService.swift); aceitação via alerta em [`OnboardingView`](../ClairfyApp/Features/Onboarding/OnboardingView.swift) |
| Microfone | Pedido em [`VoiceRecordingViewModel`](../ClairfyApp/Features/VoiceRecording/VoiceRecordingViewModel.swift) (`AVAudioApplication.recordPermission`) |
| Áudio em fundo | [`Info.plist`](../ClairfyApp/Info.plist) — `UIBackgroundModes` → `audio` |

## O que o código **não** garante por si só

- **Criptografia end-to-end** ou **cifrado em repouso** específico para SwiftData ou ficheiros — **não** está implementado de forma explícita nos ficheiros analisados; não afirmar “dados criptografados” no marketing sem implementação audível.
- **Sincronização na nuvem** — não há código de sync.
- **Anonimização** de dados clínicos para telemetria — não documentada no código.

## Conteúdo legal no onboarding (resumo)

O texto de termos menciona, entre outros:

- Consentimento do **paciente** antes de gravar.
- Clairfy como **ferramenta de apoio**, não substituto de diagnóstico.
- **Revisão obrigatória** de resumos gerados por IA.
- **Isenção de responsabilidade** dos desenvolvedores.

Qualquer alteração jurídica deve passar por revisão jurídica; o código apenas exibe o texto atual.

## LGPD (Brasil)

Para utilizadores no Brasil, aplicam-se princípios da **Lei Geral de Proteção de Dados** (bases legais, minimização, transparência, direitos do titular). O app trata dados potencialmente **sensíveis** (saúde). Esta secção é **orientativa**; não constitui aconselhamento jurídico.

### Checklist para o produto (fora do código)

- Política de privacidade publicada e acessível.
- Registo de operações de tratamento (ROPA) interno.
- Avaliação de **DPIA** / RIPD se aplicável.
- Canal para pedidos do titular (acesso, correção, eliminação).

## Checklist técnico (App Privacy / loja)

Quando integrar backend ou analytics, atualizar:

- Categorias de dados recolhidos (contactos, saúde, áudio, etc.).
- Finalidades e se os dados são ligados ao utilizador.
- Se os dados são usados para *tracking*.

Ver [app-store-connect.md](app-store-connect.md) para o fluxo na App Store Connect.

## Fora do escopo do código

- HIPAA e outros regimes **fora do Brasil** — mencionar apenas se o produto for internacionalizado.
- Certificações de segurança (ISO 27001, SOC 2, etc.).
