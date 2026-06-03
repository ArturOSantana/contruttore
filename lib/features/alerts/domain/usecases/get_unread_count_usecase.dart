import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/alerts_repository.dart';

@injectable
class GetUnreadCountUseCase {
  final AlertsRepository _repository;

  GetUnreadCountUseCase(this._repository);

  Future<Either<Failure, int>> call(String projectId) {
    return _repository.getUnreadCount(projectId);
  }
}

// Made with Bob
