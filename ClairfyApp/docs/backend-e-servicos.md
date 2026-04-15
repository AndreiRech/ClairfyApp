# Backend e serviços

## Estado atual no repositório

- **Não existe** código de cliente HTTP (`URLSession`, `URLSessionTask`, etc.) nos ficheiros Swift analisados.
- **Não existe** servidor, worker ou BFF versionado neste repo.
- A “camada de dados” é **local**: **SwiftData** para entidades de domínio e **ficheiros** no diretório Documents para gravações **m4a**.

Qualquer menção futura a “backend” no Clairfy deve ser tratada como **projeto à parte**, até existir código ou contratos versionados aqui.

## Serviços Swift (app)

| Serviço | Função | Ficheiro |
|---------|--------|----------|
| `ConsultationService` | CRUD de `Consultation` | [`ConsultationService.swift`](../ClairfyApp/Services/Consultation/ConsultationService.swift) |
| `AudioService` | CRUD de `AudioFile` | [`AudioService.swift`](../ClairfyApp/Services/Audio/AudioService.swift) |
| `TranscriptionService` | CRUD de `Transcription` | [`TranscriptionService.swift`](../ClairfyApp/Services/Transcription/TranscriptionService.swift) |
| `RecordingService` | Gravação com `AVAudioRecorder`, interrupções de sessão | [`RecordingService.swift`](../ClairfyApp/Services/Recording/RecordingService.swift) |
| `OnboardingService` | Dados estáticos de páginas e texto de termos | [`OnboardingService.swift`](../ClairfyApp/Services/Onboarding/OnboardingService.swift) |

Todos os serviços de SwiftData usam [`Persistence.shared.modelContext`](../ClairfyApp/Services/Persistence.swift).

## DTOs e integração futura (LLM / API)

Em [`ClairfyApp/Models/DTO/`](../ClairfyApp/Models/DTO/) existem estruturas que sugerem um **contrato tipo chat** para um modelo generativo:

- **`ChatMessage`** — `role`, `content` ([`ChatMessage.swift`](../ClairfyApp/Models/DTO/ChatMessage.swift)).
- **`ChatBody`** — `model`, `messages`, `temperature` ([`ChatBody.swift`](../ClairfyApp/Models/DTO/ChatBody.swift)).
- **`DoctorDTO`**, **`PatienceDTO`** — nomes alinhados a entidades de domínio eventual API.

**Nenhum** destes DTOs é referenciado pelo fluxo de UI atual de gravação ou lista. Devem ser documentados como **preparação** ou **exploração**, não como API ativa.

## Repositórios

Encapsulam serviços para os ViewModels:

- [`ConsultationListRepository`](../ClairfyApp/Repositories/ConsultationList/ConsultationListRepository.swift)
- [`VoiceRecordingRepository`](../ClairfyApp/Repositories/VoiceRecording/VoiceRecordingRepository.swift)
- [`OnboardingRepository`](../ClairfyApp/Repositories/Onboarding/OnboardingRepository.swift)

## Fora do escopo do código

- Endereços base URL, chaves API, filas cloud.
- Esquemas OpenAPI ou GraphQL.
- Políticas de retenção e backup no servidor (quando existir backend).
