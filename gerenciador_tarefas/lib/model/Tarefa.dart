class Tarefa {
  int? id;
  String titulo;
  String descricao;
  String prioridade;
  String categoria; // nome da categoria (para exibição)
  int? categoriaId;
  DateTime prazo;
  bool concluida;
  int usuarioId;

  Tarefa({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.prioridade,
    required this.categoria,
    this.categoriaId,
    required this.prazo,
    this.concluida = false,
    required this.usuarioId,
  });

  void concluir() {
    concluida = !concluida;
  }

  factory Tarefa.fromMap(Map<String, dynamic> json) => Tarefa(
    id: json['id'],
    titulo: json['titulo'],
    descricao: json['descricao'],
    prioridade: json['prioridade'],
    // 'categoria_nome' vem do JOIN com categorias (nome atual); se a
    // categoria foi removida, usa o nome salvo na própria tarefa.
    categoria: (json['categoria_nome'] ?? json['categoria']) as String,
    categoriaId: json['categoria_id'] as int?,
    prazo: DateTime.parse(json['prazo']),
    concluida: json['concluida'] == 1,
    usuarioId: json['usuario_id'] as int,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'titulo': titulo,
    'descricao': descricao,
    'prioridade': prioridade,
    'categoria': categoria,
    'categoria_id': categoriaId,
    'prazo': prazo.toIso8601String(),
    'concluida': concluida ? 1 : 0,
    'usuario_id': usuarioId,
  };
}