import 'package:flutter/material.dart';
import 'package:gerenciador_tarefas/app_drawer.dart';
import 'package:gerenciador_tarefas/dao/CategoriaDao.dart';
import 'package:gerenciador_tarefas/model/Categoria.dart';
import 'package:gerenciador_tarefas/model/Usuario.dart';
import 'package:gerenciador_tarefas/views/categoria/addCategoria.dart';
import 'package:gerenciador_tarefas/views/categoria/categoria_item.dart';

class CategoriaPage extends StatefulWidget {
  final Usuario usuario;

  const CategoriaPage({
    super.key,
    required this.usuario,
  });

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
    final lista = await CategoriaDao.instance.getCategorias(widget.usuario.id!);

    setState(() {
      categorias = lista;
    });
  }

  Future<void> deleteCategoria(Categoria categoria) async {
    await CategoriaDao.instance.remove(categoria);
    await carregarCategorias();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
        title: const Text(
          'Categorias',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      drawer: AppDrawer(atual: 'categorias', usuario: widget.usuario,),
      body: ListView.builder(
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];

          return CategoriaItem(
            categoria: categoria,
            usuario: widget.usuario,
            deleteItem: () => deleteCategoria(categoria),
            editItem: () => carregarCategorias(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCategoria(usuario: widget.usuario),
            ),
          );

          carregarCategorias();
        },

        child: const Icon(Icons.add),
      ),
    );
  }
}