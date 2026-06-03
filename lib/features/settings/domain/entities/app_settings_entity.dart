import 'package:equatable/equatable.dart';

/// Configurações do aplicativo
class AppSettingsEntity extends Equatable {
  final String userId;
  final bool notificationsEnabled;
  final TimeOfDay silentModeStart;
  final TimeOfDay silentModeEnd;
  final bool alertsEnabled;
  final bool educationalAlertsEnabled;
  final int maxPushPerDay;
  final DateTime updatedAt;

  const AppSettingsEntity({
    required this.userId,
    required this.notificationsEnabled,
    required this.silentModeStart,
    required this.silentModeEnd,
    required this.alertsEnabled,
    required this.educationalAlertsEnabled,
    required this.maxPushPerDay,
    required this.updatedAt,
  });

  /// Configurações padrão
  factory AppSettingsEntity.defaults(String userId) {
    return AppSettingsEntity(
      userId: userId,
      notificationsEnabled: true,
      silentModeStart: const TimeOfDay(hour: 22, minute: 0),
      silentModeEnd: const TimeOfDay(hour: 8, minute: 0),
      alertsEnabled: true,
      educationalAlertsEnabled: true,
      maxPushPerDay: 2,
      updatedAt: DateTime.now(),
    );
  }

  /// Verifica se está no horário de silêncio
  bool get isInSilentMode {
    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

    // Se o horário de início é menor que o de fim (ex: 8h às 22h)
    if (silentModeStart.hour < silentModeEnd.hour) {
      return _isTimeBetween(currentTime, silentModeStart, silentModeEnd);
    }
    // Se o horário cruza a meia-noite (ex: 22h às 8h)
    else {
      return !_isTimeBetween(currentTime, silentModeEnd, silentModeStart);
    }
  }

  bool _isTimeBetween(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    return timeMinutes >= startMinutes && timeMinutes < endMinutes;
  }

  AppSettingsEntity copyWith({
    String? userId,
    bool? notificationsEnabled,
    TimeOfDay? silentModeStart,
    TimeOfDay? silentModeEnd,
    bool? alertsEnabled,
    bool? educationalAlertsEnabled,
    int? maxPushPerDay,
    DateTime? updatedAt,
  }) {
    return AppSettingsEntity(
      userId: userId ?? this.userId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      silentModeStart: silentModeStart ?? this.silentModeStart,
      silentModeEnd: silentModeEnd ?? this.silentModeEnd,
      alertsEnabled: alertsEnabled ?? this.alertsEnabled,
      educationalAlertsEnabled:
          educationalAlertsEnabled ?? this.educationalAlertsEnabled,
      maxPushPerDay: maxPushPerDay ?? this.maxPushPerDay,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    notificationsEnabled,
    silentModeStart,
    silentModeEnd,
    alertsEnabled,
    educationalAlertsEnabled,
    maxPushPerDay,
    updatedAt,
  ];
}

/// TimeOfDay simples para evitar dependência do Flutter
class TimeOfDay extends Equatable {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  @override
  List<Object?> get props => [hour, minute];

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

// Made with Bob
