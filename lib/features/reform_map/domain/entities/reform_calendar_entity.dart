import 'package:equatable/equatable.dart';

/// Entidade que representa o calendário inteligente da reforma
///
/// Mostra eventos importantes organizados por data:
/// - Prazos de pagamento
/// - Entregas agendadas
/// - Visitas de fornecedores
/// - Inspeções
/// - Marcos importantes
class ReformCalendarEntity extends Equatable {
  /// Eventos do calendário organizados por data
  final List<CalendarEventEntity> events;

  /// Eventos de hoje
  final List<CalendarEventEntity> todayEvents;

  /// Eventos desta semana
  final List<CalendarEventEntity> thisWeekEvents;

  /// Eventos deste mês
  final List<CalendarEventEntity> thisMonthEvents;

  /// Próximo evento importante
  final CalendarEventEntity? nextImportantEvent;

  /// Dias até o próximo evento importante
  final int? daysUntilNextEvent;

  const ReformCalendarEntity({
    required this.events,
    required this.todayEvents,
    required this.thisWeekEvents,
    required this.thisMonthEvents,
    this.nextImportantEvent,
    this.daysUntilNextEvent,
  });

  /// Retorna eventos de uma data específica
  List<CalendarEventEntity> getEventsForDate(DateTime date) {
    return events.where((event) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    }).toList();
  }

  /// Retorna eventos entre duas datas
  List<CalendarEventEntity> getEventsBetween(DateTime start, DateTime end) {
    return events.where((event) {
      return event.date.isAfter(start.subtract(const Duration(days: 1))) &&
          event.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Retorna eventos por tipo
  List<CalendarEventEntity> getEventsByType(CalendarEventType type) {
    return events.where((event) => event.type == type).toList();
  }

  /// Retorna eventos atrasados
  List<CalendarEventEntity> get overdueEvents {
    final now = DateTime.now();
    return events.where((event) {
      return event.date.isBefore(now) && !event.isCompleted;
    }).toList();
  }

  /// Retorna eventos urgentes (próximos 3 dias)
  List<CalendarEventEntity> get urgentEvents {
    final now = DateTime.now();
    final threeDaysFromNow = now.add(const Duration(days: 3));
    return events.where((event) {
      return event.date.isAfter(now) &&
          event.date.isBefore(threeDaysFromNow) &&
          !event.isCompleted;
    }).toList();
  }

  /// Verifica se há eventos hoje
  bool get hasEventsToday => todayEvents.isNotEmpty;

  /// Verifica se há eventos atrasados
  bool get hasOverdueEvents => overdueEvents.isNotEmpty;

  /// Verifica se há eventos urgentes
  bool get hasUrgentEvents => urgentEvents.isNotEmpty;

  @override
  List<Object?> get props => [
        events,
        todayEvents,
        thisWeekEvents,
        thisMonthEvents,
        nextImportantEvent,
        daysUntilNextEvent,
      ];
}

/// Entidade que representa um evento do calendário
class CalendarEventEntity extends Equatable {
  /// ID único do evento
  final String id;

  /// Título do evento
  final String title;

  /// Descrição detalhada
  final String description;

  /// Data do evento
  final DateTime date;

  /// Tipo do evento
  final CalendarEventType type;

  /// Prioridade do evento
  final EventPriority priority;

  /// Se o evento foi concluído
  final bool isCompleted;

  /// Data de conclusão
  final DateTime? completedAt;

  /// ID relacionado (ex: ID do pagamento, fornecedor, etc)
  final String? relatedId;

  /// Tipo de entidade relacionada
  final String? relatedType;

  /// Ícone do evento
  final String icon;

  /// Cor do evento
  final String color;

  const CalendarEventEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    required this.priority,
    this.isCompleted = false,
    this.completedAt,
    this.relatedId,
    this.relatedType,
    required this.icon,
    required this.color,
  });

  /// Verifica se o evento é hoje
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Verifica se o evento é esta semana
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        date.isBefore(weekEnd.add(const Duration(days: 1)));
  }

  /// Verifica se o evento é este mês
  bool get isThisMonth {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Verifica se o evento está atrasado
  bool get isOverdue {
    return date.isBefore(DateTime.now()) && !isCompleted;
  }

  /// Verifica se o evento é urgente (próximos 3 dias)
  bool get isUrgent {
    final now = DateTime.now();
    final threeDaysFromNow = now.add(const Duration(days: 3));
    return date.isAfter(now) && date.isBefore(threeDaysFromNow) && !isCompleted;
  }

  /// Dias até o evento
  int get daysUntil {
    final now = DateTime.now();
    final difference = date.difference(now);
    return difference.inDays;
  }

  /// Texto descritivo da data
  String get dateDescription {
    if (isToday) return 'Hoje';
    if (daysUntil == 1) return 'Amanhã';
    if (daysUntil == -1) return 'Ontem';
    if (daysUntil < 0) return '${-daysUntil} dias atrás';
    if (daysUntil <= 7) return 'Em $daysUntil dias';
    return 'Em ${(daysUntil / 7).ceil()} semanas';
  }

  CalendarEventEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    CalendarEventType? type,
    EventPriority? priority,
    bool? isCompleted,
    DateTime? completedAt,
    String? relatedId,
    String? relatedType,
    String? icon,
    String? color,
  }) {
    return CalendarEventEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        date,
        type,
        priority,
        isCompleted,
        completedAt,
        relatedId,
        relatedType,
        icon,
        color,
      ];
}

/// Tipos de eventos do calendário
enum CalendarEventType {
  /// Pagamento a ser realizado
  payment,

  /// Entrega de material
  delivery,

  /// Visita de fornecedor
  supplierVisit,

  /// Inspeção ou vistoria
  inspection,

  /// Marco importante da reforma
  milestone,

  /// Início de fase
  phaseStart,

  /// Fim de fase
  phaseEnd,

  /// Reunião
  meeting,

  /// Outro tipo de evento
  other,
}

/// Prioridade do evento
enum EventPriority {
  /// Baixa prioridade
  low,

  /// Prioridade média
  medium,

  /// Alta prioridade
  high,

  /// Prioridade crítica
  critical,
}

/// Extensão para obter informações sobre o tipo de evento
extension CalendarEventTypeExtension on CalendarEventType {
  String get displayName {
    switch (this) {
      case CalendarEventType.payment:
        return 'Pagamento';
      case CalendarEventType.delivery:
        return 'Entrega';
      case CalendarEventType.supplierVisit:
        return 'Visita';
      case CalendarEventType.inspection:
        return 'Inspeção';
      case CalendarEventType.milestone:
        return 'Marco';
      case CalendarEventType.phaseStart:
        return 'Início de Fase';
      case CalendarEventType.phaseEnd:
        return 'Fim de Fase';
      case CalendarEventType.meeting:
        return 'Reunião';
      case CalendarEventType.other:
        return 'Outro';
    }
  }

  String get icon {
    switch (this) {
      case CalendarEventType.payment:
        return '';
      case CalendarEventType.delivery:
        return '';
      case CalendarEventType.supplierVisit:
        return '';
      case CalendarEventType.inspection:
        return '';
      case CalendarEventType.milestone:
        return '';
      case CalendarEventType.phaseStart:
        return '';
      case CalendarEventType.phaseEnd:
        return '';
      case CalendarEventType.meeting:
        return '';
      case CalendarEventType.other:
        return '';
    }
  }
}

/// Extensão para obter informações sobre a prioridade
extension EventPriorityExtension on EventPriority {
  String get displayName {
    switch (this) {
      case EventPriority.low:
        return 'Baixa';
      case EventPriority.medium:
        return 'Média';
      case EventPriority.high:
        return 'Alta';
      case EventPriority.critical:
        return 'Crítica';
    }
  }

  String get color {
    switch (this) {
      case EventPriority.low:
        return '#4CAF50'; // Verde
      case EventPriority.medium:
        return '#2196F3'; // Azul
      case EventPriority.high:
        return '#FF9800'; // Laranja
      case EventPriority.critical:
        return '#F44336'; // Vermelho
    }
  }
}

// Made with Bob
