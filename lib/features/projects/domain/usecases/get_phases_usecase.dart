import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/phase_entity.dart';
import '../repositories/phase_repository.dart';

@injectable
class GetPhasesUsecase implements UseCase<List<PhaseEntity>, String> {
  final PhaseRepository _repository;

  GetPhasesUsecase(this._repository);

  @override
  Future<Either<Failure, List<PhaseEntity>>> call(String projectId) async {
    return await _repository.getPhases(projectId);
  }
}

// Made with Bob
