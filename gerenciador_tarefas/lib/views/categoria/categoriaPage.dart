import 'package:flutter/material.dart';
import 'package:gerenciador_tarefas/dao/CategoriaDao.dart';
import 'package:gerenciador_tarefas/model/Categoria.dart';
import 'package:gerenciador_tarefas/views/categoria_item.dart';

class CategoriaPage extends StatefulWidget {
  const CategoriaPage({super.key});

  @override
  State<CategoriaPage> createState() => _CategoriaPageState();
}

class _CategoriaPageState extends State<CategoriaPage> {
  List<Categoria> categorias = [];

  @override
  void initState() {
    super.initState();
    carregarCategorias();
  }

  Future<void> carregarCategorias() async {
    final lista = await CategoriaDao.instance.getCategorias();

    setState(() {
      categorias = lista;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
      ),
      body: ListView.builder(
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];

          return CategoriaItem(
            categoria: categoria,
            deleteItem: () {
              // remover categoria
            },
            editItem: () {
              // editar categoria
            },
          );
        },
      ),
    );
  }
}