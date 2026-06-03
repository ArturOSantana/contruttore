import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:injectable/injectable.dart';

// Handler para mensagens em background (top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}

@lazySingleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications;
  final FirebaseMessaging _firebaseMessaging;

  // Callback para quando usuário toca na notificação
  Function(String?)? onNotificationTap;

  NotificationService(this._localNotifications, this._firebaseMessaging);

  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    // Inicializar timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

    // Configurar notificações locais
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Criar canal de notificação (Android)
    await _createNotificationChannel();

    // Configurar Firebase Messaging
    await _setupFirebaseMessaging();

    // Solicitar permissão
    await requestPermission();
  }

  /// Cria canal de notificação no Android
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'costruttore_channel',
      'Costruttore',
      description: 'Notificações do Costruttore',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Configura listeners do Firebase Messaging
  Future<void> _setupFirebaseMessaging() async {
    // Handler para mensagens em background
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handler para mensagens quando app está em foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handler para quando usuário toca na notificação (app em background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Verificar se app foi aberto por uma notificação
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// Solicita permissão para notificações
  Future<bool> requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Obtém o FCM token do dispositivo
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Erro ao obter FCM token: $e');
      return null;
    }
  }

  /// Agenda notificação local
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      // Não agendar se a data já passou
      if (tzScheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        print('Data de agendamento no passado, ignorando: $scheduledDate');
        return;
      }

      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'costruttore_channel',
            'Costruttore',
            channelDescription: 'Notificações do Costruttore',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_notification',
            color: Color(0xFFBF5942),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      print('Notificação agendada: $title para $scheduledDate');
    } catch (e) {
      print('Erro ao agendar notificação: $e');
    }
  }

  /// Cancela notificação específica
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancela todas as notificações
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Lista notificações pendentes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  /// Handler para mensagens em foreground
  void _handleForegroundMessage(RemoteMessage message) {
    print('Mensagem recebida em foreground: ${message.messageId}');

    // Mostrar notificação local
    showNotification(
      title: message.notification?.title ?? 'Costruttore',
      body: message.notification?.body ?? '',
      payload: message.data['route'],
    );
  }

  /// Handler para quando usuário toca na notificação
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Notificação tocada: ${message.messageId}');
    final route = message.data['route'];
    if (route != null && onNotificationTap != null) {
      onNotificationTap!(route);
    }
  }

  /// Callback quando usuário toca em notificação local
  void _onNotificationTap(NotificationResponse response) {
    print('Notificação local tocada: ${response.payload}');
    if (response.payload != null && onNotificationTap != null) {
      onNotificationTap!(response.payload);
    }
  }

  /// Mostra notificação local imediatamente (método público)
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'costruttore_channel',
          'Costruttore',
          channelDescription: 'Notificações do Costruttore',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
          color: Color(0xFFBF5942),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Gera ID único para notificação baseado em string
  static int generateNotificationId(String key) {
    return key.hashCode.abs() % 2147483647;
  }
}

// Made with Bob
