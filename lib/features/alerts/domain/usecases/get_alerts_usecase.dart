import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/alert_entity.dart';
import '../repositories/alerts_repository.dart';

@injectable
class GetAlertsUseCase {
  final AlertsRepository _repository;

  GetAlertsUseCase(this._repository);

  Future<Either<Failure, List<AlertEntity>>> call(String projectId) {
    return _repository.getAlerts(projectId);
  }
}

// Made with Bob
