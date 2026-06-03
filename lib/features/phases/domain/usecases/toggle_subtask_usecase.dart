import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/phase_repository.dart';

@injectable
class ToggleSubtaskUseCase {
  final PhaseRepository _repository;

  ToggleSubtaskUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required String phaseId,
    required String subtaskId,
  }) {
    return _repository.toggleSubtask(projectId, phaseId, subtaskId);
  }
}

// Made with Bob
