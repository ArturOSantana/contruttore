import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/phase_repository.dart';

@injectable
class CompletePhaseUsecase implements UseCase<void, CompletePhaseParams> {
  final PhaseRepository repository;

  CompletePhaseUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(CompletePhaseParams params) async {
    return await repository.completePhase(params.projectId, params.phaseId);
  }
}

class CompletePhaseParams extends Equatable {
  final String projectId;
  final String phaseId;

  const CompletePhaseParams({
    required this.projectId,
    required this.phaseId,
  });

  @override
  List<Object?> get props => [projectId, phaseId];
}

// Made with Bob
