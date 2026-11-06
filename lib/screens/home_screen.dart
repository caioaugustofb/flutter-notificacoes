import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../data/eventos.dart';
import '../services/notification_service.dart';
import 'evento_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda Tech Belém')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _TokenCard(),
          const SizedBox(height: 24),
          Text(
            'Próximos eventos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final evento in eventos) _EventoTile(evento: evento),
        ],
      ),
    );
  }
}

class _EventoTile extends StatelessWidget {
  const _EventoTile({required this.evento});

  final Evento evento;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            evento.imagemUrl,
            width: 72,
            height: 72,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                const SizedBox(width: 72, height: 72, child: Icon(Icons.event)),
          ),
        ),
        title: Text(evento.titulo),
        subtitle: Text('${evento.data} - ${evento.categoria}\n${evento.local}'),
        isThreeLine: true,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => EventoScreen(evento: evento))),
      ),
    );
  }
}

/// Mostra o token FCM do aparelho. O Console precisa dele para enviar a
/// "mensagem de teste" direto para este dispositivo.
class _TokenCard extends StatelessWidget {
  const _TokenCard();

  @override
  Widget build(BuildContext context) {
    final service = NotificationService.instance;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active_outlined),
                const SizedBox(width: 8),
                Text(
                  'Notificações',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder(
              valueListenable: service.permissao,
              builder: (context, status, _) =>
                  Text('Permissão: ${_descreverPermissao(status)}'),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder(
              valueListenable: service.token,
              builder: (context, token, _) {
                if (token == null) {
                  return const Text('Obtendo token FCM...');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      token,
                      maxLines: 3,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      onPressed: () => service.copiarToken(context),
                      icon: const Icon(Icons.copy),
                      label: const Text('Copiar token FCM'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _descreverPermissao(AuthorizationStatus? status) {
    return switch (status) {
      AuthorizationStatus.authorized => 'concedida',
      AuthorizationStatus.provisional => 'provisória',
      AuthorizationStatus.denied || AuthorizationStatus.deniedPermanently =>
        'negada (ative em Configurações > Apps > Agenda Tech Belém)',
      AuthorizationStatus.notDetermined => 'não definida',
      null => 'verificando...',
    };
  }
}
