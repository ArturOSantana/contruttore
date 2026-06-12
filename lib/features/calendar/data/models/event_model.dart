import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/event_entity.dart';

/// Model de evento para Firestore
class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.projectId,
    required super.title,
    super.description,
    required super.startDate,
    super.endDate,
    super.location,
    super.type,
    super.priority,
    super.status,
    super.isAllDay,
    super.hasNotification,
    super.notificationMinutesBefore,
    required super.createdAt,
    super.completedAt,
  });

  /// Cria um EventModel a partir de um EventEntity
  factory EventModel.fromEntity(EventEntity entity) {
    return EventModel(
      id: entity.id,
      projectId: entity.projectId,
      title: entity.title,
      description: entity.description,
      startDate: entity.startDate,
      endDate: entity.endDate,
      location: entity.location,
      type: entity.type,
      priority: entity.priority,
      status: entity.status,
      isAllDay: entity.isAllDay,
      hasNotification: entity.hasNotification,
      notificationMinutesBefore: entity.notificationMinutesBefore,
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
    );
  }

  /// Cria um EventModel a partir de um documento do Firestore
  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return EventModel(
      id: doc.id,
      projectId: data['projectId'] as String,
      title: data['title'] as String,
      description: data['description'] as String?,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      location: data['location'] as String?,
      type: EventType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => EventType.other,
      ),
      priority: EventPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => EventPriority.medium,
      ),
      status: EventStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => EventStatus.pending,
      ),
      isAllDay: data['isAllDay'] as bool? ?? false,
      hasNotification: data['hasNotification'] as bool? ?? true,
      notificationMinutesBefore: data['notificationMinutesBefore'] as int?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Converte o model para um Map para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'location': location,
      'type': type.name,
      'priority': priority.name,
      'status': status.name,
      'isAllDay': isAllDay,
      'hasNotification': hasNotification,
      'notificationMinutesBefore': notificationMinutesBefore,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  /// Converte para EventEntity
  EventEntity toEntity() {
    return EventEntity(
      id: id,
      projectId: projectId,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      location: location,
      type: type,
      priority: priority,
      status: status,
      isAllDay: isAllDay,
      hasNotification: hasNotification,
      notificationMinutesBefore: notificationMinutesBefore,
      createdAt: createdAt,
      completedAt: completedAt,
    );
  }
}

// Made with Bob
