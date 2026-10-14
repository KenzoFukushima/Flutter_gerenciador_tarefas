import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  static const int _version = 2;
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

  // v1 -> v2: categorias passam a pertencer a um usuário.
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE categorias ADD COLUMN usuario_id INTEGER '
        'REFERENCES usuarios (id) ON DELETE CASCADE ON UPDATE CASCADE',
      );

      // As categorias antigas eram globais: cada usuário existente recebe
      // uma cópia delas, e as originais (sem dono) são removidas.
      await db.execute('''
        INSERT INTO categorias (nome, usuario_id)
        SELECT c.nome, u.id
        FROM categorias c CROSS JOIN usuarios u
        WHERE c.usuario_id IS NULL
      ''');
      await db.execute('''
        UPDATE tarefas SET categoria_id = NULL
        WHERE categoria_id IN (SELECT id FROM categorias WHERE usuario_id IS NULL)
      ''');
      await db.execute('DELETE FROM categorias WHERE usuario_id IS NULL');

      final usuarios = await db.query('usuarios', columns: ['id']);
      for (final usuario in usuarios) {
        await criarCategoriasPadrao(db, usuario['id'] as int);
      }

      // Liga as tarefas existentes à categoria do dono pelo nome.
      await db.execute('''
        UPDATE tarefas SET categoria_id = (
          SELECT c.id FROM categorias c
          WHERE c.usuario_id = tarefas.usuario_id AND c.nome = tarefas.categoria
          LIMIT 1
        )
        WHERE categoria_id IS NULL
      ''');
    }
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
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
      version: _version,
    );
  }
}
