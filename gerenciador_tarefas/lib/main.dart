import 'package:flutter/material.dart';
import 'package:gerenciador_tarefas/services/notificacao_service.dart';
import 'package:gerenciador_tarefas/views/pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificacaoService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const LoginPage(),
    );
  }
}
