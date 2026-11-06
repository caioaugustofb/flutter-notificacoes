import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/eventos.dart';
import '../screens/evento_screen.dart';

/// Chave dos dados personalizados (Firebase Console > Opcoes adicionais >
/// Dados personalizados) que identifica qual evento abrir.
const String chaveEventoId = 'evento_id';

/// Mesmo id declarado no AndroidManifest como canal padrao do FCM.
const AndroidNotificationChannel canalEventos = AndroidNotificationChannel(
  'eventos',
  'Eventos',
  description: 'Avisos sobre eventos da agenda',
  importance: Importance.high,
);

/// Chamado pelo FCM em um isolate separado quando chega uma mensagem com o
/// app em segundo plano ou fechado. Mensagens com bloco `notification`
/// (as enviadas pelo Console) ja sao exibidas pelo proprio Android, entao
/// aqui so registramos no log.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] mensagem em segundo plano: ${message.messageId}');
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final ValueNotifier<String?> token = ValueNotifier<String?>(null);
  final ValueNotifier<AuthorizationStatus?> permissao =
      ValueNotifier<AuthorizationStatus?>(null);

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _initLocalNotifications();
    await _pedirPermissao();
    await _carregarToken();

    // Desafio 3, app em segundo plano: o usuario toca na notificacao e o app
    // volta para a frente.
    FirebaseMessaging.onMessageOpenedApp.listen(_abrirPelaMensagem);

    // App aberto: o Android nao mostra notificacao do FCM sozinho, entao
    // exibimos uma local com o mesmo conteudo.
    FirebaseMessaging.onMessage.listen(_mostrarEmPrimeiroPlano);
  }

  /// Desafio 3, app fechado: o toque na notificacao iniciou o app. Precisa
  /// rodar depois do primeiro frame, quando o Navigator ja existe.
  Future<void> tratarAberturaInicial() async {
    final inicial = await _messaging.getInitialMessage();
    if (inicial != null) {
      _abrirPelaMensagem(inicial);
      return;
    }

    // App fechado aberto por uma notificacao local (caso raro, mas cobre).
    final detalhes = await _local.getNotificationAppLaunchDetails();
    if (detalhes?.didNotificationLaunchApp ?? false) {
      abrirEvento(detalhes!.notificationResponse?.payload);
    }
  }

  void abrirEvento(String? id) {
    final evento = buscarEvento(id);
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    if (evento == null) {
      if (id != null) {
        ScaffoldMessenger.of(
          navigator.context,
        ).showSnackBar(SnackBar(content: Text('Evento "$id" não encontrado.')));
      }
      return;
    }

    // Volta para a home antes de abrir, para nao empilhar telas de detalhe.
    navigator.popUntil((route) => route.isFirst);
    navigator.push(
      MaterialPageRoute(builder: (_) => EventoScreen(evento: evento)),
    );
  }

  Future<void> copiarToken(BuildContext context) async {
    final valor = token.value;
    if (valor == null) return;
    await Clipboard.setData(ClipboardData(text: valor));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Token copiado.')));
    }
  }

  Future<void> _initLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
    );
    await _local.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) =>
          abrirEvento(response.payload),
    );

    // Cria o canal com importancia alta para a notificacao aparecer no topo
    // da tela (heads-up), inclusive as que o FCM exibe em segundo plano.
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(canalEventos);
  }

  Future<void> _pedirPermissao() async {
    // No Android 13+ abre o dialogo de POST_NOTIFICATIONS.
    final settings = await _messaging.requestPermission();
    permissao.value = settings.authorizationStatus;
  }

  Future<void> _carregarToken() async {
    // getToken/onTokenRefresh estao marcados como deprecated na v17 em favor
    // de register()/onRegistered, que devolvem o FID. Mantemos o token
    // classico porque e o que o campo "token de registro do FCM" do envio de
    // teste no Firebase Console aceita.
    try {
      // ignore: deprecated_member_use
      token.value = await _messaging.getToken();
      debugPrint('[FCM] token: ${token.value}');
    } catch (e) {
      debugPrint('[FCM] erro ao obter token: $e');
    }
    // ignore: deprecated_member_use
    _messaging.onTokenRefresh.listen((novo) => token.value = novo);
  }

  void _abrirPelaMensagem(RemoteMessage message) {
    debugPrint('[FCM] aberto pela notificacao, dados: ${message.data}');
    abrirEvento(message.data[chaveEventoId]?.toString());
  }

  Future<void> _mostrarEmPrimeiroPlano(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final imagemUrl = notification.android?.imageUrl;
    final imagem = imagemUrl == null ? null : await _baixarImagem(imagemUrl);

    final android = AndroidNotificationDetails(
      canalEventos.id,
      canalEventos.name,
      channelDescription: canalEventos.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
      largeIcon: imagem == null ? null : ByteArrayAndroidBitmap(imagem),
      styleInformation: imagem == null
          ? BigTextStyleInformation(notification.body ?? '')
          : BigPictureStyleInformation(
              ByteArrayAndroidBitmap(imagem),
              contentTitle: notification.title,
              summaryText: notification.body,
              hideExpandedLargeIcon: true,
            ),
    );

    await _local.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(android: android),
      payload: message.data[chaveEventoId]?.toString(),
    );
  }

  Future<Uint8List?> _baixarImagem(String url) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != 200) return null;
      return await consolidateHttpClientResponseBytes(response);
    } catch (e) {
      debugPrint('[FCM] erro ao baixar imagem: $e');
      return null;
    } finally {
      client.close();
    }
  }
}
