import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/phase_repository.dart';

@injectable
class CompletePhaseUseCase {
  final PhaseRepository _repository;

  CompletePhaseUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required String phaseId,
  }) async {
    // Verificar se todas as subtarefas obrigatórias estão concluídas
    final phaseResult = await _repository.getPhase(projectId, phaseId);

    return phaseResult.fold((failure) => Left(failure), (phase) {
      if (!phase.canComplete) {
        return Left(
          ValidationFailure(
            'Não é possível concluir a fase. Complete todas as subtarefas obrigatórias primeiro.',
          ),
        );
      }
      return _repository.completePhase(projectId, phaseId);
    });
  }
}

// Made with Bob
