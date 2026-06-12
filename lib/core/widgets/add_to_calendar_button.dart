import 'package:flutter/material.dart';
import '../services/calendar_link_service.dart';

/// Widget de botão para adicionar eventos ao Google Calendar
///
/// Exemplo de uso:
/// ```dart
/// AddToCalendarButton(
///   title: 'Reunião com Pedreiro',
///   startDate: DateTime(2024, 6, 15, 10, 0),
///   endDate: DateTime(2024, 6, 15, 11, 0),
///   description: 'Discutir cronograma',
///   location: 'Canteiro de obras',
/// )
/// ```
class AddToCalendarButton extends StatelessWidget {
  final String title;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  final String? location;
  final bool isAllDay;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final ButtonStyle? style;
  final Widget? icon;
  final Widget? label;

  const AddToCalendarButton({
    super.key,
    required this.title,
    required this.startDate,
    this.endDate,
    this.description,
    this.location,
    this.isAllDay = false,
    this.onSuccess,
    this.onError,
    this.style,
    this.icon,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _handleAddToCalendar(context),
      style: style,
      icon: icon ?? const Icon(Icons.calendar_today),
      label: label ?? const Text('Adicionar ao Calendário'),
    );
  }

  Future<void> _handleAddToCalendar(BuildContext context) async {
    try {
      final success = await CalendarLinkService.openGoogleCalendarLink(
        title: title,
        startDate: startDate,
        endDate: endDate,
        description: description,
        location: location,
        isAllDay: isAllDay,
      );

      if (!context.mounted) return;

      if (success) {
        onSuccess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Evento adicionado ao Google Calendar!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        onError?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Erro ao abrir Google Calendar'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      onError?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Erro: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

/// Botão compacto (apenas ícone) para adicionar ao calendário
class AddToCalendarIconButton extends StatelessWidget {
  final String title;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  final String? location;
  final bool isAllDay;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final Color? color;
  final double? iconSize;
  final String? tooltip;

  const AddToCalendarIconButton({
    super.key,
    required this.title,
    required this.startDate,
    this.endDate,
    this.description,
    this.location,
    this.isAllDay = false,
    this.onSuccess,
    this.onError,
    this.color,
    this.iconSize,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _handleAddToCalendar(context),
      icon: Icon(Icons.calendar_today, size: iconSize),
      color: color ?? Theme.of(context).primaryColor,
      tooltip: tooltip ?? 'Adicionar ao Calendário',
    );
  }

  Future<void> _handleAddToCalendar(BuildContext context) async {
    try {
      final success = await CalendarLinkService.openGoogleCalendarLink(
        title: title,
        startDate: startDate,
        endDate: endDate,
        description: description,
        location: location,
        isAllDay: isAllDay,
      );

      if (!context.mounted) return;

      if (success) {
        onSuccess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('✅ Adicionado ao calendário!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        onError?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Erro ao abrir Google Calendar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      onError?.call();
    }
  }
}

/// Card de evento com botão de adicionar ao calendário
class EventCard extends StatelessWidget {
  final String title;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  final String? location;
  final IconData icon;
  final Color? iconColor;
  final bool isAllDay;

  const EventCard({
    super.key,
    required this.title,
    required this.startDate,
    this.endDate,
    this.description,
    this.location,
    this.icon = Icons.event,
    this.iconColor,
    this.isAllDay = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? theme.primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(startDate, endDate),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (location != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (description != null) ...[
              const SizedBox(height: 12),
              Text(
                description!,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: AddToCalendarButton(
                title: title,
                startDate: startDate,
                endDate: endDate,
                description: description,
                location: location,
                isAllDay: isAllDay,
                icon: const Icon(Icons.calendar_today, size: 18),
                label: const Text('Adicionar ao Calendário'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime start, DateTime? end) {
    if (isAllDay) {
      return '${start.day}/${start.month}/${start.year} - Dia inteiro';
    }

    final startStr =
        '${start.day}/${start.month}/${start.year} às ${start.hour}:${start.minute.toString().padLeft(2, '0')}';

    if (end != null) {
      final endStr = '${end.hour}:${end.minute.toString().padLeft(2, '0')}';
      return '$startStr - $endStr';
    }

    return startStr;
  }
}

// Made with Bob
