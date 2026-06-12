import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/calendar_cubit.dart';
import '../cubit/calendar_state.dart';
import '../../domain/entities/event_entity.dart';

class CalendarPage extends StatelessWidget {
  final String projectId;

  const CalendarPage({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navegar para página de adicionar evento
              // Navigator.pushNamed(context, '/calendar/add', arguments: projectId);
            },
          ),
        ],
      ),
      body: BlocBuilder<CalendarCubit, CalendarState>(
        builder: (context, state) {
          if (state is CalendarLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CalendarError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CalendarCubit>().loadEvents(projectId);
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (state is CalendarLoaded) {
            final events = state.events;

            if (events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, size: 64),
                    const SizedBox(height: 16),
                    const Text('Nenhum evento agendado'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Navegar para adicionar evento
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar evento'),
                    ),
                  ],
                ),
              );
            }

            // Agrupar eventos por data
            final groupedEvents = _groupEventsByDate(events);

            return ListView.builder(
              itemCount: groupedEvents.length,
              itemBuilder: (context, index) {
                final date = groupedEvents.keys.elementAt(index);
                final dateEvents = groupedEvents[date]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _formatDate(date),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    ...dateEvents
                        .map((event) => _buildEventCard(context, event)),
                  ],
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Map<DateTime, List<EventEntity>> _groupEventsByDate(
      List<EventEntity> events) {
    final grouped = <DateTime, List<EventEntity>>{};

    for (final event in events) {
      final date = DateTime(
        event.startDate.year,
        event.startDate.month,
        event.startDate.day,
      );

      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(event);
    }

    // Ordenar por data
    final sortedKeys = grouped.keys.toList()..sort();
    final sortedMap = <DateTime, List<EventEntity>>{};
    for (final key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }

    return sortedMap;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (date == today) {
      return 'Hoje';
    } else if (date == tomorrow) {
      return 'Amanhã';
    } else {
      return DateFormat('EEEE, d MMMM', 'pt_BR').format(date);
    }
  }

  Widget _buildEventCard(BuildContext context, EventEntity event) {
    final isPast = event.startDate.isBefore(DateTime.now());
    final isCompleted = event.status == EventStatus.completed;
    final isCancelled = event.status == EventStatus.cancelled;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getEventColor(event.type).withOpacity(0.2),
          child: Icon(
            _getEventIcon(event.type),
            color: _getEventColor(event.type),
          ),
        ),
        title: Text(
          event.title,
          style: TextStyle(
            decoration:
                isCompleted || isCancelled ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, size: 14),
                const SizedBox(width: 4),
                Text(
                  event.isAllDay
                      ? 'Dia inteiro'
                      : DateFormat('HH:mm').format(event.startDate),
                ),
                if (event.hasNotification) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.notifications_active, size: 14),
                ],
              ],
            ),
            if (event.description != null) ...[
              const SizedBox(height: 4),
              Text(
                event.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (event.priority == EventPriority.high)
              Icon(Icons.priority_high, color: Colors.red, size: 20),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showEventOptions(context, event),
            ),
          ],
        ),
        onTap: () {
          // TODO: Navegar para detalhes
        },
      ),
    );
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.meeting:
        return Icons.people;
      case EventType.inspection:
        return Icons.search;
      case EventType.delivery:
        return Icons.local_shipping;
      case EventType.payment:
        return Icons.payment;
      case EventType.deadline:
        return Icons.alarm;
      case EventType.reminder:
        return Icons.notifications;
      case EventType.other:
        return Icons.event;
    }
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.meeting:
        return Colors.blue;
      case EventType.inspection:
        return Colors.orange;
      case EventType.delivery:
        return Colors.green;
      case EventType.payment:
        return Colors.red;
      case EventType.deadline:
        return Colors.purple;
      case EventType.reminder:
        return Colors.teal;
      case EventType.other:
        return Colors.grey;
    }
  }

  void _showEventOptions(BuildContext context, EventEntity event) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (event.status == EventStatus.pending) ...[
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Marcar como concluído'),
              onTap: () {
                Navigator.pop(context);
                context.read<CalendarCubit>().completeEvent(event);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancelar evento'),
              onTap: () {
                Navigator.pop(context);
                context.read<CalendarCubit>().cancelEvent(event);
              },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navegar para edição
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Excluir', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(context, event);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, EventEntity event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir evento'),
        content: const Text('Tem certeza que deseja excluir este evento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<CalendarCubit>().deleteEvent(
                    event.projectId,
                    event.id,
                  );
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

// Made with Bob
