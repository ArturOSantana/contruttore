import 'package:equatable/equatable.dart';

class AlertEntity extends Equatable {
  final String id;
  final String projectId;
  final AlertType type;
  final String title;
  final String message;
  final bool isRead;
  final String? actionRoute;
  final DateTime? snoozeUntil;
  final DateTime createdAt;

  const AlertEntity({
    required this.id,
    required this.projectId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.actionRoute,
    this.snoozeUntil,
    required this.createdAt,
  });

  bool get isSnoozed {
    if (snoozeUntil == null) return false;
    return snoozeUntil!.isAfter(DateTime.now());
  }

  bool get shouldShowPush {
    return type == AlertType.critical || type == AlertType.preventive;
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    type,
    title,
    message,
    isRead,
    actionRoute,
    snoozeUntil,
    createdAt,
  ];
}

enum AlertType { critical, preventive, info, educational }

extension AlertTypeExtension on AlertType {
  String get displayName {
    switch (this) {
      case AlertType.critical:
        return 'Crítico';
      case AlertType.preventive:
        return 'Preventivo';
      case AlertType.info:
        return 'Informação';
      case AlertType.educational:
        return 'Educativo';
    }
  }

  String get icon {
    switch (this) {
      case AlertType.critical:
        return '🔴';
      case AlertType.preventive:
        return '⚠️';
      case AlertType.info:
        return 'ℹ️';
      case AlertType.educational:
        return '💡';
    }
  }

  int get colorValue {
    switch (this) {
      case AlertType.critical:
        return 0xFFC62828; // vermelho
      case AlertType.preventive:
        return 0xFFB8860B; // amarelo
      case AlertType.info:
        return 0xFF1565C0; // azul
      case AlertType.educational:
        return 0xFF2E7D4F; // verde
    }
  }

  int get priority {
    switch (this) {
      case AlertType.critical:
        return 3;
      case AlertType.preventive:
        return 2;
      case AlertType.info:
        return 1;
      case AlertType.educational:
        return 0;
    }
  }
}

// Made with Bob
