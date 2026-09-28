import 'package:gerenciador_tarefas/database/database_helper.dart';
import 'package:gerenciador_tarefas/model/Tarefa.dart';
import 'package:sqflite/sqflite.dart';

class TarefaDao {
  TarefaDao._();

  static final TarefaDao instance = TarefaDao._();

  // R - Read
  Future<List<Tarefa>> getTarefas() async {
    Database db = await DatabaseHelper.instance.database;

    var tarefas = await db.query('tarefas', orderBy: 'id DESC');

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
