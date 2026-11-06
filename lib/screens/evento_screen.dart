import 'package:flutter/material.dart';

import '../data/eventos.dart';

class EventoScreen extends StatelessWidget {
  const EventoScreen({super.key, required this.evento});

  final Evento evento;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(evento.categoria)),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              evento.imagemUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: Colors.black12,
                child: Center(child: Icon(Icons.event, size: 64)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(evento.titulo, style: textTheme.headlineSmall),
                const SizedBox(height: 16),
                _Info(icon: Icons.calendar_today, texto: evento.data),
                _Info(icon: Icons.schedule, texto: evento.horario),
                _Info(icon: Icons.place_outlined, texto: evento.local),
                const SizedBox(height: 16),
                Text(evento.resumo, style: textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(evento.descricao, style: textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.texto});

  final IconData icon;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}
