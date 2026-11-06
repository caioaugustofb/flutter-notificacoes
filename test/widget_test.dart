import 'package:agenda_eventos/data/eventos.dart';
import 'package:agenda_eventos/screens/evento_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buscarEvento encontra pelo id usado na notificacao', () {
    expect(buscarEvento('workshop-firebase')?.titulo, 'Workshop de Firebase');
    expect(buscarEvento(' meetup-ux ')?.id, 'meetup-ux');
    expect(buscarEvento('nao-existe'), isNull);
    expect(buscarEvento(null), isNull);
  });

  test('ids dos eventos sao unicos', () {
    final ids = eventos.map((e) => e.id).toSet();
    expect(ids.length, eventos.length);
  });

  testWidgets('tela de detalhes mostra os dados do evento', (tester) async {
    final evento = eventos.first;
    await tester.pumpWidget(MaterialApp(home: EventoScreen(evento: evento)));

    expect(find.text(evento.titulo), findsOneWidget);
    expect(find.text(evento.local), findsOneWidget);
    expect(find.text(evento.descricao), findsOneWidget);
  });
}
