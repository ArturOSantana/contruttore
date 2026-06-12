import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/notification_service.dart';
import '../entities/event_entity.dart';

/// UseCase para agendar notificação de um evento
@injectable
class ScheduleEventNotificationUseCase {
  final NotificationService _notificationService;

  ScheduleEventNotificationUseCase(this._notificationService);

  Future<Either<Failure, void>> call(EventEntity event) async {
    try {
      if (!event.hasNotification || event.notificationMinutesBefore == null) {
        return const Right(null);
      }

      final notificationTime = event.startDate.subtract(
        Duration(minutes: event.notificationMinutesBefore!),
      );

      // Não agendar se a data já passou
      if (notificationTime.isBefore(DateTime.now())) {
        return const Right(null);
      }

      await _notificationService.scheduleNotification(
        id: event.id.hashCode,
        title: _getNotificationTitle(event.type),
        body: event.title,
        scheduledDate: notificationTime,
        payload: event.id,
      );

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao agendar notificação: $e'));
    }
  }

  String _getNotificationTitle(EventType type) {
    switch (type) {
      case EventType.meeting:
        return '📅 Reunião em breve';
      case EventType.inspection:
        return '🔍 Vistoria agendada';
      case EventType.delivery:
        return '📦 Entrega prevista';
      case EventType.payment:
        return '💰 Pagamento a vencer';
      case EventType.deadline:
        return '⏰ Prazo se aproximando';
      case EventType.reminder:
        return '🔔 Lembrete';
      case EventType.other:
        return '📌 Evento agendado';
    }
  }
}

// Made with Bob
