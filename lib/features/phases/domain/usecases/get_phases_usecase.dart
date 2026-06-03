import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../repositories/phase_repository.dart';

@injectable
class GetPhasesUseCase {
  final PhaseRepository _repository;

  GetPhasesUseCase(this._repository);

  Future<Either<Failure, List<PhaseEntity>>> call(String projectId) {
    return _repository.getPhases(projectId);
  }
}

// Made with Bob
