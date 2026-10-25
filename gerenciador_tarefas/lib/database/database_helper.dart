import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  static const int _version = 1;
  static const String _dbName = 'tarefas_db.db';

  // Categorias que todo usuário recebe ao criar a conta.
  static const List<String> categoriasPadrao = [
    'Escola',
    'Estudos',
    'Trabalho',
  ];

  Future _createDb(Database db, int version) async {
    await db.execute('''
    CREATE TABLE usuarios
      (id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT NOT NULL,
      senha TEXT NOT NULL
      )''');

    await db.execute('''
    CREATE TABLE categorias
      (id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      usuario_id INTEGER NOT NULL,
      FOREIGN KEY (usuario_id)
        REFERENCES usuarios (id) ON DELETE CASCADE ON UPDATE CASCADE
      )''');

    await db.execute('''
      CREATE TABLE tarefas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descricao TEXT NOT NULL,
        prioridade TEXT NOT NULL,
        categoria TEXT NOT NULL,
        prazo TEXT NOT NULL,
        concluida INTEGER NOT NULL,
        usuario_id INTEGER,
        categoria_id INTEGER,
        FOREIGN KEY (usuario_id)
          REFERENCES usuarios (id) ON UPDATE CASCADE,
        FOREIGN KEY (categoria_id)
          REFERENCES categorias (id) ON UPDATE CASCADE
      )
    ''');
  }

  /// Cria as categorias padrão do usuário (só as que ele ainda não tem).
  static Future<void> criarCategoriasPadrao(
    DatabaseExecutor db,
    int usuarioId,
  ) async {
    for (final nome in categoriasPadrao) {
      await db.rawInsert('''
        INSERT INTO categorias (nome, usuario_id)
        SELECT ?, ?
        WHERE NOT EXISTS (
          SELECT 1 FROM categorias WHERE usuario_id = ? AND nome = ?
        )
      ''', [nome, usuarioId, usuarioId, nome]);
    }
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDir = await getApplicationCacheDirectory();
    String path = join(documentsDir.path, _dbName);

    return openDatabase(
      path,
      onCreate: _createDb,
      onConfigure: _onConfigure,
      version: _version,
    );
  }
}