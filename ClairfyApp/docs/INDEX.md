# Documentação Clairfy — índice

Este diretório reúne ficheiros **modulares** para **desenvolvedores** e **agentes de IA** entenderem o app sem depender só do código. Tudo está em **português brasileiro**.

## Como usar (agentes de IA)

1. Leia primeiro este índice e o glossário abaixo.
2. Abra o documento do tema que precisa (arquitetura, front, segurança, etc.).
3. Cada doc indica **fonte no repositório** (paths) e **o que está fora do código** (processos Apple, jurídico, contas).
4. **Não assuma** backend remoto, criptografia ou integrações não mencionadas no código — use [`backend-e-servicos.md`](backend-e-servicos.md) para o estado real.

## Ordem de leitura sugerida

| Ordem | Documento | Conteúdo |
|-------|-----------|----------|
| 1 | [arquitetura.md](arquitetura.md) | Camadas, SwiftData, fluxo de dados |
| 2 | [frontend-ios.md](frontend-ios.md) | Telas SwiftUI, navegação, WIP |
| 3 | [backend-e-servicos.md](backend-e-servicos.md) | Serviços locais, ausência de API, DTOs futuros |
| 4 | [design-system.md](design-system.md) | Cores, componentes, assets |
| 5 | [ui-padroes-apple.md](ui-padroes-apple.md) | HIG, cores de sistema, padrões UI |
| 6 | [liquid-glass.md](liquid-glass.md) | Modifier `.glassEffect()` e requisitos |
| 7 | [seguranca-e-privacidade.md](seguranca-e-privacidade.md) | Dados, microfone, LGPD, checklists |
| 8 | [app-store-connect.md](app-store-connect.md) | Distribuição, privacidade na loja, TestFlight |
| POC | [poc-gemma-local.md](poc-gemma-local.md) | Gemma E2B/E4B local: URLs, spike llama.cpp/MediaPipe, limitações |

## Mapa do código (pastas principais)

| Pasta | Descrição |
|-------|-----------|
| [`App/`](../App/) | Entrada do app, assets (cores, imagens) |
| [`Features/`](../Features/) | Telas (onboarding, lista, gravação, splash, **modelos locais**) |
| [`Core/`](../Core/) | Componentes reutilizáveis e utilitários |
| [`Models/`](../Models/) | Domínio, DTOs, modelos SwiftData |
| [`Repositories/`](../Repositories/) | Camada entre ViewModels e serviços |
| [`Services/`](../Services/) | Serviços (SwiftData, áudio, onboarding, **LocalAI**) |

## Glossário rápido

| Termo | Significado no Clairfy |
|-------|------------------------|
| **Clairfy** | Nome do app; assistente de consulta por áudio (roadmap inclui IA). |
| **SwiftData** | Framework de persistência; modelos `@Model` e `ModelContainer`. |
| **Consultation** | Entidade principal de uma consulta; relaciona-se com áudio e transcrição. |
| **Liquid Glass** | Família de UI Apple; neste projeto aparece como `.glassEffect()` em SwiftUI. |

## Fora do âmbito destes ficheiros

- Credenciais, segredos e respostas exatas do **App Privacy** na App Store (processo na conta Apple).
- Textos legais finais e políticas publicadas — apenas referência ao que existe no código (ex.: termos no onboarding).
