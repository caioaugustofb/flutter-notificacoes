# Agenda Tech Belém

Atividade Prática 4 — Notificações Push (Flutter + Firebase Cloud Messaging).

App de agenda de eventos de tecnologia em Belém. A tela inicial lista os próximos eventos e a tela de detalhes mostra data, horário, local e descrição de cada um. As notificações avisam o usuário sobre a agenda.

## Como funciona

- `lib/data/eventos.dart`: eventos fixos no código. Cada um tem um `id` (ex.: `workshop-firebase`).
- `lib/services/notification_service.dart`:
  - pede a permissão de notificações (Android 13+);
  - obtém o token FCM e mostra na tela inicial, com botão de copiar;
  - **segundo plano / app fechado**: o próprio Android exibe a notificação enviada pelo Console, inclusive a imagem;
  - **app aberto**: o Android não exibe notificação do FCM sozinho, então o app mostra uma notificação local (`flutter_local_notifications`) com o mesmo título, texto e imagem;
  - **navegação**: lê o campo `evento_id` dos dados da mensagem e abre a tela do evento. Funciona com o app em segundo plano (`onMessageOpenedApp`), com o app fechado (`getInitialMessage`) e com o app aberto (toque na notificação local).
- `AndroidManifest.xml`: define o canal `eventos` (importância alta, aparece no topo da tela) e o ícone de calendário como padrões do FCM.

## Configuração do Firebase (feita uma vez)

1. Acesse https://console.firebase.google.com e clique em **Criar um projeto**. Pode desativar o Google Analytics. O projeto fica no plano Spark (gratuito, sem cartão).
2. Na página do projeto, clique no ícone do **Android** para adicionar um app.
   - Nome do pacote Android: `br.cesupa.caio.agenda_eventos` (tem que ser exatamente esse).
   - Apelido: `Agenda Tech Belém`. O SHA-1 pode ficar em branco.
3. Baixe o `google-services.json` e coloque em `android/app/google-services.json`.
4. Pule as etapas seguintes do assistente (o SDK e o plugin do Gradle já estão configurados no projeto).

O `google-services.json` está no `.gitignore`. Quem clonar o repositório precisa gerar o próprio arquivo.

## Rodar

```bash
flutter pub get
flutter run
```

Na primeira abertura, aceite a permissão de notificações. Copie o token FCM pelo botão na tela inicial (ele também aparece no log como `[FCM] token: ...`).

## Enviar as notificações pelo Console

Menu lateral > **Executar** (Run) > **Messaging** > **Criar primeira campanha** (ou **Nova campanha**) > **Mensagens do Firebase Notification** > **Criar**.

Para mandar só para o seu celular: depois de preencher o texto, clique em **Enviar mensagem de teste**, cole o token, clique em **+** e depois em **Testar**.

### Desafio 1 — Notificação simples

Deixe o app em segundo plano (botão home).

- Título: `Inscrições abertas: Flutter Day Belém`
- Texto: `Garanta sua vaga no dia 21/11. Palestras sobre Flutter e mobile no CESUPA.`

### Desafio 2 — Notificação com imagem

App em segundo plano.

- Título: `Destaque da semana: Hackathon Amazônia Digital`
- Texto: `48 horas criando soluções para a região. Equipes de até 5 pessoas.`
- Imagem da notificação: `https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800&q=70&fm=jpg`

Na notificação, deslize para baixo (ou toque na seta) para expandir a imagem.

### Desafio 3 — Notificação com navegação

- Título: `Começa em 1 hora: Workshop de Firebase`
- Texto: `Laboratório 4 do CESUPA, às 19h. Toque para ver os detalhes.`
- Imagem (opcional): `https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=800&q=70&fm=jpg`
- Na etapa **Opções adicionais (opcional)** > **Dados personalizados**:
  - Chave: `evento_id`
  - Valor: `workshop-firebase`

O botão "Enviar mensagem de teste" fica na primeira etapa, mas ele envia a campanha com tudo o que já foi preenchido. Então preencha os dados personalizados **antes** e volte para a etapa 1 para testar.

Se a mensagem de teste chegar mas não abrir o evento, publique a campanha de verdade: em **Segmentação** escolha o app `br.cesupa.caio.agenda_eventos`, em **Programação** escolha **Agora** e clique em **Revisar** > **Publicar**. Como só o seu aparelho tem o app, só ele recebe. O log `[FCM] aberto pela notificacao, dados: {...}` mostra o que chegou.

Teste os dois casos pedidos:
1. **Segundo plano**: app aberto em outra tela ou minimizado. Toque na notificação e o app abre os detalhes do workshop.
2. **App fechado**: feche o app pelos apps recentes (deslizando o card). Envie e toque na notificação. O app inicia direto nos detalhes.

Ids válidos para `evento_id`: `flutter-day`, `hackathon-amazonia`, `workshop-firebase`, `meetup-ux`, `ia-amazonia`. Um id inexistente mostra um aviso na tela inicial.

## Observações

- Se o app for encerrado com **Forçar parada** nas configurações do Android, o sistema bloqueia as notificações até ele ser aberto de novo. Feche pelos apps recentes.
- Em alguns aparelhos (Xiaomi, Samsung com economia de bateria) é preciso permitir execução em segundo plano.
- A imagem precisa ser uma URL https pública com menos de 1 MB.
