import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/phase_entity.dart';

abstract class PhaseRepository {
  Future<Either<Failure, List<PhaseEntity>>> getPhases(String projectId);
  Future<Either<Failure, PhaseEntity>> getPhase(
      String projectId, String phaseId);
  Future<Either<Failure, void>> updatePhase(PhaseEntity phase);
  Future<Either<Failure, void>> updateSubtask(
    String projectId,
    String phaseId,
    SubtaskEntity subtask,
  );
  Future<Either<Failure, void>> completePhase(String projectId, String phaseId);
  Future<Either<Failure, void>> startPhase(String projectId, String phaseId);
}

// Made with Bob
