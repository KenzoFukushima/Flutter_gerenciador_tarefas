  class Categoria {
    int? id;
    String nome;


    Categoria({
      this.id,
      required this.nome,
    });

    factory Categoria.fromMap(Map<String, dynamic> json) => Categoria(
      id: json['id'],
      nome: json['nome'],
    );

    Map<String, dynamic> toMap() => {
      'id': id,
      'nome': nome,
    };
  }
