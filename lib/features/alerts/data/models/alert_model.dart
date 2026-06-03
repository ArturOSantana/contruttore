import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/alert_entity.dart';

class AlertModel extends AlertEntity {
  const AlertModel({
    required super.id,
    required super.projectId,
    required super.type,
    required super.title,
    required super.message,
    required super.isRead,
    super.actionRoute,
    super.snoozeUntil,
    required super.createdAt,
  });

  factory AlertModel.fromMap(Map<String, dynamic> map, String id) {
    return AlertModel(
      id: id,
      projectId: map['projectId'] ?? '',
      type: AlertType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AlertType.info,
      ),
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      isRead: map['isRead'] ?? false,
      actionRoute: map['actionRoute'],
      snoozeUntil: map['snoozeUntil'] != null
          ? (map['snoozeUntil'] as Timestamp).toDate()
          : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'type': type.name,
      'title': title,
      'message': message,
      'isRead': isRead,
      'actionRoute': actionRoute,
      'snoozeUntil': snoozeUntil != null
          ? Timestamp.fromDate(snoozeUntil!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

// Made with Bob
