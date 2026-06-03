import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/alert_entity.dart';

abstract class AlertsRepository {
  Future<Either<Failure, List<AlertEntity>>> getAlerts(String projectId);
  Future<Either<Failure, void>> addAlert(AlertEntity alert);
  Future<Either<Failure, void>> markAsRead(String projectId, String alertId);
  Future<Either<Failure, void>> snoozeAlert(String projectId, String alertId);
  Future<Either<Failure, void>> deleteAlert(String projectId, String alertId);
  Future<Either<Failure, int>> getUnreadCount(String projectId);
  Future<Either<Failure, bool>> alertExists(String projectId, String title);
}

// Made with Bob
