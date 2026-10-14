import 'package:flutter/material.dart';
import 'package:gerenciador_tarefas/dao/CategoriaDao.dart';
import 'package:gerenciador_tarefas/model/Categoria.dart';

class AddCategoria extends StatefulWidget {
  const AddCategoria({super.key});

  @override
  State<AddCategoria> createState() => _AddCategoriaState();
}

class _AddCategoriaState extends State<AddCategoria> {
  final TextEditingController nomeController = TextEditingController();

  Future<void> salvar() async {
    if (nomeController.text.trim().isEmpty) {
      return;
    }

    final categoria = Categoria(
      nome: nomeController.text.trim(),
    );

    await CategoriaDao.instance.add(categoria);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Categoria'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome da categoria',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: salvar,
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}