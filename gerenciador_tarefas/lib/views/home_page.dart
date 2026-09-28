import 'package:flutter/material.dart';
import 'package:gerenciador_tarefas/dao/tarefaDao.dart';
import 'package:gerenciador_tarefas/model/Tarefa.dart';
import 'package:gerenciador_tarefas/views/add_tarefa.dart';
import 'package:gerenciador_tarefas/views/tarefa_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Tarefa> tarefas = [];

  @override
  void initState() {
    super.initState();
    carregarTarefas();
  }

  Future<void> carregarTarefas() async {
    final lista = await TarefaDao.instance.getTarefas();

    setState(() {
      tarefas = lista;
    });
  }

  String filtro = 'todas';
  List<Tarefa> get tarefasFiltradas {
    if (filtro == 'Pendentes') {
      return tarefas.where((tarefa) => !tarefa.concluida).toList();
    }

    if (filtro == 'Concluídas') {
      return tarefas.where((tarefa) => tarefa.concluida).toList();
    }

    return tarefas;
  }

  Future<void> deleteTarefa(Tarefa tarefa) async {
    await TarefaDao.instance.remove(tarefa);
    await carregarTarefas();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Minhas Tarefas",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 1.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        filtro = 'Todas';
                      });
                    },
                    child: Text(
                      'Todas',
                      style: TextStyle(
                        color: filtro == 'Todas'
                            ? colors.primary
                            : colors.onSurface,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        filtro = 'Pendentes';
                      });
                    },
                    child: Text(
                      "Pendentes",
                      style: TextStyle(
                        color: filtro == 'Pendentes'
                            ? colors.primary
                            : colors.onSurface,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        filtro = 'Concluídas';
                      });
                    },
                    child: Text(
                      "Concluídas",
                      style: TextStyle(
                        color: filtro == 'Concluídas'
                            ? colors.primary
                            : colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          //item
          if (tarefasFiltradas.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  "Não possui tarefas na categoria: $filtro",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: tarefasFiltradas.length,

                itemBuilder: (context, index) {
                  Tarefa currentTarefa = tarefasFiltradas[index];

                  return TarefaItem(
                    tarefa: currentTarefa,
                    deleteItem: () => deleteTarefa(currentTarefa),
                    editItem: () => carregarTarefas(),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTarefa()),
          );

          carregarTarefas();
        },

        child: const Icon(Icons.add),
      ),
    );
  }
}
