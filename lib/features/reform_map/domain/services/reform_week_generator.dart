import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import '../entities/reform_calendar_entity.dart';
import '../entities/reform_week_entity.dart';

/// Serviço que gera a visualização da semana da reforma
///
/// Transforma eventos do calendário em uma visualização semanal
/// com análise de intensidade e distribuição de atividades
@injectable
class ReformWeekGenerator {
  /// Gera a semana da reforma a partir do calendário
  ReformWeekEntity generate(ReformCalendarEntity calendar) {
    final now = DateTime.now();
    final weekStart = _getWeekStart(now);
    final weekEnd = _getWeekEnd(weekStart);

    // Gera os 7 dias da semana
    final days = _generateWeekDays(weekStart, calendar);

    // Calcula estatísticas
    final totalEvents = days.fold<int>(0, (sum, day) => sum + day.eventCount);
    final busyDays = days.where((day) => day.hasEvents).length;
    final freeDays = 7 - busyDays;

    // Determina intensidade
    final intensity = _calculateIntensity(totalEvents);

    // Gera resumo
    final summary = _generateSummary(days, intensity);

    return ReformWeekEntity(
      weekStart: weekStart,
      weekEnd: weekEnd,
      days: days,
      totalEvents: totalEvents,
      busyDays: busyDays,
      freeDays: freeDays,
      intensity: intensity,
      weekSummary: summary,
    );
  }

  /// Retorna o início da semana (segunda-feira)
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: weekday - 1));
  }

  /// Retorna o fim da semana (domingo)
  DateTime _getWeekEnd(DateTime weekStart) {
    return weekStart.add(const Duration(days: 6));
  }

  /// Gera os 7 dias da semana com seus eventos
  List<WeekDayEntity> _generateWeekDays(
    DateTime weekStart,
    ReformCalendarEntity calendar,
  ) {
    final days = <WeekDayEntity>[];
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dayEvents = calendar.getEventsForDate(date);

      final isToday = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      final isPast = date.isBefore(DateTime(now.year, now.month, now.day));

      final status = _calculateDayStatus(dayEvents.length);

      days.add(WeekDayEntity(
        date: date,
        dayName: _getDayName(date.weekday),
        events: dayEvents,
        isToday: isToday,
        isPast: isPast,
        status: status,
      ));
    }

    return days;
  }

  /// Retorna o nome abreviado do dia
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Seg';
      case 2:
        return 'Ter';
      case 3:
        return 'Qua';
      case 4:
        return 'Qui';
      case 5:
        return 'Sex';
      case 6:
        return 'Sáb';
      case 7:
        return 'Dom';
      default:
        return '';
    }
  }

  /// Calcula o status do dia baseado no número de eventos
  DayStatus _calculateDayStatus(int eventCount) {
    if (eventCount == 0) return DayStatus.free;
    if (eventCount <= 2) return DayStatus.light;
    if (eventCount <= 4) return DayStatus.busy;
    return DayStatus.overloaded;
  }

  /// Calcula a intensidade da semana
  WeekIntensity _calculateIntensity(int totalEvents) {
    if (totalEvents <= 3) return WeekIntensity.calm;
    if (totalEvents <= 7) return WeekIntensity.moderate;
    if (totalEvents <= 12) return WeekIntensity.busy;
    return WeekIntensity.intense;
  }

  /// Gera um resumo textual da semana
  String _generateSummary(List<WeekDayEntity> days, WeekIntensity intensity) {
    final busyDays = days.where((d) => d.hasEvents).toList();

    if (busyDays.isEmpty) {
      return 'Nenhuma atividade planejada esta semana';
    }

    if (busyDays.length == 1) {
      final day = busyDays.first;
      return '${day.eventCount} ${day.eventCount == 1 ? 'evento' : 'eventos'} em ${day.dayName}';
    }

    final totalEvents = days.fold<int>(0, (sum, day) => sum + day.eventCount);

    switch (intensity) {
      case WeekIntensity.calm:
        return '$totalEvents eventos distribuídos em ${busyDays.length} dias';
      case WeekIntensity.moderate:
        return 'Ritmo equilibrado com $totalEvents atividades';
      case WeekIntensity.busy:
        return 'Semana movimentada com $totalEvents compromissos';
      case WeekIntensity.intense:
        return 'Semana intensa! $totalEvents atividades planejadas';
    }
  }
}

// Made with Bob
