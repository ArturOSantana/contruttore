import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/alerts_repository.dart';

@injectable
class MarkAsReadUseCase {
  final AlertsRepository _repository;

  MarkAsReadUseCase(this._repository);

  Future<Either<Failure, void>> call(String projectId, String alertId) {
    return _repository.markAsRead(projectId, alertId);
  }
}

// Made with Bob
