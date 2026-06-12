# 📅 Sistema de Calendário - Implementação

## ✅ O que foi implementado

### 1. Estrutura Base do Calendário
- ✅ `EventEntity` - Entidade completa com 7 tipos de eventos
- ✅ `EventModel` - Model para Firestore
- ✅ `EventRepository` - Interface do repositório
- ✅ `EventRepositoryImpl` - Implementação com Firestore
- ✅ `CalendarLinkService` - Geração de links do Google Calendar
- ✅ Widgets prontos (`AddToCalendarButton`, `EventCard`)

### 2. Notificações
- ✅ `ScheduleEventNotificationUseCase` - Agendar notificações
- ✅ `CancelEventNotificationUseCase` - Cancelar notificações
- ✅ `CalendarState` - Estados do calendário

### 3. Documentação
- ✅ `lib/features/calendar/README.md` - Documentação completa
- ✅ `docs/CALENDAR_LINKS_GUIDE.md` - Guia de uso

## 🚧 O que falta implementar

### 1. Cubit do Calendário
Criar `lib/features/calendar/presentation/cubit/calendar_cubit.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/usecases/schedule_event_notification_usecase.dart';
import '../../domain/usecases/cancel_event_notification_usecase.dart';
import 'calendar_state.dart';

@injectable
class CalendarCubit extends Cubit<CalendarState> {
  final EventRepositoryImpl _repository;
  final ScheduleEventNotificationUseCase _scheduleNotification;
  final CancelEventNotificationUseCase _cancelNotification;

  CalendarCubit(
    this._repository,
    this._scheduleNotification,
    this._cancelNotification,
  ) : super(CalendarInitial());

  /// Carregar eventos de um projeto
  Future<void> loadEvents(String projectId) async {
    emit(CalendarLoading());
    try {
      final events = await _repository.getEvents(projectId);
      emit(CalendarLoaded(events: events));
    } catch (e) {
      emit(CalendarError('Erro ao carregar eventos: $e'));
    }
  }

  /// Criar novo evento
  Future<void> createEvent(EventEntity event) async {
    try {
      await _repository.createEvent(event);
      
      // Agendar notificação se necessário
      if (event.hasNotification) {
        await _scheduleNotification(event);
      }
      
      emit(EventCreated(event));
      // Recarregar eventos
      await loadEvents(event.projectId);
    } catch (e) {
      emit(CalendarError('Erro ao criar evento: $e'));
    }
  }

  /// Atualizar evento
  Future<void> updateEvent(EventEntity event) async {
    try {
      await _repository.updateEvent(event);
      
      // Cancelar notificação antiga
      await _cancelNotification(event.id);
      
      // Agendar nova notificação se necessário
      if (event.hasNotification) {
        await _scheduleNotification(event);
      }
      
      emit(EventUpdated(event));
      await loadEvents(event.projectId);
    } catch (e) {
      emit(CalendarError('Erro ao atualizar evento: $e'));
    }
  }

  /// Deletar evento
  Future<void> deleteEvent(String projectId, String eventId) async {
    try {
      await _repository.deleteEvent(projectId, eventId);
      await _cancelNotification(eventId);
      
      emit(EventDeleted(eventId));
      await loadEvents(projectId);
    } catch (e) {
      emit(CalendarError('Erro ao deletar evento: $e'));
    }
  }

  /// Filtrar eventos por data
  void filterByDate(DateTime date) {
    if (state is CalendarLoaded) {
      final currentState = state as CalendarLoaded;
      emit(currentState.copyWith(selectedDate: date));
    }
  }
}
```

### 2. Página de Lista de Eventos
Criar `lib/features/calendar/presentation/pages/calendar_page.dart`:

```dart
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
              // Navegar para página de adicionar evento
              Navigator.pushNamed(
                context,
                '/calendar/add',
                arguments: projectId,
              );
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
                        Navigator.pushNamed(
                          context,
                          '/calendar/add',
                          arguments: projectId,
                        );
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
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    ...dateEvents.map((event) => _buildEventCard(
                          context,
                          event,
                        )),
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
    List<EventEntity> events,
  ) {
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

    return grouped;
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(_getEventIcon(event.type)),
        title: Text(event.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('HH:mm').format(event.startDate)),
            if (event.description != null) Text(event.description!),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (event.hasNotification)
              const Icon(Icons.notifications_active, size: 16),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                _showEventOptions(context, event);
              },
            ),
          ],
        ),
        onTap: () {
          // Navegar para detalhes do evento
          Navigator.pushNamed(
            context,
            '/calendar/details',
            arguments: event,
          );
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

  void _showEventOptions(BuildContext context, EventEntity event) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/calendar/edit',
                arguments: event,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Excluir'),
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
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
```

### 3. Página de Adicionar/Editar Evento
Criar `lib/features/calendar/presentation/pages/add_event_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../cubit/calendar_cubit.dart';
import '../../domain/entities/event_entity.dart';

class AddEventPage extends StatefulWidget {
  final String projectId;
  final EventEntity? event; // null = criar, não-null = editar

  const AddEventPage({
    super.key,
    required this.projectId,
    this.event,
  });

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  late DateTime _startDate;
  late DateTime? _endDate;
  late EventType _type;
  late EventPriority _priority;
  late bool _isAllDay;
  late bool _hasNotification;
  late int _notificationMinutes;

  @override
  void initState() {
    super.initState();
    
    if (widget.event != null) {
      // Modo edição
      final event = widget.event!;
      _titleController.text = event.title;
      _descriptionController.text = event.description ?? '';
      _locationController.text = event.location ?? '';
      _startDate = event.startDate;
      _endDate = event.endDate;
      _type = event.type;
      _priority = event.priority;
      _isAllDay = event.isAllDay;
      _hasNotification = event.hasNotification;
      _notificationMinutes = event.notificationMinutesBefore;
    } else {
      // Modo criação
      _startDate = DateTime.now();
      _endDate = null;
      _type = EventType.other;
      _priority = EventPriority.medium;
      _isAllDay = false;
      _hasNotification = true;
      _notificationMinutes = 60;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Novo Evento' : 'Editar Evento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveEvent,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Tipo
            DropdownButtonFormField<EventType>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
              ),
              items: EventType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getTypeLabel(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _type = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Data e hora de início
            ListTile(
              title: const Text('Data e hora de início'),
              subtitle: Text(_formatDateTime(_startDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDateTime(context, true),
            ),

            // Dia inteiro
            SwitchListTile(
              title: const Text('Dia inteiro'),
              value: _isAllDay,
              onChanged: (value) {
                setState(() => _isAllDay = value);
              },
            ),

            // Notificação
            SwitchListTile(
              title: const Text('Notificação'),
              value: _hasNotification,
              onChanged: (value) {
                setState(() => _hasNotification = value);
              },
            ),

            if (_hasNotification) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _notificationMinutes,
                decoration: const InputDecoration(
                  labelText: 'Notificar antes',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 15, child: Text('15 minutos')),
                  DropdownMenuItem(value: 30, child: Text('30 minutos')),
                  DropdownMenuItem(value: 60, child: Text('1 hora')),
                  DropdownMenuItem(value: 120, child: Text('2 horas')),
                  DropdownMenuItem(value: 1440, child: Text('1 dia')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _notificationMinutes = value);
                  }
                },
              ),
            ],

            const SizedBox(height: 16),

            // Prioridade
            DropdownButtonFormField<EventPriority>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: 'Prioridade',
                border: OutlineInputBorder(),
              ),
              items: EventPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(_getPriorityLabel(priority)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _priority = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Descrição
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Local
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Local',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? _startDate),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && !_isAllDay) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStart ? _startDate : (_endDate ?? _startDate),
        ),
      );

      if (time != null) {
        setState(() {
          final newDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          if (isStart) {
            _startDate = newDate;
          } else {
            _endDate = newDate;
          }
        });
      }
    } else if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final event = EventEntity(
        id: widget.event?.id ?? const Uuid().v4(),
        projectId: widget.projectId,
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        location: _locationController.text.isEmpty
            ? null
            : _locationController.text,
        startDate: _startDate,
        endDate: _endDate,
        type: _type,
        priority: _priority,
        isAllDay: _isAllDay,
        hasNotification: _hasNotification,
        notificationMinutesBefore: _notificationMinutes,
        status: widget.event?.status ?? EventStatus.pending,
        createdAt: widget.event?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.event == null) {
        context.read<CalendarCubit>().createEvent(event);
      } else {
        context.read<CalendarCubit>().updateEvent(event);
      }

      Navigator.pop(context);
    }
  }

  String _formatDateTime(DateTime date) {
    if (_isAllDay) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return '${date.day}/${date.month}/${date.year} às ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getTypeLabel(EventType type) {
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

  String _getPriorityLabel(EventPriority priority) {
    switch (priority) {
      case EventPriority.low:
        return 'Baixa';
      case EventPriority.medium:
        return 'Média';
      case EventPriority.high:
        return 'Alta';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
```

### 4. Registrar no Injection Container
Adicionar no `injection_container.dart`:

```dart
// Use cases
getIt.registerLazySingleton(() => ScheduleEventNotificationUseCase(getIt()));
getIt.registerLazySingleton(() => CancelEventNotificationUseCase(getIt()));

// Cubit
getIt.registerFactory(() => CalendarCubit(
  getIt(),
  getIt(),
  getIt(),
));
```

### 5. Adicionar Rotas
No `app_router.dart`:

```dart
GoRoute(
  path: '/calendar',
  builder: (context, state) => BlocProvider(
    create: (context) => getIt<CalendarCubit>()
      ..loadEvents(state.extra as String),
    child: CalendarPage(projectId: state.extra as String),
  ),
),
GoRoute(
  path: '/calendar/add',
  builder: (context, state) => BlocProvider.value(
    value: getIt<CalendarCubit>(),
    child: AddEventPage(projectId: state.extra as String),
  ),
),
```

## 📝 Checklist Final

- [x] Entidades e models
- [x] Repository
- [x] Use cases de notificação
- [x] States
- [ ] Cubit
- [ ] Página de lista
- [ ] Página de adicionar/editar
- [ ] Registro no DI
- [ ] Rotas
- [ ] Testes

## 🎯 Próximos Passos

1. Implementar o `CalendarCubit`
2. Criar as páginas de UI
3. Registrar no injection container
4. Adicionar rotas
5. Testar notificações
6. Integrar com outras features (adicionar eventos a partir de pagamentos, prazos, etc.)

// Made with Bob