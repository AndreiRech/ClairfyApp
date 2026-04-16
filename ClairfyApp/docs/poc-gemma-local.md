# POC: Gemma 4 E2B / E4B local (iOS)

Este documento descreve a prova de conceito na branch `poc/local-gemma-e2b-e4b`: descarga de pesos GGUF, verificação por tamanho, ecrã de estado e **inferência simulada** até o motor nativo ser integrado.

## Fonte no repositório

| Peça | Path |
|------|------|
| Catálogo + URLs + tamanhos LFS | [`Services/LocalAI/LocalModelCatalog.swift`](../Services/LocalAI/LocalModelCatalog.swift) |
| Pasta no disco | [`Services/LocalAI/LocalModelStorage.swift`](../Services/LocalAI/LocalModelStorage.swift) |
| Download com progresso | [`Services/LocalAI/ModelDownloadService.swift`](../Services/LocalAI/ModelDownloadService.swift) |
| Verificação (tamanho exacto) | [`Services/LocalAI/ModelVerificationService.swift`](../Services/LocalAI/ModelVerificationService.swift) |
| Contrato inferência | [`Services/LocalAI/LocalInferenceEngine.swift`](../Services/LocalAI/LocalInferenceEngine.swift) |
| Stub (POC UI) | [`Services/LocalAI/StubLocalInferenceEngine.swift`](../Services/LocalAI/StubLocalInferenceEngine.swift) |
| Placeholder motor nativo | [`Services/LocalAI/LlamaCppNativeInferenceEngine.swift`](../Services/LocalAI/LlamaCppNativeInferenceEngine.swift) |
| Último `.m4a` em Documents | [`Services/LocalAI/LatestRecordingLocator.swift`](../Services/LocalAI/LatestRecordingLocator.swift) |
| UI | [`Features/LocalModels/`](../Features/LocalModels/) |
| Entrada na lista | [`Features/ConsultationList/ConsultationListView.swift`](../Features/ConsultationList/ConsultationListView.swift) |

## Pesos e Hugging Face

- **E2B** (Q4_K_M): `bartowski/google_gemma-4-E2B-it-GGUF` — ficheiro `google_gemma-4-E2B-it-Q4_K_M.gguf` (~3,36 GB).
- **E4B** (Q4_K_M): `bartowski/google_gemma-4-E4B-it-GGUF` — ficheiro `google_gemma-4-E4B-it-Q4_K_M.gguf` (~5,03 GB).

Os tamanhos em bytes no catálogo devem coincidir com o **LFS** no Hugging Face; se o repo atualizar os ficheiros, **atualize** `expectedArtifactSizeBytes` em `LocalModelCatalog.swift`.

**Gating / 403:** modelos Google podem exigir login e aceite de licença no Hugging Face. Se o download falhar com 403, use token (`Authorization: Bearer`) numa variante futura do `ModelDownloadService` ou hospede os GGUF num CDN próprio com licença clara.

## Spike: motor nativo (áudio → resumo)

**Decisão recomendada:** integrar **llama.cpp** (ecossistema ggml) com suporte a **Gemma 4 + áudio**, exposto à app via **XCFramework** ou **Swift Package** que envolva as APIs C. Há trabalho ativo no repositório `ggml-org/llama.cpp` para encoders multimodais Gemma 4 (incl. áudio); validar a tag/commit que o time fixa antes de empacotar.

**Alternativa:** **MediaPipe / Google AI Edge** com formato de tarefa otimizado para LLM em iOS (Metal), se a equipa preferir a linha oficial Google.

**Estado actual do código:** `StubLocalInferenceEngine` devolve texto fixo para validar UX. `LlamaCppNativeInferenceEngine` existe como **placeholder** que falha com `LocalInferenceError.nativeEngineNotLinked` até existir bridge real.

### Passos sugeridos no Xcode

1. Adicionar todos os ficheiros Swift novos ao target **ClairfyApp** (o clone pode não incluir `.xcodeproj`; sincronizar com o repositório que contém o projeto).
2. Integrar SPM/XCFramework do motor escolhido.
3. Substituir a injecção em `ModelManagementView` / `LocalModelsViewModel` de `StubLocalInferenceEngine()` por uma fábrica que devolva a implementação nativa quando `useStubResponses == false`.
4. Testar em **dispositivo físico** com RAM suficiente (E4B ~5 GB só de peso).

## Dispositivos e armazenamento

- Reserve **RAM + espaço em disco** para o peso, caches de inferência e restantes apps (ver mensagem de “espaço insuficiente” na POC: peso + ~512 MB de margem).
- iPhones com **6 GB RAM** podem falhar com E4B; **8 GB** (ex. gama Pro recente) é mais seguro.

## Privacidade

- Descarga **HTTPS** direto para `Application Support/ClairfyModels`.
- Áudio de teste: último ficheiro `.m4a` na pasta **Documents** (mesma pasta usada pelo gravador).

## Critérios de sucesso (POC)

1. Estados E2B/E4B visíveis; descarga com progresso; verificação por tamanho.
2. “Testar inferência” funciona com **stub** quando existe modelo válido + gravação `.m4a`.
3. Motor nativo documentado e preparado (`LlamaCppNativeInferenceEngine` + erros explícitos).
