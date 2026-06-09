import 'package:flutter/material.dart';
import '../../domain/entities/reform_week_entity.dart';

/// Card que exibe a semana da reforma
///
/// Mostra um calendário semanal visual com:
/// - 7 dias da semana
/// - Indicadores de eventos por dia
/// - Status visual de cada dia
/// - Resumo da intensidade da semana
class ReformWeekCard extends StatelessWidget {
  final ReformWeekEntity week;

  const ReformWeekCard({
    super.key,
    required this.week,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getIntensityColor(week.intensity),
              _getIntensityColor(week.intensity).withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_view_week,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Semana da Reforma',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatWeekRange(),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  // Emoji da intensidade
                  Text(
                    week.intensity.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Calendário semanal
              _buildWeekCalendar(context),

              const SizedBox(height: 20),

              // Resumo da semana
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.white.withOpacity(0.9),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          week.intensity.label,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      week.weekSummary,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                    const SizedBox(height: 12),
                    // Estatísticas
                    Row(
                      children: [
                        _buildStat(
                          context,
                          '${week.totalEvents}',
                          'eventos',
                          Icons.event,
                        ),
                        const SizedBox(width: 16),
                        _buildStat(
                          context,
                          '${week.busyDays}',
                          'dias ocupados',
                          Icons.calendar_today,
                        ),
                        const SizedBox(width: 16),
                        _buildStat(
                          context,
                          '${week.freeDays}',
                          'dias livres',
                          Icons.free_breakfast,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekCalendar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: week.days.map((day) => _buildDayColumn(context, day)).toList(),
    );
  }

  Widget _buildDayColumn(BuildContext context, WeekDayEntity day) {
    return Expanded(
      child: Column(
        children: [
          // Nome do dia
          Text(
            day.dayName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          // Círculo do dia
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getDayBackgroundColor(day),
              shape: BoxShape.circle,
              border: day.isToday
                  ? Border.all(
                      color: Colors.white,
                      width: 2,
                    )
                  : null,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Número do dia
                  Text(
                    '${day.date.day}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _getDayTextColor(day),
                          fontWeight:
                              day.isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                  ),
                  // Indicador de eventos
                  if (day.hasEvents)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _getEventIndicatorColor(day),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Emoji do status
          if (day.hasEvents)
            Text(
              day.status.emoji,
              style: const TextStyle(fontSize: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.8),
            size: 16,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getIntensityColor(WeekIntensity intensity) {
    switch (intensity) {
      case WeekIntensity.calm:
        return const Color(0xFF4CAF50); // Verde
      case WeekIntensity.moderate:
        return const Color(0xFF2196F3); // Azul
      case WeekIntensity.busy:
        return const Color(0xFFFF9800); // Laranja
      case WeekIntensity.intense:
        return const Color(0xFFF44336); // Vermelho
    }
  }

  Color _getDayBackgroundColor(WeekDayEntity day) {
    if (day.isPast) {
      return Colors.white.withOpacity(0.1);
    }
    if (day.isToday) {
      return Colors.white;
    }
    if (!day.hasEvents) {
      return Colors.white.withOpacity(0.2);
    }

    // Cor baseada no status
    switch (day.status) {
      case DayStatus.free:
        return Colors.white.withOpacity(0.2);
      case DayStatus.light:
        return Colors.white.withOpacity(0.3);
      case DayStatus.busy:
        return Colors.white.withOpacity(0.4);
      case DayStatus.overloaded:
        return Colors.white.withOpacity(0.5);
    }
  }

  Color _getDayTextColor(WeekDayEntity day) {
    if (day.isToday) {
      return _getIntensityColor(week.intensity);
    }
    if (day.isPast) {
      return Colors.white.withOpacity(0.4);
    }
    return Colors.white;
  }

  Color _getEventIndicatorColor(WeekDayEntity day) {
    if (day.isToday) {
      return _getIntensityColor(week.intensity);
    }
    if (day.criticalEvents.isNotEmpty) {
      return Colors.red;
    }
    if (day.highPriorityEvents.isNotEmpty) {
      return Colors.orange;
    }
    return Colors.white;
  }

  String _formatWeekRange() {
    final start = week.weekStart;
    final end = week.weekEnd;

    if (start.month == end.month) {
      return '${start.day} a ${end.day} de ${_getMonthName(start.month)}';
    } else {
      return '${start.day} ${_getMonthName(start.month)} a ${end.day} ${_getMonthName(end.month)}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];
    return months[month - 1];
  }
}

// Made with Bob
