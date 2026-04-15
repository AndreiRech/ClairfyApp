# Design system (código)

Este documento descreve **tokens e componentes** tal como aparecem no código. Não substitui um guia de marca externo.

## Fonte no repositório

- **Cores (Asset Catalog):** [`ClairfyApp/App/Assets.xcassets/Colors/`](../ClairfyApp/App/Assets.xcassets/Colors/)
- **Imagens:** [`ClairfyApp/App/Assets.xcassets/Images/`](../ClairfyApp/App/Assets.xcassets/Images/)
- **Extensão de texto:** [`StringExtension.swift`](../ClairfyApp/Core/Utils/StringExtension.swift) — `highlight(substring:with:)` para `AttributedString`

## Cores nomeadas

| Nome no projeto | Uso observado |
|-----------------|---------------|
| `clairBlue` | Marca: splash, destaques em lista, botões de onboarding, gravação, indicador de gravação |
| `reverseClairBlue` | Definido no catálogo; verificar uso pontual em novas telas |
| `Label-Basic` | Definido no catálogo |

No SwiftUI, a cor de marca aparece como `Color(.clairBlue)` (asset) ou `Color.clairBlue` / `.clairBlue` consoante o contexto (gerado a partir do nome do asset).

## Tipografia e hierarquia

- Onboarding: `.largeTitle` + negrito para títulos; `.body` para descrições ([`OnboardingPageView`](../ClairfyApp/Core/Components/OnboardingPageView.swift)).
- Lista: estilos de etiqueta em [`ListComponent`](../ClairfyApp/Core/Components/ListComponent.swift).

## Destaque semântico no texto

[`String.highlight(substring:with:)`](../ClairfyApp/Core/Utils/StringExtension.swift) aplica cor a uma substring (case insensitive) dentro de `AttributedString`, usado para realçar palavras nos títulos e descrições do onboarding com `.clairBlue`.

## Componentes principais

| Componente | Descrição breve |
|------------|-------------------|
| `ListComponent` | Linha de lista com título, data formatada, ícone |
| `EmptyState` | Estado vazio da lista de consultas |
| `OnboardingPageView` | Página com imagem, texto destacado, botões Continuar/Pular |
| `AudioForm` | Formulário visual relacionado com áudio (formas e preenchimento) |
| `PulsatingRecordingIndicator` | Indicador animado durante gravação |

## Liquid Glass

O uso do modifier **`.glassEffect()`** está detalhado em [liquid-glass.md](liquid-glass.md).

## Fora do escopo do código

- Grid de espaçamentos formais (8pt system) se não estiver codificado em constantes.
- Tokens exportados do Figma — alinhar manualmente quando existir handoff de design.
