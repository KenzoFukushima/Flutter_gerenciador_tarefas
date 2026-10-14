import 'package:flutter/material.dart';
import 'package:gerenciador_tarefas/model/Categoria.dart';
import 'package:gerenciador_tarefas/views/categoria/addCategoria.dart';

class CategoriaItem extends StatefulWidget {
  final Categoria categoria;
  final Function() deleteItem;
  final Function() editItem;

  const CategoriaItem({
    super.key,
    required this.categoria,
    required this.deleteItem,
    required this.editItem,
  });

  @override
  State<CategoriaItem> createState() => _CategoriaItemState();
}

class _CategoriaItemState extends State<CategoriaItem> {


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: 
      
        ListTile(
          leading: const Icon(
            Icons.category,
            color: Colors.blue,
          ),

          title: Text(
            widget.categoria.nome,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'remover') {
                widget.deleteItem();
              }

              if (value == 'editar') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddCategoria(
                      categoria: widget.categoria,
                    ),
                  ),
                );
                widget.editItem();
              }
            },
            itemBuilder: (BuildContext context) => const [
              PopupMenuItem<String>(
                value: 'editar',
                child: Text('Editar'),
              ),
              PopupMenuItem<String>(
                value: 'remover',
                child: Text('Remover'),
              ),
            ],
          ),
        ),
    );
  }
}
