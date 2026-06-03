import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../projects/domain/entities/phase_entity.dart';

abstract class PhaseRepository {
  Future<Either<Failure, List<PhaseEntity>>> getPhases(String projectId);
  Future<Either<Failure, PhaseEntity>> getPhase(
    String projectId,
    String phaseId,
  );
  Future<Either<Failure, void>> updatePhase(PhaseEntity phase);
  Future<Either<Failure, void>> toggleSubtask(
    String projectId,
    String phaseId,
    String subtaskId,
  );
  Future<Either<Failure, void>> completePhase(String projectId, String phaseId);
  Future<Either<Failure, void>> addCustomSubtask(
    String projectId,
    String phaseId,
    SubtaskEntity subtask,
  );
}

// Made with Bob
