import 'package:flutter/material.dart';
import 'package:gerenciador_tarefas/dao/UsuarioDao.dart';
import 'package:gerenciador_tarefas/model/Usuario.dart';
import 'package:gerenciador_tarefas/services/notificacao_service.dart';
import 'package:gerenciador_tarefas/views/pages/home_page.dart';
import 'package:gerenciador_tarefas/views/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificacaoService.instance.init();

  final prefs = await SharedPreferences.getInstance();
  final id = prefs.getInt('usuario_id');
  final usuario = id == null ? null : await UsuarioDao.instance.getPorId(id);

  runApp(MyApp(usuario: usuario));
}

class MyApp extends StatelessWidget {
  final Usuario? usuario;

  const MyApp({super.key, this.usuario});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: usuario == null ? const LoginPage() : HomePage(usuario: usuario!),
    );
  }
}