import 'package:equatable/equatable.dart';
import '../../domain/entities/event_entity.dart';

/// Estados do calendário
abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class CalendarInitial extends CalendarState {}

/// Carregando eventos
class CalendarLoading extends CalendarState {}

/// Eventos carregados com sucesso
class CalendarLoaded extends CalendarState {
  final List<EventEntity> events;
  final DateTime? selectedDate;

  const CalendarLoaded({
    required this.events,
    this.selectedDate,
  });

  @override
  List<Object?> get props => [events, selectedDate];

  CalendarLoaded copyWith({
    List<EventEntity>? events,
    DateTime? selectedDate,
  }) {
    return CalendarLoaded(
      events: events ?? this.events,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

/// Erro ao carregar eventos
class CalendarError extends CalendarState {
  final String message;

  const CalendarError(this.message);

  @override
  List<Object> get props => [message];
}

/// Evento criado com sucesso
class EventCreated extends CalendarState {
  final EventEntity event;

  const EventCreated(this.event);

  @override
  List<Object> get props => [event];
}

/// Evento atualizado com sucesso
class EventUpdated extends CalendarState {
  final EventEntity event;

  const EventUpdated(this.event);

  @override
  List<Object> get props => [event];
}

/// Evento deletado com sucesso
class EventDeleted extends CalendarState {
  final String eventId;

  const EventDeleted(this.eventId);

  @override
  List<Object> get props => [eventId];
}

// Made with Bob
