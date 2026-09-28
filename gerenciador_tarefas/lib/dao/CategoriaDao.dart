import 'package:gerenciador_tarefas/database/database_helper.dart';
import 'package:gerenciador_tarefas/model/Categoria.dart';
import 'package:sqflite/sqflite.dart';

class CategoriaDao {
  CategoriaDao._();

  static final CategoriaDao instance = CategoriaDao._();

  // R - Read
  Future<List<Categoria>> getCategorias() async {
    Database db = await DatabaseHelper.instance.database;

    final categorias = await db.query(
      'categorias',
      orderBy: 'id DESC',
    );

    return categorias
        .map((item) => Categoria.fromMap(item))
        .toList();
  }

  // C - Create
  Future<int> add(Categoria novaCategoria) async {
    Database db = await DatabaseHelper.instance.database;

    return await db.insert(
      'categorias',
      novaCategoria.toMap(),
    );
  }

  // D - Delete
  Future<int> remove(Categoria categoria) async {
    Database db = await DatabaseHelper.instance.database;

    return await db.delete(
      'categorias',
      where: 'id = ?',
      whereArgs: [categoria.id],
    );
  }

  // U - Update
  Future<int> update(Categoria categoria) async {
    Database db = await DatabaseHelper.instance.database;

    return await db.update(
      'categorias',
      categoria.toMap(),
      where: 'id = ?',
      whereArgs: [categoria.id],
    );
  }
}
