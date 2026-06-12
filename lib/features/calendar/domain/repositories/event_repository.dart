import '../entities/event_entity.dart';

/// Repositório de eventos do calendário
abstract class EventRepository {
  /// Busca todos os eventos de um projeto
  Future<List<EventEntity>> getEvents(String projectId);

  /// Busca eventos por período
  Future<List<EventEntity>> getEventsByDateRange({
    required String projectId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Busca eventos pendentes
  Future<List<EventEntity>> getPendingEvents(String projectId);

  /// Busca eventos de hoje
  Future<List<EventEntity>> getTodayEvents(String projectId);

  /// Busca eventos próximos (próximas 24h)
  Future<List<EventEntity>> getUpcomingEvents(String projectId);

  /// Cria um novo evento
  Future<EventEntity> createEvent(EventEntity event);

  /// Atualiza um evento
  Future<void> updateEvent(EventEntity event);

  /// Deleta um evento
  Future<void> deleteEvent(String eventId);

  /// Marca evento como concluído
  Future<void> completeEvent(String eventId);

  /// Marca evento como cancelado
  Future<void> cancelEvent(String eventId);

  /// Observa mudanças nos eventos de um projeto
  Stream<List<EventEntity>> watchEvents(String projectId);

  /// Observa mudanças em eventos pendentes
  Stream<List<EventEntity>> watchPendingEvents(String projectId);
}

// Made with Bob
