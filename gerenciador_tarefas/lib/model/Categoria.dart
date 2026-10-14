class Categoria {
  int? id;
  String nome;
  int usuarioId;

  Categoria({
    this.id,
    required this.nome,
    required this.usuarioId,
  });

  factory Categoria.fromMap(Map<String, dynamic> json) => Categoria(
    id: json['id'],
    nome: json['nome'],
    usuarioId: json['usuario_id'] as int,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nome': nome,
    'usuario_id': usuarioId,
  };
}
