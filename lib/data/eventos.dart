/// Dados fixos do app. A atividade permite definir os dados no codigo,
/// sem banco nem backend.
class Evento {
  const Evento({
    required this.id,
    required this.titulo,
    required this.categoria,
    required this.data,
    required this.horario,
    required this.local,
    required this.resumo,
    required this.descricao,
    required this.imagemUrl,
  });

  /// Identificador usado no campo `evento_id` dos dados da notificacao.
  final String id;
  final String titulo;
  final String categoria;
  final String data;
  final String horario;
  final String local;
  final String resumo;
  final String descricao;
  final String imagemUrl;
}

String _unsplash(String foto) =>
    'https://images.unsplash.com/$foto?w=800&q=70&fm=jpg';

final List<Evento> eventos = [
  Evento(
    id: 'flutter-day',
    titulo: 'Flutter Day Belém',
    categoria: 'Conferência',
    data: '21/11/2026',
    horario: '09:00 às 18:00',
    local: 'Auditório do CESUPA - Belém',
    resumo: 'Um dia inteiro de palestras sobre Flutter e mobile.',
    descricao:
        'Palestras sobre arquitetura de apps Flutter, gerenciamento de estado, '
        'testes e publicação. No fim do dia tem um painel com desenvolvedores '
        'de empresas de Belém contando como usam Flutter em produção.',
    imagemUrl: _unsplash('photo-1540575467063-178a50c2df87'),
  ),
  Evento(
    id: 'hackathon-amazonia',
    titulo: 'Hackathon Amazônia Digital',
    categoria: 'Hackathon',
    data: '28/11/2026',
    horario: '08:00 (48 horas)',
    local: 'Estação das Docas - Belém',
    resumo: '48 horas para criar soluções para problemas da região.',
    descricao:
        'Equipes de até 5 pessoas desenvolvem soluções para mobilidade urbana, '
        'meio ambiente e economia local. Mentoria durante todo o evento e '
        'premiação para os três primeiros lugares.',
    imagemUrl: _unsplash('photo-1504384308090-c894fdcc538d'),
  ),
  Evento(
    id: 'workshop-firebase',
    titulo: 'Workshop de Firebase',
    categoria: 'Workshop',
    data: '03/12/2026',
    horario: '19:00 às 22:00',
    local: 'Laboratório 4 - CESUPA',
    resumo: 'Mão na massa com Auth, Firestore e Cloud Messaging.',
    descricao:
        'Workshop prático: autenticação, banco em tempo real com Firestore e '
        'envio de notificações push com Firebase Cloud Messaging. Traga o '
        'notebook com o Flutter instalado.',
    imagemUrl: _unsplash('photo-1517245386807-bb43f82c33c4'),
  ),
  Evento(
    id: 'meetup-ux',
    titulo: 'Meetup UX/UI Pará',
    categoria: 'Meetup',
    data: '10/12/2026',
    horario: '18:30 às 21:00',
    local: 'Coworking Ver-o-Peso - Belém',
    resumo: 'Conversa sobre design de produto e acessibilidade.',
    descricao:
        'Encontro mensal da comunidade de design do Pará. Nesta edição: '
        'acessibilidade em apps mobile e como validar protótipos com usuários '
        'reais. Networking com café regional no final.',
    imagemUrl: _unsplash('photo-1531482615713-2afd69097998'),
  ),
  Evento(
    id: 'ia-amazonia',
    titulo: 'Palestra: IA na Amazônia',
    categoria: 'Palestra',
    data: '15/12/2026',
    horario: '19:00 às 20:30',
    local: 'Teatro Margarida Schivasappa - Belém',
    resumo: 'Como a inteligência artificial ajuda a monitorar a floresta.',
    descricao:
        'Pesquisadores mostram projetos que usam visão computacional e imagens '
        'de satélite para detectar desmatamento e queimadas em tempo quase '
        'real. Sessão de perguntas no final.',
    imagemUrl: _unsplash('photo-1677442136019-21780ecad995'),
  ),
];

Evento? buscarEvento(String? id) {
  if (id == null) return null;
  for (final evento in eventos) {
    if (evento.id == id.trim()) return evento;
  }
  return null;
}
