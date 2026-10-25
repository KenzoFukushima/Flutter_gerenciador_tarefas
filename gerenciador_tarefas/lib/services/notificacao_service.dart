import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gerenciador_tarefas/model/Tarefa.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificacaoService {
  NotificacaoService._();

  static final instance = NotificacaoService._();

  final plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  Future<void> pedirPermissao() async {
    await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> cancelarTudo() async {
    await plugin.cancelAll();
  }

  Future<void> avisarTarefasDeHoje(List<Tarefa> tarefas) async {
    final agora = DateTime.now();


    if (agora.hour < 8) return;


    final pendentes = tarefas
        .where(
          (t) =>
              !t.concluida &&
              t.prazo.year == agora.year &&
              t.prazo.month == agora.month &&
              t.prazo.day == agora.day,
        )
        .toList();


    if (pendentes.isEmpty) return;

    await plugin.show(
      id: 999,
      title: '${pendentes.length} tarefa(s) pendente(s) para hoje',
      body: pendentes.map((t) => t.titulo).join(', '),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'tarefas',
          'Tarefas',
          channelDescription: 'Lembretes de tarefas pendentes',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
