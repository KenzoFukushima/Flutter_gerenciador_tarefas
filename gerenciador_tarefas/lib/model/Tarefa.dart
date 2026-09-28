class Tarefa {
  int? id;
  String titulo;
  String descricao;
  String prioridade;
  String categoria;
  DateTime prazo;
  bool concluida;

  Tarefa({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.prioridade,
    required this.categoria,
    required this.prazo,
    this.concluida = false,
  });

  void concluir() {
    concluida = !concluida;
  }

  factory Tarefa.fromMap(Map<String, dynamic> json) => Tarefa(
    id: json['id'],
    titulo: json['titulo'],
    descricao: json['descricao'],
    prioridade: json['prioridade'],
    categoria: json['categoria'],
    prazo: DateTime.parse(json['prazo']),
    concluida: json['concluida'] == 1,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'titulo': titulo,
    'descricao': descricao,
    'prioridade': prioridade,
    'categoria': categoria,
    'prazo': prazo.toIso8601String(),
    'concluida': concluida ? 1 : 0,
  };
}
