import '../../domain/entities/app_settings_entity.dart';

class AppSettingsModel extends AppSettingsEntity {
  const AppSettingsModel({
    required super.userId,
    required super.notificationsEnabled,
    required super.silentModeStart,
    required super.silentModeEnd,
    required super.alertsEnabled,
    required super.educationalAlertsEnabled,
    required super.maxPushPerDay,
    required super.updatedAt,
  });

  factory AppSettingsModel.fromEntity(AppSettingsEntity entity) {
    return AppSettingsModel(
      userId: entity.userId,
      notificationsEnabled: entity.notificationsEnabled,
      silentModeStart: entity.silentModeStart,
      silentModeEnd: entity.silentModeEnd,
      alertsEnabled: entity.alertsEnabled,
      educationalAlertsEnabled: entity.educationalAlertsEnabled,
      maxPushPerDay: entity.maxPushPerDay,
      updatedAt: entity.updatedAt,
    );
  }

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      userId: map['userId'] as String,
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      silentModeStart: TimeOfDay(
        hour: map['silentModeStartHour'] as int? ?? 22,
        minute: map['silentModeStartMinute'] as int? ?? 0,
      ),
      silentModeEnd: TimeOfDay(
        hour: map['silentModeEndHour'] as int? ?? 8,
        minute: map['silentModeEndMinute'] as int? ?? 0,
      ),
      alertsEnabled: map['alertsEnabled'] as bool? ?? true,
      educationalAlertsEnabled:
          map['educationalAlertsEnabled'] as bool? ?? true,
      maxPushPerDay: map['maxPushPerDay'] as int? ?? 2,
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'notificationsEnabled': notificationsEnabled,
      'silentModeStartHour': silentModeStart.hour,
      'silentModeStartMinute': silentModeStart.minute,
      'silentModeEndHour': silentModeEnd.hour,
      'silentModeEndMinute': silentModeEnd.minute,
      'alertsEnabled': alertsEnabled,
      'educationalAlertsEnabled': educationalAlertsEnabled,
      'maxPushPerDay': maxPushPerDay,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Made with Bob
