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

  /// Carregar eventos de hoje
  Future<void> loadTodayEvents(String projectId) async {
    emit(CalendarLoading());
    try {
      final events = await _repository.getTodayEvents(projectId);
      emit(CalendarLoaded(events: events));
    } catch (e) {
      emit(CalendarError('Erro ao carregar eventos de hoje: $e'));
    }
  }

  /// Carregar eventos futuros
  Future<void> loadUpcomingEvents(String projectId) async {
    emit(CalendarLoading());
    try {
      final events = await _repository.getUpcomingEvents(projectId);
      emit(CalendarLoaded(events: events));
    } catch (e) {
      emit(CalendarError('Erro ao carregar eventos futuros: $e'));
    }
  }

  /// Criar novo evento
  Future<void> createEvent(EventEntity event) async {
    try {
      await _repository.createEvent(event);

      // Agendar notificação se necessário
      if (event.hasNotification) {
        final result = await _scheduleNotification(event);
        result.fold(
          (failure) => print('Erro ao agendar notificação: ${failure.message}'),
          (_) => print('Notificação agendada com sucesso'),
        );
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
      final cancelResult = await _cancelNotification(event.id);
      cancelResult.fold(
        (failure) => print('Erro ao cancelar notificação: ${failure.message}'),
        (_) => print('Notificação cancelada'),
      );

      // Agendar nova notificação se necessário
      if (event.hasNotification) {
        final scheduleResult = await _scheduleNotification(event);
        scheduleResult.fold(
          (failure) => print('Erro ao agendar notificação: ${failure.message}'),
          (_) => print('Notificação reagendada'),
        );
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
      await _repository.deleteEvent(eventId);

      // Cancelar notificação
      final result = await _cancelNotification(eventId);
      result.fold(
        (failure) => print('Erro ao cancelar notificação: ${failure.message}'),
        (_) => print('Notificação cancelada'),
      );

      emit(EventDeleted(eventId));
      await loadEvents(projectId);
    } catch (e) {
      emit(CalendarError('Erro ao deletar evento: $e'));
    }
  }

  /// Marcar evento como concluído
  Future<void> completeEvent(EventEntity event) async {
    try {
      final updatedEvent = EventEntity(
        id: event.id,
        projectId: event.projectId,
        title: event.title,
        description: event.description,
        location: event.location,
        startDate: event.startDate,
        endDate: event.endDate,
        type: event.type,
        priority: event.priority,
        status: EventStatus.completed,
        isAllDay: event.isAllDay,
        hasNotification: event.hasNotification,
        notificationMinutesBefore: event.notificationMinutesBefore,
        createdAt: event.createdAt,
        completedAt: DateTime.now(),
      );

      await updateEvent(updatedEvent);
    } catch (e) {
      emit(CalendarError('Erro ao completar evento: $e'));
    }
  }

  /// Cancelar evento
  Future<void> cancelEvent(EventEntity event) async {
    try {
      final updatedEvent = EventEntity(
        id: event.id,
        projectId: event.projectId,
        title: event.title,
        description: event.description,
        location: event.location,
        startDate: event.startDate,
        endDate: event.endDate,
        type: event.type,
        priority: event.priority,
        status: EventStatus.cancelled,
        isAllDay: event.isAllDay,
        hasNotification: event.hasNotification,
        notificationMinutesBefore: event.notificationMinutesBefore,
        createdAt: event.createdAt,
      );

      await updateEvent(updatedEvent);
    } catch (e) {
      emit(CalendarError('Erro ao cancelar evento: $e'));
    }
  }

  /// Filtrar eventos por data
  void filterByDate(DateTime date) {
    if (state is CalendarLoaded) {
      final currentState = state as CalendarLoaded;
      emit(currentState.copyWith(selectedDate: date));
    }
  }

  /// Observar mudanças em tempo real
  Stream<List<EventEntity>> watchEvents(String projectId) {
    return _repository.watchEvents(projectId);
  }
}

// Made with Bob
