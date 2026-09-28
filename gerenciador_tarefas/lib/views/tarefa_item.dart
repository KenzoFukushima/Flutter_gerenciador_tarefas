  import 'package:flutter/material.dart';
  import 'package:gerenciador_tarefas/dao/tarefaDao.dart';
  import 'package:gerenciador_tarefas/model/Tarefa.dart';
  import 'package:gerenciador_tarefas/views/add_tarefa.dart';

  class TarefaItem extends StatefulWidget {
    final Tarefa tarefa;
    final Function() deleteItem;
    final Function() editItem;
    const TarefaItem({
      super.key,
      required this.tarefa,
      required this.deleteItem,
      required this.editItem,
    });

    @override
    State<TarefaItem> createState() => _TarefaItemState();
  }

  class _TarefaItemState extends State<TarefaItem> {
    @override
    Widget build(BuildContext context) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          leading: Checkbox(
            value: widget.tarefa.concluida,

            onChanged: (value) async {
              setState(() {
                widget.tarefa.concluir();
              });

              await TarefaDao.instance.update(widget.tarefa);
            },
          ),

          title: Text(
            widget.tarefa.titulo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.tarefa.descricao),

                const SizedBox(height: 8),

                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6, // Espaçamento padrão entre ícone e texto
                  children: [
                    const Icon(Icons.flag, size: 16, color: Colors.red),
                    Text(widget.tarefa.prioridade),

                    const SizedBox(
                      width: 10,
                    ), // Espaço extra apenas entre os blocos de informação

                    const Icon(Icons.calendar_today, size: 14),
                    Text(
                      '${widget.tarefa.prazo.day}/'
                      '${widget.tarefa.prazo.month}',
                    ),

                    const SizedBox(width: 10),

                    Text(widget.tarefa.categoria),
                  ],
                ),
              ],
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
                    builder: (context) => AddTarefa(tarefa: widget.tarefa),
                  ),
                );
                widget.editItem();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'editar', child: Text('Editar')),
              const PopupMenuItem<String>(
                value: 'remover',
                child: Text('remover'),
              ),
            ],
          ),
        ),
      );
    }
  }
