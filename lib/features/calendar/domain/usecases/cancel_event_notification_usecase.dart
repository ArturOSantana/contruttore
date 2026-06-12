import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/notification_service.dart';

/// UseCase para cancelar notificação de um evento
@injectable
class CancelEventNotificationUseCase {
  final NotificationService _notificationService;

  CancelEventNotificationUseCase(this._notificationService);

  Future<Either<Failure, void>> call(String eventId) async {
    try {
      await _notificationService.cancelNotification(eventId.hashCode);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao cancelar notificação: $e'));
    }
  }
}

// Made with Bob
