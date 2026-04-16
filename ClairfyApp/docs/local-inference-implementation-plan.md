# Plano: inferência local no iPhone (hardware + implementação)

Documento de decisão e roadmap após pesquisa (ecossistema Apple, Google AI Edge, llama.cpp) e alinhamento com a POC actual (`poc-gemma-local.md`): pesos **GGUF** no disco, `StubLocalInferenceEngine` até motor real.

## 1. O que o hardware do iPhone oferece (contexto)

| Recurso | Papel típico em LLM on-device |
|--------|-------------------------------|
| **GPU (Metal)** | Operações matriciais em massa; backend principal para **llama.cpp** (ggml-metal), **MLX** e stacks Google com aceleração Metal. |
| **Memória unificada** | Partilha eficiente CPU/GPU (relevante para MLX e para cargas grandes). |
| **CPU (P+E)** | Pré/pós-processamento, caminhos não acelerados, *fallback*; paralelismo com cuidado para não competir com a GPU. |
| **Neural Engine (ANE)** | Usada sobretudo por modelos **Core ML** compilados para esse destino; **GGUF + llama.cpp não usam ANE directamente**. Maximizar ANE implicaria outro formato/pipeline (Core ML ou runtime que o mapeie). |

**Conclusão:** “Extrair o máximo do iPhone” para LLMs passa, na prática, por **Metal na GPU** + **quantização agressiva** + **gestão de memória** (e eventualmente **Increased Memory Limit**). ANE é bónus só se migrarem para uma stack Core ML / conversão oficial.

---

## 2. Opções avaliadas

### A) **llama.cpp + Metal (GGUF)** — *recomendada para a linha actual da POC*

- **Prós:** Mantém o **mesmo artefacto** já descarregado (`.gguf` Q4_K_M), alinhado ao catálogo e ao `ModelDownloadService`. Ecossistema **ggml** com backend **Metal** activo (evolução Metal assíncrono, trabalho contínuo em tensores/novas APIs Apple). Suporte multimodal **Gemma 4 + áudio** é tema de desenvolvimento no *upstream* — há de ser fixada **tag/commit** testada.
- **Contras:** Integração **C/C++ → Swift** (XCFramework ou SPM com bridge), manutenção de binários por arquitectura; **ANE** não entra no caminho GGUF clássico.
- **Hardware:** Uso forte de **GPU** via Metal; adequado ao objectivo “melhor desempenho” sem trocar o formato dos pesos.

### B) **MLX / MLX Swift** (Apple)

- **Prós:** Framework pensado para **Apple Silicon**, **Metal**, memória unificada; exemplos e sessões WWDC para LLM no dispositivo; boa integração **Swift**.
- **Contras:** Modelos costumam vir em **formato MLX** (ex.: repos `mlx-community` no Hugging Face), **não** são os `.gguf` actuais — implica **segundo pipeline de descarga**, conversão, ou mudança de catálogo. Verificar disponibilidade **Gemma 4 E2B/E4B** em MLX e requisitos de RAM.

### C) **Google AI Edge: MediaPipe LLM Inference**

- **Prós:** Documentação iOS, Gemma em fluxos oficiais.
- **Contras:** A documentação pública indica **deprecação** em favor de **LiteRT-LM**; não é boa aposta para projeto novo de longo prazo.

### D) **LiteRT-LM** (Google)

- **Prós:** Direcção oficial Google para edge; referência a **Gemma 4**, **Metal**, aceleradores; multi-modalidade e roadmap activo.
- **Contras:** Integração **iOS** pode depender ainda de **APIs C++** ou *bindings* Swift em evolução; **artefactos** podem não coincidir com os GGUF já usados — validar pacotes iOS e licenciamento.

---

## 3. Recomendação

| Prioridade | Escolha | Motivo |
|------------|---------|--------|
| **1 (curto / médio prazo)** | **llama.cpp + Metal** com os **GGUF** já integrados | Menor atrito: mesmo ficheiro, mesma verificação por tamanho, foco em bridge nativo e parâmetros de performance (threads, batch, *context*). |
| **2 (estratégia paralela)** | Avaliar **LiteRT-LM** quando existir caminho **Swift** estável e modelo **Gemma 4** equivalente (E2B/E4B) empacotado para iOS | Alinha com Google e pode oferecer stack unificada Android+iOS, se o produto aceitar **dois** formatos de peso em paralelo durante transição. |
| **3** | **MLX Swift** se o produto aceitar **trocar** ou **duplicar** origem de modelos (HF MLX) e priorizar “stack Apple” sobre GGUF único | Máximo alinhamento Apple; custo de catálogo e UX de descarga. |

**Não** esperar que **GGUF + llama.cpp** usem **ANE**; isso só entra com **Core ML** ou runtime que exporte para ANE (fora do scope imediato).

---

## 4. Plano de implementação (fases)

### Fase 0 — Pré-requisitos de engenharia

- Fixar **commit/tag** de `llama.cpp` (ou fork) com **Gemma 4 IT + modalidade de áudio** validada em **dispositivo físico** (não só simulador).
- Definir **RAM mínima** suportada (documentação actual: ~6 GB arriscado para E4B; **8 GB** mais seguro).
- Pedir entitlement **Increased Memory Limit** se testes mostrarem jetsam com E4B.

### Fase 1 — Binário e ligação ao Xcode

- Produzir **XCFramework** (ou SPM) com **llama** + **ggml-metal** para `iphoneos` + `iphonesimulator` conforme política de CI.
- Expor API **C mínima**: carregar modelo (path GGUF), aplicar prompt / *tokens* de áudio conforme API multimodal escolhida no *upstream*.
- Integrar no target **ClairfyApp**; documentar flags de compilação e *link* com Metal framework.

### Fase 2 — Camada Swift

- Implementar `LlamaCppNativeInferenceEngine` (ou renomear para `GemmaLlamaInferenceEngine`):
  - Carregar pesos de `LocalModelStorage.fileURL(for:)`.
  - Pipeline **áudio →** (conforme API suportada: *encoder* / *tokens* / *path* multimodal) **→ texto** resumo + bullet *action items* (prompt de sistema em PT se for requisito de produto).
  - Tratamento de erros: ficheiro corrupto, OOM, *timeout*, cancelamento (`Task`).
- Manter `StubLocalInferenceEngine` para **DEBUG** ou *feature flag*.

### Fase 3 — Integração produto

- **Factory** / injecção: `LocalModelsViewModel` recebe implementação real em **Release**; stub opcional em **DEBUG**.
- Métricas: tempo de primeira *token*, *tokens/s*, memória de pico (Instruments).
- UX: mensagem clara se RAM insuficiente ou modelo não suportado no *build*.

### Fase 4 — Qualidade e rollout

- Testes em **2–3 gerações** de iPhone (6 GB vs 8 GB RAM).
- Testes de **regressão** com os mesmos `.m4a` da pasta Documents.
- Documentar em `poc-gemma-local.md` a **versão** do motor e limitações conhecidas.

### Fase 5 — Opcional (pós-MVP)

- **Spike LiteRT-LM:** comparar latência/qualidade com o mesmo *prompt*; decisão de convergência de formato.
- **Spike MLX:** apenas se houver modelo Gemma 4 equivalente e aceitação de duplo catálogo.

---

## 5. Critérios de sucesso mensuráveis

1. **“Testar inferência”** gera texto **não simulado** com modelo descarregado (E2B no mínimo).
2. **GPU** activa durante inferência (Metal *capture* ou *Instruments*).
3. Nenhum crash em *smoke test* em dispositivo alvo com RAM documentada.
4. Tempo e qualidade do resumo aceitáveis pela equipa clínica/produto (definir *threshold* qualitativo).

---

## 6. Referências úteis (externas)

- `ggml-org/llama.cpp` — exemplos iOS / Metal, *issues* de dispositivos reais.
- Apple — sessões **MLX** / LLM on-device (WWDC25+).
- Google — **LiteRT-LM**, **AI Edge** (quickstart iOS), documentação de **Gemma** em mobile.
- *Gist* / exemplos “LLM on iPhone with MLX Swift” — referência de entitlements e limites de memória.

Este plano deve ser revisto após a primeira **prova técnica** com binário llama.cpp no dispositivo (Fase 1–2).
