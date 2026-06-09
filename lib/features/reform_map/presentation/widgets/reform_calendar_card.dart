import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/reform_calendar_entity.dart';
import '../../../../core/services/calendar_service.dart';
import '../cubit/reform_map_cubit.dart';
import 'add_event_dialog.dart';

/// Card que exibe o calendário inteligente da reforma
///
/// Mostra:
/// - Eventos de hoje
/// - Próximo evento importante
/// - Eventos urgentes
/// - Eventos atrasados
class ReformCalendarCard extends StatelessWidget {
  final ReformCalendarEntity calendar;
  final String projectId;

  const ReformCalendarCard({
    super.key,
    required this.calendar,
    required this.projectId,
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
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF5E35B1), // Roxo escuro
              Color(0xFF7E57C2), // Roxo médio
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Calendário da Reforma',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Eventos e prazos importantes',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.file_download, color: Colors.white),
                    onPressed: () => _exportCalendar(context),
                    tooltip: 'Exportar para Calendário',
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => _showAddEventDialog(context),
                    tooltip: 'Adicionar Evento',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Alertas
              if (calendar.hasOverdueEvents) ...[
                _buildAlert(
                  context,
                  icon: Icons.warning_amber_rounded,
                  title: 'Eventos atrasados',
                  subtitle:
                      '${calendar.overdueEvents.length} ${calendar.overdueEvents.length == 1 ? 'evento atrasado' : 'eventos atrasados'}',
                  color: Colors.red,
                ),
                const SizedBox(height: 12),
              ],

              if (calendar.hasUrgentEvents) ...[
                _buildAlert(
                  context,
                  icon: Icons.access_time,
                  title: 'Eventos urgentes',
                  subtitle:
                      '${calendar.urgentEvents.length} ${calendar.urgentEvents.length == 1 ? 'evento' : 'eventos'} nos próximos 3 dias',
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
              ],

              // Eventos de hoje
              if (calendar.hasEventsToday) ...[
                _buildSection(
                  context,
                  title: 'Hoje',
                  events: calendar.todayEvents,
                ),
                const SizedBox(height: 16),
              ],

              // Próximo evento importante
              if (calendar.nextImportantEvent != null) ...[
                _buildNextEvent(context, calendar.nextImportantEvent!),
                const SizedBox(height: 16),
              ],

              // Resumo da semana
              if (calendar.thisWeekEvents.isNotEmpty) ...[
                _buildWeekSummary(context, calendar),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlert(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<CalendarEventEntity> events,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...events.take(3).map((event) => _buildEventItem(context, event)),
        if (events.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '+ ${events.length - 3} outros eventos',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEventItem(BuildContext context, CalendarEventEntity event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            event.icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (event.description.isNotEmpty)
                  Text(
                    event.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          _buildPriorityBadge(event.priority),
        ],
      ),
    );
  }

  Widget _buildNextEvent(BuildContext context, CalendarEventEntity event) {
    final dateFormat = DateFormat('dd/MM');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Próximo evento importante',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                event.icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dateFormat.format(event.date)} • ${event.dateDescription}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSummary(
      BuildContext context, ReformCalendarEntity calendar) {
    final paymentEvents = calendar.thisWeekEvents
        .where((e) => e.type == CalendarEventType.payment)
        .length;
    final phaseEvents = calendar.thisWeekEvents
        .where((e) =>
            e.type == CalendarEventType.phaseStart ||
            e.type == CalendarEventType.phaseEnd)
        .length;
    final otherEvents =
        calendar.thisWeekEvents.length - paymentEvents - phaseEvents;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Esta semana',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                icon: '',
                count: paymentEvents,
                label: 'Pagamentos',
              ),
              _buildSummaryItem(
                icon: '',
                count: phaseEvents,
                label: 'Fases',
              ),
              _buildSummaryItem(
                icon: '',
                count: otherEvents,
                label: 'Outros',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String icon,
    required int count,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityBadge(EventPriority priority) {
    Color color;
    String label;

    switch (priority) {
      case EventPriority.critical:
        color = Colors.red;
        label = '!!!';
        break;
      case EventPriority.high:
        color = Colors.orange;
        label = '!!';
        break;
      case EventPriority.medium:
        color = Colors.blue;
        label = '!';
        break;
      case EventPriority.low:
        color = Colors.green;
        label = '';
        break;
    }

    if (label.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _exportCalendar(BuildContext context) async {
    try {
      final service = CalendarService();
      await service.exportToCalendar(calendar.events);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📅 Calendário exportado! Escolha onde importar.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao exportar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showAddEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AddEventDialog(
        onEventAdded: (event) {
          // Salva evento no Firestore via Cubit
          context.read<ReformMapCubit>().addCalendarEvent(
                projectId: projectId,
                event: event,
              );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Evento "${event.title}" adicionado!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        },
      ),
    );
  }
}

// Made with Bob
