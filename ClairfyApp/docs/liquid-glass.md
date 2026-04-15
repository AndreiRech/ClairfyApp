# Liquid Glass (SwiftUI no Clairfy)

## O que o código usa

O projeto aplica o modifier SwiftUI **`.glassEffect()`** em:

1. **[`ConsultationListView`](../ClairfyApp/Features/ConsultationList/ConsultationListView.swift)** — no botão circular **REC** (gravar).
2. **[`OnboardingPageView`](../ClairfyApp/Core/Components/OnboardingPageView.swift)** — no botão **“Continuar”** (texto com cor `.clairBlue`).

Não há outros usos de `glassEffect` nos ficheiros Swift listados no repositório.

## Relação com “Liquid Glass” da Apple

A Apple associa **Liquid Glass** a materiais e interações de UI recentes no ecossistema. O modifier **`.glassEffect()`** faz parte desse conjunto de APIs SwiftUI quando disponível no **SDK / versão de sistema** com que o projeto é compilado.

## Orientação para agentes de IA e devs

1. **Não assumir** disponibilidade em iOS antigo: verifique o **deployment target** e a **documentação da API** da versão do Xcode em uso.
2. **Não inventar** parâmetros ou modificadores não presentes no código; o uso atual é **sem argumentos** — `.glassEffect()`.
3. Se a compilação falhar num SDK mais antigo, as opções são: subir o deployment target, usar `if #available`, ou substituir por material alternativo (`.ultraThinMaterial`, etc.) conforme decisão de produto — isso é alteração de código, não documentada aqui como feita.

## Testes recomendados

- Verificar contraste do botão **Continuar** e do **REC** em **claro** e **escuro**.
- Validar legibilidade do texto sobre o material de vidro em diferentes fundos.

## Fora do escopo do código

- Vídeos de marketing Apple sobre Liquid Glass.
- Especificação de design pixel-perfect não versionada no repo.
