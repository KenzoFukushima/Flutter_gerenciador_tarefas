import 'package:flutter/material.dart';
import 'package:gerenciador_tarefas/dao/tarefaDao.dart';
import 'package:gerenciador_tarefas/model/Tarefa.dart';

class AddTarefa extends StatefulWidget {
  final Tarefa? tarefa;

  const AddTarefa({super.key, this.tarefa});

  @override
  State<AddTarefa> createState() => _AddTarefaState();
}

class _AddTarefaState extends State<AddTarefa> {
  final _formKey = GlobalKey<FormState>();

  final tituloController = TextEditingController();
  final descricaoController = TextEditingController();

  String _prioridade = 'Média';
  String _categoria = 'Escola';
  DateTime? _prazo;

  @override
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.tarefa != null) {
      tituloController.text = widget.tarefa!.titulo;
      descricaoController.text = widget.tarefa!.descricao;
      _prioridade = widget.tarefa!.prioridade;
      _categoria = widget.tarefa!.categoria;
      _prazo = widget.tarefa!.prazo;
    }
  }

  Future<void> salvar() async {
    if (_formKey.currentState!.validate()) {
      final tarefa = Tarefa(
        id: widget.tarefa?.id,
        titulo: tituloController.text,
        descricao: descricaoController.text,
        prioridade: _prioridade,
        categoria: _categoria,
        prazo: _prazo!,
        concluida: widget.tarefa?.concluida ?? false,
      );

      if (widget.tarefa == null) {
        await TarefaDao.instance.add(tarefa);
      } else {
        await TarefaDao.instance.update(tarefa);
      }

      Navigator.pop(context);
    }
  }

  Future<void> selecionarData() async {
    final dataSelecionada = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );

    if (dataSelecionada != null) {
      setState(() {
        _prazo = dataSelecionada;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        title: Text(
          widget.tarefa == null ? 'Adicionar tarefa' : 'Editar tarefa',
          style: const TextStyle(color: Colors.white),
        ),

        backgroundColor: Theme.of(context).colorScheme.primary,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.chevron_left_sharp, color: Colors.white),
        ),

        actions: [
          TextButton(
            onPressed: salvar,
            child: const Text("SALVAR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: ListView(
            children: [
              // TÍTULO
              TextFormField(
                controller: tituloController,

                decoration: const InputDecoration(
                  labelText: "Título",
                  hintText: "Digite o título da tarefa",
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Digite o título da tarefa";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // DESCRIÇÃO
              TextFormField(
                controller: descricaoController,

                maxLines: 5,

                decoration: const InputDecoration(
                  labelText: "Descrição",
                  hintText: "Digite a descrição da tarefa",
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Digite a descrição";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // PRIORIDADE
              DropdownButtonFormField<String>(
                initialValue: _prioridade,

                decoration: const InputDecoration(
                  labelText: 'Prioridade',
                  border: OutlineInputBorder(),
                ),

                items: const [
                  DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                  DropdownMenuItem(value: 'Média', child: Text('Média')),
                  DropdownMenuItem(value: 'Baixa', child: Text('Baixa')),
                ],

                onChanged: (value) {
                  setState(() {
                    _prioridade = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // CATEGORIA
              DropdownButtonFormField<String>(
                initialValue: _categoria,

                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),

                items: const [
                  DropdownMenuItem(value: 'Escola', child: Text('Escola')),
                  DropdownMenuItem(value: 'Estudos', child: Text('Estudos')),
                  DropdownMenuItem(value: 'Pessoal', child: Text('Trabalho')),
                ],

                onChanged: (value) {
                  setState(() {
                    _categoria = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // PRAZO
              TextFormField(
                readOnly: true,

                decoration: InputDecoration(
                  labelText: "Prazo",
                  hintText: "Selecione uma data",
                  border: const OutlineInputBorder(),

                  suffixIcon: IconButton(
                    onPressed: selecionarData,
                    icon: const Icon(Icons.calendar_month),
                  ),
                ),

                controller: TextEditingController(
                  text: _prazo == null
                      ? ''
                      : '${_prazo!.day.toString().padLeft(2, '0')}/'
                            '${_prazo!.month.toString().padLeft(2, '0')}/'
                            '${_prazo!.year}',
                ),

                validator: (value) {
                  if (_prazo == null) {
                    return "Selecione um prazo";
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
