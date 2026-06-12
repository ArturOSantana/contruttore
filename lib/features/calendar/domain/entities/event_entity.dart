import 'package:equatable/equatable.dart';

/// Tipos de eventos
enum EventType {
  meeting, // Reunião
  inspection, // Vistoria
  delivery, // Entrega
  payment, // Pagamento
  deadline, // Prazo
  reminder, // Lembrete
  other, // Outro
}

/// Prioridades
enum EventPriority {
  low, // Baixa
  medium, // Média
  high, // Alta
}

/// Status do evento
enum EventStatus {
  pending, // Pendente
  completed, // Concluído
  cancelled, // Cancelado
}

/// Entidade de evento do calendário local
class EventEntity extends Equatable {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final String? location;
  final EventType type;
  final EventPriority priority;
  final EventStatus status;
  final bool isAllDay;
  final bool hasNotification;
  final int? notificationMinutesBefore;
  final DateTime createdAt;
  final DateTime? completedAt;

  const EventEntity({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.startDate,
    this.endDate,
    this.location,
    this.type = EventType.other,
    this.priority = EventPriority.medium,
    this.status = EventStatus.pending,
    this.isAllDay = false,
    this.hasNotification = true,
    this.notificationMinutesBefore = 60, // 1 hora antes por padrão
    required this.createdAt,
    this.completedAt,
  });

  /// Verifica se o evento já passou
  bool get isPast => startDate.isBefore(DateTime.now());

  /// Verifica se o evento é hoje
  bool get isToday {
    final now = DateTime.now();
    return startDate.year == now.year &&
        startDate.month == now.month &&
        startDate.day == now.day;
  }

  /// Verifica se o evento é amanhã
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return startDate.year == tomorrow.year &&
        startDate.month == tomorrow.month &&
        startDate.day == tomorrow.day;
  }

  /// Verifica se o evento está próximo (nas próximas 24h)
  bool get isUpcoming {
    final now = DateTime.now();
    final diff = startDate.difference(now);
    return diff.inHours >= 0 && diff.inHours <= 24;
  }

  /// Duração do evento
  Duration? get duration {
    if (endDate == null) return null;
    return endDate!.difference(startDate);
  }

  /// Ícone do tipo de evento
  String get typeIcon {
    switch (type) {
      case EventType.meeting:
        return '👥';
      case EventType.inspection:
        return '🔍';
      case EventType.delivery:
        return '📦';
      case EventType.payment:
        return '💰';
      case EventType.deadline:
        return '⏰';
      case EventType.reminder:
        return '🔔';
      case EventType.other:
        return '📅';
    }
  }

  /// Nome do tipo de evento
  String get typeName {
    switch (type) {
      case EventType.meeting:
        return 'Reunião';
      case EventType.inspection:
        return 'Vistoria';
      case EventType.delivery:
        return 'Entrega';
      case EventType.payment:
        return 'Pagamento';
      case EventType.deadline:
        return 'Prazo';
      case EventType.reminder:
        return 'Lembrete';
      case EventType.other:
        return 'Outro';
    }
  }

  /// Nome da prioridade
  String get priorityName {
    switch (priority) {
      case EventPriority.low:
        return 'Baixa';
      case EventPriority.medium:
        return 'Média';
      case EventPriority.high:
        return 'Alta';
    }
  }

  /// Copia o evento com novos valores
  EventEntity copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    EventType? type,
    EventPriority? priority,
    EventStatus? status,
    bool? isAllDay,
    bool? hasNotification,
    int? notificationMinutesBefore,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return EventEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      isAllDay: isAllDay ?? this.isAllDay,
      hasNotification: hasNotification ?? this.hasNotification,
      notificationMinutesBefore:
          notificationMinutesBefore ?? this.notificationMinutesBefore,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        title,
        description,
        startDate,
        endDate,
        location,
        type,
        priority,
        status,
        isAllDay,
        hasNotification,
        notificationMinutesBefore,
        createdAt,
        completedAt,
      ];
}

// Made with Bob
