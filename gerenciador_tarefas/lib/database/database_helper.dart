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
      nome TEXT NOT NULL
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
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON UPDATE CASCADE
        categoria_id INTEGER, 
        FOREIGN KEY (categoria_id) REFERENCES categorias (id) ON UPDATE CASCADE
      )
    ''');
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
