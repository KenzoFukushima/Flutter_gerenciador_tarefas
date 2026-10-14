import 'package:gerenciador_tarefas/database/database_helper.dart';
import 'package:gerenciador_tarefas/model/Categoria.dart';
import 'package:sqflite/sqflite.dart';

class CategoriaDao {
  CategoriaDao._();

  static final CategoriaDao instance = CategoriaDao._();

  Future<List<Categoria>> getCategorias(int usuarioId) async {
    Database db = await DatabaseHelper.instance.database;

    final categorias = await db.query(
      'categorias',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'id DESC',
    );

    return categorias
        .map((item) => Categoria.fromMap(item))
        .toList();
  }


  Future<int> add(Categoria novaCategoria) async {
    Database db = await DatabaseHelper.instance.database;

    return await db.insert(
      'categorias',
      novaCategoria.toMap(),
    );
  }

  Future<int> remove(Categoria categoria) async {
    Database db = await DatabaseHelper.instance.database;

    // As tarefas que usavam a categoria ficam sem categoria (mantêm o nome).
    return await db.transaction((txn) async {
      await txn.update(
        'tarefas',
        {'categoria_id': null},
        where: 'categoria_id = ?',
        whereArgs: [categoria.id],
      );

      return await txn.delete(
        'categorias',
        where: 'id = ? AND usuario_id = ?',
        whereArgs: [categoria.id, categoria.usuarioId],
      );
    });
  }


  Future<int> update(Categoria categoria) async {
    Database db = await DatabaseHelper.instance.database;

    return await db.update(
      'categorias',
      categoria.toMap(),
      where: 'id = ? AND usuario_id = ?',
      whereArgs: [categoria.id, categoria.usuarioId],
    );
  }
}
