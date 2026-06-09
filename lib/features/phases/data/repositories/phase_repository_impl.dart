import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../../domain/repositories/phase_repository.dart';
import '../models/phase_model.dart';

@LazySingleton(as: PhaseRepository)
class PhaseRepositoryImpl implements PhaseRepository {
  final FirebaseFirestore _firestore;

  PhaseRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, List<PhaseEntity>>> getPhases(String projectId) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('phases')
          .orderBy('number')
          .get();

      final phases = snapshot.docs
          .map((doc) => PhaseModel.fromMap(doc.data(), doc.id))
          .toList();

      return Right(phases);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar fases: $e'));
    }
  }

  @override
  Future<Either<Failure, PhaseEntity>> getPhase(
    String projectId,
    String phaseId,
  ) async {
    try {
      final doc = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('phases')
          .doc(phaseId)
          .get();

      if (!doc.exists) {
        return Left(ServerFailure('Fase não encontrada'));
      }

      return Right(PhaseModel.fromMap(doc.data()!, doc.id));
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar fase: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePhase(PhaseEntity phase) async {
    try {
      // Usar set() com merge para criar ou atualizar
      await _firestore
          .collection('projects')
          .doc(phase.projectId)
          .collection('phases')
          .doc(phase.id)
          .set(PhaseModel.fromEntity(phase).toMap(), SetOptions(merge: true));

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar fase: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleSubtask(
    String projectId,
    String phaseId,
    String subtaskId,
  ) async {
    try {
      final phaseResult = await getPhase(projectId, phaseId);

      return phaseResult.fold((failure) => Left(failure), (phase) async {
        final updatedSubtasks = phase.subtasks.map((subtask) {
          if (subtask.id == subtaskId) {
            return SubtaskModel(
              id: subtask.id,
              name: subtask.name,
              isRequired: subtask.isRequired,
              isDone: !subtask.isDone,
              completedAt: !subtask.isDone ? DateTime.now() : null,
              notes: subtask.notes,
            );
          }
          return subtask;
        }).toList();

        final updatedPhase = PhaseModel(
          id: phase.id,
          projectId: phase.projectId,
          number: phase.number,
          name: phase.name,
          description: phase.description,
          status: phase.status,
          startDate: phase.startDate,
          endDate: phase.endDate,
          estimatedDurationDays: phase.estimatedDurationDays,
          subtasks: updatedSubtasks,
          notes: phase.notes,
          glossaryTerms: phase.glossaryTerms,
          commonMistake: phase.commonMistake,
        );

        return updatePhase(updatedPhase);
      });
    } catch (e) {
      return Left(ServerFailure('Erro ao alternar subtarefa: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> completePhase(
    String projectId,
    String phaseId,
  ) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('phases')
          .doc(phaseId)
          .update({
        'status': PhaseStatus.done.name,
        'endDate': Timestamp.now(),
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao concluir fase: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addCustomSubtask(
    String projectId,
    String phaseId,
    SubtaskEntity subtask,
  ) async {
    try {
      final phaseResult = await getPhase(projectId, phaseId);

      return phaseResult.fold((failure) => Left(failure), (phase) {
        final updatedSubtasks = [...phase.subtasks, subtask];

        final updatedPhase = PhaseModel(
          id: phase.id,
          projectId: phase.projectId,
          number: phase.number,
          name: phase.name,
          description: phase.description,
          status: phase.status,
          startDate: phase.startDate,
          endDate: phase.endDate,
          estimatedDurationDays: phase.estimatedDurationDays,
          subtasks: updatedSubtasks,
          notes: phase.notes,
          glossaryTerms: phase.glossaryTerms,
          commonMistake: phase.commonMistake,
        );

        return updatePhase(updatedPhase);
      });
    } catch (e) {
      return Left(ServerFailure('Erro ao adicionar subtarefa: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markPhasesRetroactive({
    required String projectId,
    required List<String> phaseNames,
  }) async {
    try {
      // Buscar todas as fases do projeto
      final phasesResult = await getPhases(projectId);

      return phasesResult.fold(
        (failure) => Left(failure),
        (phases) async {
          // Filtrar fases que devem ser marcadas como retroativas
          final phasesToUpdate = phases
              .where(
                (phase) => phaseNames.contains(phase.name),
              )
              .toList();

          // Atualizar cada fase
          for (final phase in phasesToUpdate) {
            await _firestore
                .collection('projects')
                .doc(projectId)
                .collection('phases')
                .doc(phase.id)
                .update({
              'status': PhaseStatus.doneNoRecord.name,
              'isRetroactive': true,
              'retroactiveMarkedAt': Timestamp.now(),
            });
          }

          return const Right(null);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao marcar fases como retroativas: $e'));
    }
  }
}

// Made with Bob
