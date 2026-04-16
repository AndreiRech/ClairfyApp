# Gemma 4: áudio directo no modelo (iOS) e **mtmd**

## O que a app faz hoje

1. **Descarrega** o GGUF principal (bartowski) e o **mmproj** Q8 (`ggml-org/gemma-4-*-it-GGUF`).
2. **Converte** o `.m4a` para **PCM float32 mono a 16 kHz** com **AVFoundation** (sem Speech / Siri).
3. **Não** corre ainda a pilha multimodal no dispositivo: o pacote **LlamaSwift** (mattt) só inclui o binário **llama** base; a API **C `mtmd_*`** (`tools/mtmd/mtmd.h`) não está nesse XCFramework.

## O que falta para inferência real

- Ligar **libmtmd** compilada para `iphoneos` (ou um XCFramework que inclua `llama` + `mtmd`).
- Referência upstream: `mtmd_init_from_file(mmproj_fname, text_model, …)` e entrada `MTMD_INPUT_CHUNK_TYPE_AUDIO` (ver `docs` em llama.cpp e `llama-mtmd-cli`).

## Referência de linha de comando (desktop)

```bash
llama-mtmd-cli -m gemma-4-E2B-it-Q4_K_M.gguf --mmproj mmproj-gemma-4-E2B-it-Q8_0.gguf --audio sample.wav -p "…"
```

No iPhone, o equivalente é chamar a mesma lógica via **C/C++** a partir do vosso código, não o `Speech` da Apple.

## Próximos passos sugeridos

1. Fixar uma **tag** de `ggml-org/llama.cpp` com suporte Gemma 4 áudio.
2. Compilar **mtmd** + dependências para iOS (arm64) e empacotar como **XCFramework**.
3. Adicionar target **C++** ou **bridge** no Xcode que chame `mtmd_init_from_file` e alimente os PCM já produzidos por `AudioPCMExtractor`.
