import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gerenciador_tarefas/model/Tarefa.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Notificação diária com as tarefas pendentes que vencem no dia.
///
/// Como funciona:
///  - Todo dia às [_horaDoResumo]h chega uma notificação listando as tarefas
///    NÃO concluídas cujo prazo é aquele dia.
///  - Para o conteúdo refletir a realidade, o app agenda os próximos
///    [_diasAgendados] dias sempre que a lista de tarefas muda (login, criar,
///    editar, remover ou concluir uma tarefa).
///  - Se o usuário entra no app depois do horário do resumo, a notificação de
///    hoje é exibida na hora (uma vez por login).
///  - Ao sair da conta, tudo é cancelado (as notificações são por usuário).
class NotificacaoService {
  NotificacaoService._();

  static final NotificacaoService instance = NotificacaoService._();

  static const int _horaDoResumo = 8;
  static const int _diasAgendados = 7;
  static const int _idBase = 1000; // ids 1000..1006 = próximos 7 dias
  static const int _idAvisoImediato = 999;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _inicializado = false;
  bool _permissaoPedida = false;
  bool _avisoDeHojeFeito = false;

  Future<void> init() async {
    if (_inicializado) return;

    try {
      tzdata.initializeTimeZones();

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _plugin.initialize(
        settings: const InitializationSettings(android: android),
      );

      _inicializado = true;
    } catch (e) {
      // Ex.: plataforma sem suporte. O app segue funcionando sem notificações.
      debugPrint('Notificações indisponíveis: $e');
    }
  }

  /// Android 13+ exige permissão em tempo de execução. Pede só uma vez por
  /// execução do app.
  Future<void> pedirPermissao() async {
    if (!_inicializado || _permissaoPedida) return;
    _permissaoPedida = true;

    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('Erro ao pedir permissão de notificação: $e');
    }
  }

  /// (Re)agenda os resumos dos próximos dias com base na lista atual.
  Future<void> agendarResumos(List<Tarefa> tarefas) async {
    if (!_inicializado) return;

    try {
      final agora = DateTime.now();

      for (var i = 0; i < _diasAgendados; i++) {
        final id = _idBase + i;
        await _plugin.cancel(id: id);

        final dia = DateTime(agora.year, agora.month, agora.day + i);
        final horario = DateTime(dia.year, dia.month, dia.day, _horaDoResumo);
        if (!horario.isAfter(agora)) continue;

        final pendentes = _pendentesDoDia(tarefas, dia);
        if (pendentes.isEmpty) continue;

        // O agendamento é por instante absoluto (data/hora já calculada no
        // fuso do aparelho pelo DateTime do Dart). Por isso o instante é
        // passado em UTC e não é preciso descobrir o fuso do aparelho.
        final utc = horario.toUtc();

        await _plugin.zonedSchedule(
          id: id,
          title: _titulo(pendentes.length),
          body: _resumo(pendentes),
          scheduledDate: tz.TZDateTime.utc(
            utc.year,
            utc.month,
            utc.day,
            utc.hour,
            utc.minute,
          ),
          notificationDetails: _detalhes(pendentes),
          // Aproximado: não exige a permissão de "alarmes exatos".
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (e) {
      debugPrint('Erro ao agendar notificações: $e');
    }
  }

  /// Se o usuário abriu o app depois do horário do resumo, mostra o resumo de
  /// hoje agora. Só acontece uma vez por login.
  Future<void> avisarTarefasDeHoje(List<Tarefa> tarefas) async {
    if (!_inicializado || _avisoDeHojeFeito) return;
    _avisoDeHojeFeito = true;

    final agora = DateTime.now();
    final horario = DateTime(agora.year, agora.month, agora.day, _horaDoResumo);
    if (agora.isBefore(horario)) return; // o resumo agendado cobre este caso

    final pendentes = _pendentesDoDia(tarefas, agora);
    if (pendentes.isEmpty) return;

    try {
      await _plugin.show(
        id: _idAvisoImediato,
        title: _titulo(pendentes.length),
        body: _resumo(pendentes),
        notificationDetails: _detalhes(pendentes),
      );
    } catch (e) {
      debugPrint('Erro ao exibir notificação: $e');
    }
  }

  /// Chamar ao sair da conta.
  Future<void> cancelarTudo() async {
    _avisoDeHojeFeito = false;
    if (!_inicializado) return;

    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('Erro ao cancelar notificações: $e');
    }
  }

  List<Tarefa> _pendentesDoDia(List<Tarefa> tarefas, DateTime dia) {
    return tarefas
        .where(
          (t) =>
              !t.concluida &&
              t.prazo.year == dia.year &&
              t.prazo.month == dia.month &&
              t.prazo.day == dia.day,
        )
        .toList();
  }

  String _titulo(int quantidade) => quantidade == 1
      ? '1 tarefa pendente para hoje'
      : '$quantidade tarefas pendentes para hoje';

  // Texto da notificação recolhida: títulos separados por vírgula.
  String _resumo(List<Tarefa> pendentes) =>
      pendentes.map((t) => t.titulo).join(', ');

  // Texto da notificação expandida: um título por linha (máx. 5).
  String _listaExpandida(List<Tarefa> pendentes) {
    final linhas = pendentes.take(5).map((t) => '• ${t.titulo}').toList();
    final restantes = pendentes.length - linhas.length;
    if (restantes > 0) linhas.add('e mais $restantes...');
    return linhas.join('\n');
  }

  NotificationDetails _detalhes(List<Tarefa> pendentes) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'tarefas_do_dia',
        'Tarefas do dia',
        channelDescription: 'Resumo diário das tarefas pendentes',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(_listaExpandida(pendentes)),
      ),
    );
  }
}
