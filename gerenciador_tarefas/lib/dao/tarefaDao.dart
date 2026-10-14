import 'package:gerenciador_tarefas/database/database_helper.dart';
import 'package:gerenciador_tarefas/model/Tarefa.dart';
import 'package:sqflite/sqflite.dart';

class TarefaDao {
  TarefaDao._();

  static final TarefaDao instance = TarefaDao._();

Future<List<Tarefa>> getTarefas(int usuarioId) async {
  Database db = await DatabaseHelper.instance.database;

  // LEFT JOIN: traz o nome atual da categoria (caso tenha sido renomeada).
  var tarefas = await db.rawQuery('''
    SELECT t.*, c.nome AS categoria_nome
    FROM tarefas t
    LEFT JOIN categorias c ON c.id = t.categoria_id
    WHERE t.usuario_id = ?
    ORDER BY t.id DESC
  ''', [usuarioId]);

  List<Tarefa> tarefaList = tarefas.isNotEmpty
      ? tarefas.map((item) => Tarefa.fromMap(item)).toList()
      : [];

  return tarefaList;
}

  // C - Create
  Future<int> add(Tarefa novaTarefa) async {
    Database db = await DatabaseHelper.instance.database;

    return await db.insert('tarefas', novaTarefa.toMap());
  }

  // D - Delete
  Future<int> remove(Tarefa tarefa) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete('tarefas', where: 'id = ?', whereArgs: [tarefa.id]);
  }

  // U - Update
  Future<int> update(Tarefa tarefa) async {
    Database db = await DatabaseHelper.instance.database;

    return await db.update(
      'tarefas',
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }
}
