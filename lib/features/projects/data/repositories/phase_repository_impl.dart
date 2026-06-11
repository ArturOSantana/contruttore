import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/phase_entity.dart';
import '../../domain/repositories/phase_repository.dart';
import '../models/phase_model.dart';

@LazySingleton(as: PhaseRepository)
class PhaseRepositoryImpl implements PhaseRepository {
  final FirebaseFirestore _firestore;

  PhaseRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, List<PhaseEntity>>> getPhases(
    String projectId,
  ) async {
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
      final phaseDoc = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('phases')
          .doc(phaseId)
          .get();

      if (!phaseDoc.exists) {
        return Left(ServerFailure('Fase não encontrada'));
      }

      final phase = PhaseModel.fromMap(phaseDoc.data()!, phaseDoc.id);
      return Right(phase);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar fase: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePhase(PhaseEntity phase) async {
    try {
      final phaseModel = PhaseModel.fromEntity(phase);

      await _firestore
          .collection('projects')
          .doc(phase.projectId)
          .collection('phases')
          .doc(phase.id)
          .update(phaseModel.toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar fase: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSubtask(
    String projectId,
    String phaseId,
    SubtaskEntity subtask,
  ) async {
    try {
      // Buscar a fase primeiro
      final phaseResult = await getPhase(projectId, phaseId);

      return phaseResult.fold(
        (failure) => Left(failure),
        (phase) async {
          // Atualizar a subtarefa na lista
          final updatedSubtasks = phase.subtasks.map((s) {
            if (s.id == subtask.id) {
              return subtask;
            }
            return s;
          }).toList();

          // Atualizar a fase com as subtarefas atualizadas
          final updatedPhase = phase.copyWith(subtasks: updatedSubtasks);
          return await updatePhase(updatedPhase);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar subtarefa: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> completePhase(
    String projectId,
    String phaseId,
  ) async {
    try {
      // 1. Buscar a fase atual
      final phaseResult = await getPhase(projectId, phaseId);

      return phaseResult.fold(
        (failure) => Left(failure),
        (currentPhase) async {
          // 2. Marcar fase atual como concluída
          final updatedPhase = currentPhase.copyWith(
            status: PhaseStatus.done,
            endDate: DateTime.now(),
          );
          final updateResult = await updatePhase(updatedPhase);

          // Se falhou ao atualizar, retornar erro
          if (updateResult.isLeft()) {
            return updateResult;
          }

          // 3. Buscar todas as fases para encontrar a próxima
          final phasesResult = await getPhases(projectId);

          return phasesResult.fold(
            (failure) => Right(
                null), // Fase concluída, mas não conseguiu desbloquear próxima
            (allPhases) async {
              // Ordenar por número
              final sortedPhases = List<PhaseEntity>.from(allPhases)
                ..sort((a, b) => a.number.compareTo(b.number));

              // Encontrar índice da fase atual
              final currentIndex =
                  sortedPhases.indexWhere((p) => p.id == phaseId);

              // Se existe próxima fase
              if (currentIndex != -1 &&
                  currentIndex < sortedPhases.length - 1) {
                final nextPhase = sortedPhases[currentIndex + 1];

                // Desbloquear e ativar próxima fase
                final nextPhaseUpdated = nextPhase.copyWith(
                  status: PhaseStatus.active,
                  startDate: DateTime.now(),
                );

                await updatePhase(nextPhaseUpdated);
              }

              return Right(null);
            },
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao completar fase: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> startPhase(
    String projectId,
    String phaseId,
  ) async {
    try {
      final phaseResult = await getPhase(projectId, phaseId);

      return phaseResult.fold(
        (failure) => Left(failure),
        (phase) async {
          final updatedPhase = phase.copyWith(
            status: PhaseStatus.active,
            startDate: DateTime.now(),
          );
          return await updatePhase(updatedPhase);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao iniciar fase: $e'));
    }
  }
}

// Made with Bob
