import 'package:flutter/material.dart';
import 'package:gerenciador_tarefas/dao/UsuarioDao.dart';
import 'package:gerenciador_tarefas/views/pages/cadastro_page.dart';
import 'package:gerenciador_tarefas/views/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  bool ocultarSenha = true;

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> entrar() async {
    final email = emailController.text.trim();
    final senha = senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      mostrarMensagem('Preencha e-mail e senha');
      return;
    }

    final usuario = await UsuarioDao.instance.login(email, senha);

    if (!mounted) return;

    if (usuario == null) {
      mostrarMensagem('E-mail ou senha inválidos');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('usuario_id', usuario.id!);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(usuario: usuario),
      ),
    );
  }
  void mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Lottie.asset(
                'assets/animations/Task Loader.json',
                width: 250,
                height: 210,
                repeat: true,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              const Text(
                'Gerenciador de Tarefas',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
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
                obscureText: ocultarSenha,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      ocultarSenha ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => ocultarSenha = !ocultarSenha),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: entrar,
                  child: const Text('Entrar', style: TextStyle(fontSize: 17),),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CadastroPage(),
                    ),
                  );
                },
                child: const Text('Criar conta', style: TextStyle(fontSize: 17),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
