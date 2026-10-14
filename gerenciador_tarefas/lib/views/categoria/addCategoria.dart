import 'package:flutter/material.dart';
import 'package:gerenciador_tarefas/dao/CategoriaDao.dart';
import 'package:gerenciador_tarefas/model/Categoria.dart';

class AddCategoria extends StatefulWidget {
  final Categoria? categoria;
  const AddCategoria({super.key, this.categoria});

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
      id: widget.categoria?.id,
      nome: nomeController.text.trim(),
    );

    if (widget.categoria == null) {
      await CategoriaDao.instance.add(categoria);
    } else {
      await CategoriaDao.instance.update(categoria);
    }

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

    if(widget.categoria != null) {
      nomeController.text = widget.categoria!.nome;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( widget.categoria == null ? 'Nova Categoria' : 'Editar Categoria'),
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
              child: Text(widget.categoria == null ? 'Cadastrar' : 'Editar' ),
            ),
          ],
        ),
      ),
    );
  }
}