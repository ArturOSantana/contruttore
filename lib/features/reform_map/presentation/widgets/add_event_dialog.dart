import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/reform_calendar_entity.dart';

/// Dialog para adicionar eventos customizados ao calendário
class AddEventDialog extends StatefulWidget {
  final Function(CalendarEventEntity) onEventAdded;

  const AddEventDialog({
    super.key,
    required this.onEventAdded,
  });

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  CalendarEventType _selectedType = CalendarEventType.other;
  EventPriority _selectedPriority = EventPriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Evento'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  hintText: 'Ex: Reunião com arquiteto',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Título é obrigatório';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Descrição
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Detalhes do evento',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Data
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Data'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                onTap: _selectDate,
              ),

              // Hora
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time),
                title: const Text('Hora'),
                subtitle: Text(_selectedTime.format(context)),
                onTap: _selectTime,
              ),

              const SizedBox(height: 16),

              // Tipo de evento
              DropdownButtonFormField<CalendarEventType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Evento',
                  prefixIcon: Icon(Icons.category),
                ),
                items: CalendarEventType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Text(_getEventIcon(type),
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(_getEventTypeName(type)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Prioridade
              DropdownButtonFormField<EventPriority>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Prioridade',
                  prefixIcon: Icon(Icons.priority_high),
                ),
                items: EventPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 12,
                          color: _getPriorityColor(priority),
                        ),
                        const SizedBox(width: 8),
                        Text(_getPriorityName(priority)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedPriority = value);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveEvent,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)), // 2 anos
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      // Combinar data e hora
      final eventDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final event = CalendarEventEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: eventDateTime,
        type: _selectedType,
        priority: _selectedPriority,
        isCompleted: false,
        icon: _getEventIcon(_selectedType),
        color: _getEventColor(_selectedType),
      );

      widget.onEventAdded(event);
      Navigator.pop(context);
    }
  }

  String _getEventIcon(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.payment:
        return '💰';
      case CalendarEventType.delivery:
        return '📦';
      case CalendarEventType.supplierVisit:
        return '👷';
      case CalendarEventType.inspection:
        return '🔍';
      case CalendarEventType.milestone:
        return '🎯';
      case CalendarEventType.phaseStart:
        return '🚀';
      case CalendarEventType.phaseEnd:
        return '🏁';
      case CalendarEventType.meeting:
        return '🤝';
      case CalendarEventType.other:
        return '📌';
    }
  }

  String _getEventTypeName(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.payment:
        return 'Pagamento';
      case CalendarEventType.delivery:
        return 'Entrega';
      case CalendarEventType.supplierVisit:
        return 'Visita de Fornecedor';
      case CalendarEventType.inspection:
        return 'Inspeção';
      case CalendarEventType.milestone:
        return 'Marco Importante';
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

  Color _getPriorityColor(EventPriority priority) {
    switch (priority) {
      case EventPriority.critical:
        return Colors.red;
      case EventPriority.high:
        return Colors.orange;
      case EventPriority.medium:
        return Colors.blue;
      case EventPriority.low:
        return Colors.green;
    }
  }

  String _getPriorityName(EventPriority priority) {
    switch (priority) {
      case EventPriority.critical:
        return 'Crítica';
      case EventPriority.high:
        return 'Alta';
      case EventPriority.medium:
        return 'Média';
      case EventPriority.low:
        return 'Baixa';
    }
  }

  String _getEventColor(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.payment:
        return '#4CAF50'; // Verde
      case CalendarEventType.delivery:
        return '#2196F3'; // Azul
      case CalendarEventType.supplierVisit:
        return '#FF9800'; // Laranja
      case CalendarEventType.inspection:
        return '#9C27B0'; // Roxo
      case CalendarEventType.milestone:
        return '#F44336'; // Vermelho
      case CalendarEventType.phaseStart:
        return '#00BCD4'; // Ciano
      case CalendarEventType.phaseEnd:
        return '#795548'; // Marrom
      case CalendarEventType.meeting:
        return '#607D8B'; // Cinza azulado
      case CalendarEventType.other:
        return '#9E9E9E'; // Cinza
    }
  }
}

// Made with Bob
