import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/move_in_task_entity.dart';
import '../../domain/repositories/move_in_repository.dart';
import '../models/move_in_task_model.dart';

/// Implementação do repositório de tarefas do Modo Mudança usando Firestore
@LazySingleton(as: MoveInRepository)
class MoveInRepositoryImpl implements MoveInRepository {
  final FirebaseFirestore firestore;

  MoveInRepositoryImpl({required this.firestore});

  /// Referência para a coleção de tarefas de mudança de um projeto
  CollectionReference _tasksCollection(String projectId) {
    return firestore
        .collection('projects')
        .doc(projectId)
        .collection('move_in_tasks');
  }

  @override
  Future<Either<Failure, List<MoveInTaskEntity>>> getMoveInTasks(
    String projectId,
  ) async {
    try {
      final snapshot = await _tasksCollection(projectId)
          .orderBy('dueDate', descending: false)
          .get();

      final tasks = snapshot.docs
          .map((doc) => MoveInTaskModel.fromFirestore(doc).toEntity())
          .toList();

      return Right(tasks);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao buscar tarefas'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, MoveInTaskEntity>> addTask(
    String projectId,
    MoveInTaskEntity task,
  ) async {
    try {
      // Gera um novo ID se não existir
      final docRef = task.id.isEmpty
          ? _tasksCollection(projectId).doc()
          : _tasksCollection(projectId).doc(task.id);

      // Cria a tarefa com o ID gerado
      final taskWithId = MoveInTaskEntity(
        id: docRef.id,
        title: task.title,
        description: task.description,
        category: task.category,
        dueDate: task.dueDate,
        isCompleted: task.isCompleted,
        isCritical: task.isCritical,
        isCustom: task.isCustom,
        completedAt: task.completedAt,
      );

      final model = MoveInTaskModel.fromEntity(taskWithId);
      await docRef.set(model.toFirestore());

      return Right(taskWithId);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao adicionar tarefa'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, MoveInTaskEntity>> updateTask(
    String projectId,
    MoveInTaskEntity task,
  ) async {
    try {
      if (task.id.isEmpty) {
        return Left(ValidationFailure('ID da tarefa não pode ser vazio'));
      }

      final model = MoveInTaskModel.fromEntity(task);
      await _tasksCollection(projectId)
          .doc(task.id)
          .update(model.toFirestore());

      return Right(task);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao atualizar tarefa'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, MoveInTaskEntity>> toggleTaskCompletion(
    String projectId,
    String taskId,
    bool isCompleted,
  ) async {
    try {
      if (taskId.isEmpty) {
        return Left(ValidationFailure('ID da tarefa não pode ser vazio'));
      }

      final docRef = _tasksCollection(projectId).doc(taskId);
      final doc = await docRef.get();

      if (!doc.exists) {
        return Left(NotFoundFailure('Tarefa não encontrada'));
      }

      final task = MoveInTaskModel.fromFirestore(doc).toEntity();
      final updatedTask = MoveInTaskEntity(
        id: task.id,
        title: task.title,
        description: task.description,
        category: task.category,
        dueDate: task.dueDate,
        isCompleted: isCompleted,
        isCritical: task.isCritical,
        isCustom: task.isCustom,
        completedAt: isCompleted ? DateTime.now() : null,
      );

      await docRef.update({
        'isCompleted': isCompleted,
        'completedAt': isCompleted ? Timestamp.now() : null,
      });

      return Right(updatedTask);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao marcar tarefa'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(
    String projectId,
    String taskId,
  ) async {
    try {
      if (taskId.isEmpty) {
        return Left(ValidationFailure('ID da tarefa não pode ser vazio'));
      }

      final docRef = _tasksCollection(projectId).doc(taskId);
      final doc = await docRef.get();

      if (!doc.exists) {
        return Left(NotFoundFailure('Tarefa não encontrada'));
      }

      // Verifica se é uma tarefa personalizada
      final task = MoveInTaskModel.fromFirestore(doc).toEntity();
      if (!task.isCustom) {
        return Left(
          ValidationFailure(
              'Apenas tarefas personalizadas podem ser deletadas'),
        );
      }

      await docRef.delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao deletar tarefa'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<MoveInTaskEntity>>> watchMoveInTasks(
    String projectId,
  ) {
    try {
      return _tasksCollection(projectId)
          .orderBy('dueDate', descending: false)
          .snapshots()
          .map((snapshot) {
        try {
          final tasks = snapshot.docs
              .map((doc) => MoveInTaskModel.fromFirestore(doc).toEntity())
              .toList();
          return Right<Failure, List<MoveInTaskEntity>>(tasks);
        } catch (e) {
          return Left<Failure, List<MoveInTaskEntity>>(
            ServerFailure('Erro ao processar tarefas: $e'),
          );
        }
      });
    } catch (e) {
      return Stream.value(
        Left<Failure, List<MoveInTaskEntity>>(
          ServerFailure('Erro ao observar tarefas: $e'),
        ),
      );
    }
  }
}

// Made with Bob
