import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gerenciador_tarefas/model/Usuario.dart';
import 'package:gerenciador_tarefas/views/categoria/categoriaPage.dart';
import 'package:gerenciador_tarefas/views/pages/home_page.dart';
import 'package:gerenciador_tarefas/views/pages/login_page.dart';

class AppDrawer extends StatelessWidget {
  final String atual;
  final Usuario usuario;

  const AppDrawer({
    super.key,
    required this.atual,
    required this.usuario,
  });

  void _ir(BuildContext context, String destino, Widget pagina) {
  Navigator.pop(context);

  if (atual != destino) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => pagina),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colors.primary),
            child: const Text(
              'Menu Principal',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.assignment_turned_in_outlined),
            title: const Text('Tarefas'),
            selected: atual == 'tarefas',
            onTap: () => _ir(context, 'tarefas', HomePage(usuario: usuario)),
          ),
          ListTile(
            leading: const Icon(Icons.assessment_outlined),
            title: const Text('Categorias'),
            selected: atual == 'categorias',
            onTap: () => _ir(context, 'categorias',  CategoriaPage(usuario: usuario)),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}