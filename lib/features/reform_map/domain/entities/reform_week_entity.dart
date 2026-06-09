import 'package:equatable/equatable.dart';
import 'reform_calendar_entity.dart';

/// Entidade que representa a semana da reforma
///
/// Mostra um resumo visual da semana com:
/// - Eventos por dia
/// - Dias com atividades
/// - Dias livres
/// - Intensidade da semana
class ReformWeekEntity extends Equatable {
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<WeekDayEntity> days;
  final int totalEvents;
  final int busyDays;
  final int freeDays;
  final WeekIntensity intensity;
  final String weekSummary;

  const ReformWeekEntity({
    required this.weekStart,
    required this.weekEnd,
    required this.days,
    required this.totalEvents,
    required this.busyDays,
    required this.freeDays,
    required this.intensity,
    required this.weekSummary,
  });

  /// Retorna o dia atual da semana
  WeekDayEntity? get today {
    final now = DateTime.now();
    return days.firstWhere(
      (day) =>
          day.date.year == now.year &&
          day.date.month == now.month &&
          day.date.day == now.day,
      orElse: () => days.first,
    );
  }

  /// Retorna dias com eventos
  List<WeekDayEntity> get daysWithEvents {
    return days.where((day) => day.hasEvents).toList();
  }

  /// Retorna o próximo dia com eventos
  WeekDayEntity? get nextBusyDay {
    final now = DateTime.now();
    return days.firstWhere(
      (day) => day.date.isAfter(now) && day.hasEvents,
      orElse: () => days.last,
    );
  }

  @override
  List<Object?> get props => [
        weekStart,
        weekEnd,
        days,
        totalEvents,
        busyDays,
        freeDays,
        intensity,
        weekSummary,
      ];
}

/// Representa um dia da semana
class WeekDayEntity extends Equatable {
  final DateTime date;
  final String dayName; // Seg, Ter, Qua, etc
  final List<CalendarEventEntity> events;
  final bool isToday;
  final bool isPast;
  final DayStatus status;

  const WeekDayEntity({
    required this.date,
    required this.dayName,
    required this.events,
    required this.isToday,
    required this.isPast,
    required this.status,
  });

  /// Verifica se o dia tem eventos
  bool get hasEvents => events.isNotEmpty;

  /// Retorna o número de eventos
  int get eventCount => events.length;

  /// Retorna eventos críticos
  List<CalendarEventEntity> get criticalEvents {
    return events.where((e) => e.priority == EventPriority.critical).toList();
  }

  /// Retorna eventos de alta prioridade
  List<CalendarEventEntity> get highPriorityEvents {
    return events.where((e) => e.priority == EventPriority.high).toList();
  }

  @override
  List<Object?> get props => [
        date,
        dayName,
        events,
        isToday,
        isPast,
        status,
      ];
}

/// Status do dia
enum DayStatus {
  free, // Sem eventos
  light, // 1-2 eventos
  busy, // 3-4 eventos
  overloaded, // 5+ eventos
}

/// Intensidade da semana
enum WeekIntensity {
  calm, // 0-3 eventos na semana
  moderate, // 4-7 eventos
  busy, // 8-12 eventos
  intense, // 13+ eventos
}

extension DayStatusExtension on DayStatus {
  String get label {
    switch (this) {
      case DayStatus.free:
        return 'Livre';
      case DayStatus.light:
        return 'Leve';
      case DayStatus.busy:
        return 'Ocupado';
      case DayStatus.overloaded:
        return 'Sobrecarregado';
    }
  }

  String get emoji {
    switch (this) {
      case DayStatus.free:
        return '';
      case DayStatus.light:
        return '';
      case DayStatus.busy:
        return '';
      case DayStatus.overloaded:
        return '';
    }
  }
}

extension WeekIntensityExtension on WeekIntensity {
  String get label {
    switch (this) {
      case WeekIntensity.calm:
        return 'Semana Tranquila';
      case WeekIntensity.moderate:
        return 'Semana Moderada';
      case WeekIntensity.busy:
        return 'Semana Movimentada';
      case WeekIntensity.intense:
        return 'Semana Intensa';
    }
  }

  String get description {
    switch (this) {
      case WeekIntensity.calm:
        return 'Poucos compromissos esta semana';
      case WeekIntensity.moderate:
        return 'Ritmo equilibrado de atividades';
      case WeekIntensity.busy:
        return 'Muitas atividades planejadas';
      case WeekIntensity.intense:
        return 'Semana com alta demanda';
    }
  }

  String get emoji {
    switch (this) {
      case WeekIntensity.calm:
        return '';
      case WeekIntensity.moderate:
        return '';
      case WeekIntensity.busy:
        return '';
      case WeekIntensity.intense:
        return '';
    }
  }
}

// Made with Bob
