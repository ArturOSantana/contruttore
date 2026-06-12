import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../models/event_model.dart';

/// Implementação do repositório de eventos usando Firestore
class EventRepositoryImpl implements EventRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  EventRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Referência à coleção de eventos
  CollectionReference get _eventsCollection => _firestore.collection('events');

  /// ID do usuário atual
  String get _userId => _auth.currentUser!.uid;

  @override
  Future<List<EventEntity>> getEvents(String projectId) async {
    try {
      final snapshot = await _eventsCollection
          .where('projectId', isEqualTo: projectId)
          .orderBy('startDate', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar eventos: $e');
    }
  }

  @override
  Future<List<EventEntity>> getEventsByDateRange({
    required String projectId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _eventsCollection
          .where('projectId', isEqualTo: projectId)
          .where('startDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('startDate', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar eventos por período: $e');
    }
  }

  @override
  Future<List<EventEntity>> getPendingEvents(String projectId) async {
    try {
      final snapshot = await _eventsCollection
          .where('projectId', isEqualTo: projectId)
          .where('status', isEqualTo: 'pending')
          .orderBy('startDate', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar eventos pendentes: $e');
    }
  }

  @override
  Future<List<EventEntity>> getTodayEvents(String projectId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      return await getEventsByDateRange(
        projectId: projectId,
        startDate: startOfDay,
        endDate: endOfDay,
      );
    } catch (e) {
      throw Exception('Erro ao buscar eventos de hoje: $e');
    }
  }

  @override
  Future<List<EventEntity>> getUpcomingEvents(String projectId) async {
    try {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      return await getEventsByDateRange(
        projectId: projectId,
        startDate: now,
        endDate: tomorrow,
      );
    } catch (e) {
      throw Exception('Erro ao buscar eventos próximos: $e');
    }
  }

  @override
  Future<EventEntity> createEvent(EventEntity event) async {
    try {
      final model = EventModel.fromEntity(event);
      final docRef = await _eventsCollection.add(model.toFirestore());

      final doc = await docRef.get();
      return EventModel.fromFirestore(doc).toEntity();
    } catch (e) {
      throw Exception('Erro ao criar evento: $e');
    }
  }

  @override
  Future<void> updateEvent(EventEntity event) async {
    try {
      final model = EventModel.fromEntity(event);
      await _eventsCollection.doc(event.id).update(model.toFirestore());
    } catch (e) {
      throw Exception('Erro ao atualizar evento: $e');
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      await _eventsCollection.doc(eventId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar evento: $e');
    }
  }

  @override
  Future<void> completeEvent(String eventId) async {
    try {
      await _eventsCollection.doc(eventId).update({
        'status': 'completed',
        'completedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erro ao completar evento: $e');
    }
  }

  @override
  Future<void> cancelEvent(String eventId) async {
    try {
      await _eventsCollection.doc(eventId).update({
        'status': 'cancelled',
      });
    } catch (e) {
      throw Exception('Erro ao cancelar evento: $e');
    }
  }

  @override
  Stream<List<EventEntity>> watchEvents(String projectId) {
    return _eventsCollection
        .where('projectId', isEqualTo: projectId)
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc).toEntity())
            .toList());
  }

  @override
  Stream<List<EventEntity>> watchPendingEvents(String projectId) {
    return _eventsCollection
        .where('projectId', isEqualTo: projectId)
        .where('status', isEqualTo: 'pending')
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc).toEntity())
            .toList());
  }
}

// Made with Bob
