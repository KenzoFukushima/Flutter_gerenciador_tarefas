import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:gerenciador_tarefas/database/database_helper.dart';
import 'package:gerenciador_tarefas/model/Usuario.dart';
import 'package:sqflite/sqflite.dart';

class UsuarioDao {
  UsuarioDao._();

  static final UsuarioDao instance = UsuarioDao._();

  String _hashSenha(String senha) {
    return sha256.convert(utf8.encode(senha)).toString();
  }

  // C - Create
  Future<int> add(Usuario novoUsuario) async {
    Database db = await DatabaseHelper.instance.database;

    Usuario usuario = Usuario(
      email: novoUsuario.email,
      senha: _hashSenha(novoUsuario.senha),
    );

    return await db.insert(
      'usuarios',
      usuario.toMap(),
    );
  }

  // Login
  Future<Usuario?> login(String email, String senha) async {
    Database db = await DatabaseHelper.instance.database;

    String senhaHash = _hashSenha(senha);

    var usuarios = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senhaHash],
    );

    if (usuarios.isNotEmpty) {
      return Usuario.fromMap(usuarios.first);
    }

    return null;
  }

  // Verifica se o e-mail já existe
  Future<bool> emailExiste(String email) async {
    Database db = await DatabaseHelper.instance.database;

    var usuarios = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );

    return usuarios.isNotEmpty;
  }
}
