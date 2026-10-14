import 'package:flutter/material.dart';
import 'package:gerenciador_tarefas/dao/CategoriaDao.dart';
import 'package:gerenciador_tarefas/dao/tarefaDao.dart';
import 'package:gerenciador_tarefas/model/Categoria.dart';
import 'package:gerenciador_tarefas/model/Tarefa.dart';
import 'package:gerenciador_tarefas/model/Usuario.dart';

class AddTarefa extends StatefulWidget {
  final Tarefa? tarefa;
  final Usuario usuario;

  const AddTarefa({super.key, this.tarefa, required this.usuario});

  @override
  State<AddTarefa> createState() => _AddTarefaState();
}

class _AddTarefaState extends State<AddTarefa> {
  final _formKey = GlobalKey<FormState>();

  final tituloController = TextEditingController();
  final descricaoController = TextEditingController();

  String _prioridade = 'Média';
  List<Categoria> _categorias = [];
  int? _categoriaId;
  bool _carregandoCategorias = true;
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
      _categoriaId = widget.tarefa!.categoriaId;
      _prazo = widget.tarefa!.prazo;
    }

    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    final lista = await CategoriaDao.instance.getCategorias(widget.usuario.id!);

    if (!mounted) return;

    setState(() {
      _categorias = lista;

      // A categoria da tarefa pode ter sido removida (ou ser de antes das
      // categorias por usuário): nesse caso a pessoa escolhe de novo.
      if (!lista.any((c) => c.id == _categoriaId)) {
        _categoriaId = null;
      }

      _carregandoCategorias = false;
    });
  }

  Future<void> salvar() async {
    if (_formKey.currentState!.validate()) {
      final categoriaSelecionada = _categorias
          .where((c) => c.id == _categoriaId)
          .firstOrNull;

      if (categoriaSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastre e selecione uma categoria para a tarefa'),
          ),
        );
        return;
      }

      final tarefa = Tarefa(
        id: widget.tarefa?.id,
        titulo: tituloController.text,
        descricao: descricaoController.text,
        prioridade: _prioridade,
        categoria: categoriaSelecionada.nome,
        categoriaId: categoriaSelecionada.id,
        prazo: _prazo!,
        concluida: widget.tarefa?.concluida ?? false,
        usuarioId: widget.usuario.id!,
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

              // CATEGORIA (apenas as categorias do usuário logado)
              if (_carregandoCategorias)
                const Center(child: CircularProgressIndicator())
              else if (_categorias.isEmpty)
                const Text(
                  'Você ainda não tem categorias. Cadastre uma no menu '
                  '"Categorias" para poder criar tarefas.',
                  style: TextStyle(color: Colors.grey),
                )
              else
                DropdownButtonFormField<int>(
                  initialValue: _categoriaId,

                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),

                  items: _categorias
                      .map(
                        (c) => DropdownMenuItem<int>(
                          value: c.id,
                          child: Text(c.nome),
                        ),
                      )
                      .toList(),

                  onChanged: (value) {
                    setState(() {
                      _categoriaId = value;
                    });
                  },

                  validator: (value) {
                    if (value == null) {
                      return 'Selecione uma categoria';
                    }

                    return null;
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
