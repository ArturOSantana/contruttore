import 'package:injectable/injectable.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../entities/milestone_entity.dart';
import '../entities/reform_calendar_entity.dart';
import '../entities/reform_map_entity.dart';

/// Serviço que detecta e gera eventos do calendário da reforma
///
/// Analisa o estado da reforma e gera eventos automaticamente:
/// - Pagamentos pendentes
/// - Entregas agendadas
/// - Início e fim de fases
/// - Marcos importantes
@injectable
class CalendarEventsDetector {
  /// Detecta todos os eventos do calendário
  ReformCalendarEntity detect(ReformMapEntity reformMap) {
    final allEvents = <CalendarEventEntity>[];

    // Detecta eventos de fases
    allEvents.addAll(_detectPhaseEvents(reformMap));

    // Detecta eventos de marcos
    allEvents.addAll(_detectMilestoneEvents(reformMap));

    // Ordena eventos por data
    allEvents.sort((a, b) => a.date.compareTo(b.date));

    // Filtra eventos por período
    final now = DateTime.now();
    final todayEvents = _filterTodayEvents(allEvents, now);
    final thisWeekEvents = _filterThisWeekEvents(allEvents, now);
    final thisMonthEvents = _filterThisMonthEvents(allEvents, now);

    // Encontra próximo evento importante
    final nextImportant = _findNextImportantEvent(allEvents, now);
    final daysUntilNext = nextImportant?.daysUntil;

    return ReformCalendarEntity(
      events: allEvents,
      todayEvents: todayEvents,
      thisWeekEvents: thisWeekEvents,
      thisMonthEvents: thisMonthEvents,
      nextImportantEvent: nextImportant,
      daysUntilNextEvent: daysUntilNext,
    );
  }

  /// Detecta eventos de fases
  List<CalendarEventEntity> _detectPhaseEvents(ReformMapEntity reformMap) {
    final events = <CalendarEventEntity>[];

    for (final phase in reformMap.phases) {
      // Início de fase
      if (phase.startDate != null && phase.status != PhaseStatus.done) {
        events.add(
          CalendarEventEntity(
            id: 'phase_start_${phase.id}',
            title: 'Início: ${phase.name}',
            description: 'Início da fase ${phase.name}',
            date: phase.startDate!,
            type: CalendarEventType.phaseStart,
            priority: EventPriority.high,
            relatedId: phase.id,
            relatedType: 'phase',
            icon: '',
            color: '#2196F3',
          ),
        );
      }

      // Fim de fase (estimado)
      if (phase.endDate != null && phase.status != PhaseStatus.done) {
        events.add(
          CalendarEventEntity(
            id: 'phase_end_${phase.id}',
            title: 'Conclusão: ${phase.name}',
            description: 'Conclusão prevista da fase ${phase.name}',
            date: phase.endDate!,
            type: CalendarEventType.phaseEnd,
            priority: EventPriority.medium,
            relatedId: phase.id,
            relatedType: 'phase',
            icon: '',
            color: '#4CAF50',
          ),
        );
      }
    }

    return events;
  }

  /// Detecta eventos de marcos
  List<CalendarEventEntity> _detectMilestoneEvents(ReformMapEntity reformMap) {
    final events = <CalendarEventEntity>[];

    for (final milestone in reformMap.milestones) {
      // Apenas marcos próximos que ainda não foram alcançados
      if (milestone.isNear && !milestone.isAchieved) {
        // Estima data baseada no progresso
        final estimatedDate = _estimateMilestoneDate(milestone, reformMap);

        if (estimatedDate != null) {
          events.add(
            CalendarEventEntity(
              id: 'milestone_${milestone.id}',
              title: 'Marco: ${milestone.title}',
              description: milestone.description,
              date: estimatedDate,
              type: CalendarEventType.milestone,
              priority: EventPriority.high,
              relatedId: milestone.id,
              relatedType: 'milestone',
              icon: milestone.icon,
              color: '#FF9800',
            ),
          );
        }
      }
    }

    return events;
  }

  /// Filtra eventos de hoje
  List<CalendarEventEntity> _filterTodayEvents(
    List<CalendarEventEntity> events,
    DateTime now,
  ) {
    return events.where((event) => event.isToday).toList();
  }

  /// Filtra eventos desta semana
  List<CalendarEventEntity> _filterThisWeekEvents(
    List<CalendarEventEntity> events,
    DateTime now,
  ) {
    return events.where((event) => event.isThisWeek).toList();
  }

  /// Filtra eventos deste mês
  List<CalendarEventEntity> _filterThisMonthEvents(
    List<CalendarEventEntity> events,
    DateTime now,
  ) {
    return events.where((event) => event.isThisMonth).toList();
  }

  /// Encontra próximo evento importante
  CalendarEventEntity? _findNextImportantEvent(
    List<CalendarEventEntity> events,
    DateTime now,
  ) {
    final futureEvents = events.where((event) {
      return event.date.isAfter(now) && !event.isCompleted;
    }).toList();

    if (futureEvents.isEmpty) return null;

    // Prioriza eventos críticos e de alta prioridade
    final importantEvents = futureEvents.where((event) {
      return event.priority == EventPriority.critical ||
          event.priority == EventPriority.high;
    }).toList();

    if (importantEvents.isNotEmpty) {
      return importantEvents.first;
    }

    return futureEvents.first;
  }

  /// Estima data de um marco baseado no progresso
  DateTime? _estimateMilestoneDate(
    MilestoneEntity milestone,
    ReformMapEntity reformMap,
  ) {
    // Para marcos de progresso, estima baseado na velocidade atual
    if (milestone.type == MilestoneType.progress) {
      return _estimateProgressMilestoneDate(milestone, reformMap);
    }

    // Para marcos de fase, usa a data de conclusão da fase
    if (milestone.type == MilestoneType.phase) {
      return _estimatePhaseMilestoneDate(milestone, reformMap);
    }

    // Para outros tipos, retorna null (não estimável)
    return null;
  }

  /// Estima data de marco de progresso
  DateTime? _estimateProgressMilestoneDate(
    MilestoneEntity milestone,
    ReformMapEntity reformMap,
  ) {
    // Estimativa simples: 30 dias para próximo marco
    return DateTime.now().add(const Duration(days: 30));
  }

  /// Estima data de marco de fase
  DateTime? _estimatePhaseMilestoneDate(
    MilestoneEntity milestone,
    ReformMapEntity reformMap,
  ) {
    // Procura a fase relacionada ao marco
    final phaseName = milestone.title.toLowerCase();

    for (final phase in reformMap.phases) {
      if (phaseName.contains(phase.name.toLowerCase())) {
        return phase.endDate;
      }
    }

    return null;
  }
}

// Made with Bob
