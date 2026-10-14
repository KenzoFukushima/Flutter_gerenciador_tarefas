import 'package:flutter/material.dart';
import 'package:gerenciador_tarefas/dao/UsuarioDao.dart';
import 'package:gerenciador_tarefas/model/Usuario.dart';
import 'package:lottie/lottie.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> cadastrar() async {
    final email = emailController.text.trim();
    final senha = senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      mostrarMensagem('Preencha e-mail e senha');
      return;
    }

    if (await UsuarioDao.instance.emailExiste(email)) {
      mostrarMensagem('Esse e-mail já está cadastrado');
      return;
    }

    await UsuarioDao.instance.add(Usuario(email: email, senha: senha));

    if (!mounted) return;

    mostrarMensagem('Conta criada! Faça login.');
    Navigator.pop(context);
  }

  void mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/Task Loader.json',
              width: 250,
              height: 210,
              repeat: true,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: cadastrar,
                child: const Text('Cadastrar', style: TextStyle(fontSize: 17)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
