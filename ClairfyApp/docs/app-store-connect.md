# App Store Connect e distribuição

Documento **operacional** para equipa. **Não** substitui a conta Apple Developer nem a documentação oficial da Apple. Valores concretos (bundle ID, IDs de app) ficam na conta Apple ou no projeto Xcode, não neste repositório.

## Pré-requisitos

- Conta **Apple Developer Program** ativa.
- **Xcode** com certificados de assinatura e perfis de provisionamento (Development, Distribution, App Store).
- **App Store Connect** com a app criada (ou a criar).

## Checklist — projeto Xcode

- [ ] **Bundle Identifier** único e estável.
- [ ] **Version** (Marketing) e **Build** incrementados a cada submissão.
- [ ] **Deployment target** iOS compatível com o uso de APIs (SwiftUI, SwiftData, Liquid Glass / `.glassEffect()`).
- [ ] **Signing & Capabilities** — rever microfone, fundo de áudio, e futuras capacidades (Health, Push, etc.) só se forem adicionadas.
- [ ] **Info.plist** — `NSMicrophoneUsageDescription` (e outras chaves de uso) quando exigir permissão ao utilizador; o `Info.plist` neste repo é mínimo — completar no projeto real.

## Checklist — App Store Connect (metadados)

- [ ] Nome, subtítulo, descrição (inclui Brasil se for público PT-BR).
- [ ] **Palavras-chave**, URL de suporte, URL de marketing (opcional).
- [ ] **Categoria primária** — frequentemente **Medical** ou **Health & Fitness**, conforme posicionamento do produto.
- [ ] **Classificação etária** e questionário de conteúdo.
- [ ] **Screenshots** e **preview** por tamanho de dispositivo exigido.
- [ ] **Ícone** 1024×1024 (sem transparência, conforme regras atuais).

## App Privacy (questionário de privacidade)

Responder com base no **tratamento real** de dados:

- Dados de **saúde** (gravações, notas) — tipicamente “Sim” se armazenados ou processados.
- **Microfone** — “Sim” para gravação.
- Dados **ligados ao utilizador** vs **não ligados**.
- **Tracking** — se não usar IDFA nem tracking de terceiros, declarar em conformidade.

Atualizar quando o backend ou SDKs externos forem adicionados.

## Guidelines relevantes

- **5.1.1** — Privacidade e recolha de dados.
- Apps **médicos** — não diagnosticar/substituir profissional; alinhar ao texto de termos do onboarding.
- **Acessibilidade** — Apple incentiva suporte a VoiceOver e Dynamic Type.

## TestFlight

- [ ] Upload de build via Xcode ou CI.
- [ ] Grupos de testadores internos/externos.
- [ ] Notas de teste para a revisão.

## Fora do escopo deste ficheiro

- Números de contrato, segredos ou passwords.
- Decisões de preço e disponibilidade por país.
