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

## Mapa do código (pastas principais)

| Pasta | Descrição |
|-------|-----------|
| [`ClairfyApp/App/`](../ClairfyApp/App/) | Entrada do app, assets (cores, imagens) |
| [`ClairfyApp/Features/`](../ClairfyApp/Features/) | Telas por funcionalidade (onboarding, lista, gravação, splash) |
| [`ClairfyApp/Core/`](../ClairfyApp/Core/) | Componentes reutilizáveis e utilitários |
| [`ClairfyApp/Models/`](../ClairfyApp/Models/) | Domínio, DTOs, modelos SwiftData |
| [`ClairfyApp/Repositories/`](../ClairfyApp/Repositories/) | Camada entre ViewModels e serviços |
| [`ClairfyApp/Services/`](../ClairfyApp/Services/) | Serviços (SwiftData, áudio, onboarding) |

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
