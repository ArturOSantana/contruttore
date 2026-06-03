import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/alert_entity.dart';
import '../repositories/alerts_repository.dart';

@injectable
class AddAlertUseCase {
  final AlertsRepository _repository;

  AddAlertUseCase(this._repository);

  Future<Either<Failure, void>> call(AlertEntity alert) {
    return _repository.addAlert(alert);
  }
}

// Made with Bob
