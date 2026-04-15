# Clairfy

Aplicativo **iOS** para **profissionais de saúde** registrarem consultas em áudio e, no roadmap do produto, receberem **resumos**, **transcrições** e **pontos de ação** derivados da conversa — sempre com revisão humana, conforme o texto de consentimento exibido no onboarding.

Este repositório contém o **código-fonte Swift** do app na pasta [`ClairfyApp/`](ClairfyApp/).

## Para quem é

- Equipe de produto e engenharia que mantém o Clairfy.
- Novos desenvolvedores que precisam entender stack, pastas e fluxos antes de abrir o Xcode.

## Stack (resumo)

- **SwiftUI** e **`@Observable`** nos view models.
- **SwiftData** para persistência local (`Consultation`, `Transcription`, `AudioFile`).
- **AVFoundation** para captura de áudio (`AVAudioRecorder`).
- **Não há** cliente HTTP (`URLSession`) nem backend versionado neste repositório; integrações remotas futuras estão descritas em [`docs/backend-e-servicos.md`](docs/backend-e-servicos.md).

## Requisitos

- **macOS** com **Xcode** instalado (use a versão alinhada ao time; o deployment target mínimo de iOS é definido no projeto Xcode).
- O ficheiro **`.xcodeproj`** ou **`.xcworkspace`** pode não estar incluído neste clone; nesse caso, obtenha o projeto completo com a equipa antes de compilar.

## Como desenvolver

1. Abra o projeto no Xcode (quando disponível).
2. Selecione um destino **iPhone** ou simulador compatível.
3. Execute o *scheme* principal do target **ClairfyApp**.

Permissões e modos de fundo relevantes estão documentados em [`docs/seguranca-e-privacidade.md`](docs/seguranca-e-privacidade.md) e no `Info.plist` sob `ClairfyApp/`.

## Documentação

Toda a documentação técnica modular (arquitetura, UI, segurança, App Store, Liquid Glass, etc.) está em **[`docs/INDEX.md`](docs/INDEX.md)** — ponto de entrada recomendado para **pessoas** e para **agentes de IA** que precisam mapear o projeto.

## Licença e equipa

Defina aqui a licença e os contactos do projeto, se aplicável.
