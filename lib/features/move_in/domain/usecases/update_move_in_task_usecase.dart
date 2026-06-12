import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/move_in_task_entity.dart';
import '../repositories/move_in_repository.dart';

/// Parâmetros para atualizar uma tarefa
class UpdateMoveInTaskParams {
  final String projectId;
  final MoveInTaskEntity task;

  UpdateMoveInTaskParams({
    required this.projectId,
    required this.task,
  });
}

/// Use case para atualizar uma tarefa existente
@lazySingleton
class UpdateMoveInTaskUseCase {
  final MoveInRepository repository;

  UpdateMoveInTaskUseCase(this.repository);

  Future<Either<Failure, MoveInTaskEntity>> call(
    UpdateMoveInTaskParams params,
  ) async {
    if (params.projectId.isEmpty) {
      return Left(ValidationFailure('ID do projeto não pode ser vazio'));
    }

    if (params.task.id.isEmpty) {
      return Left(ValidationFailure('ID da tarefa não pode ser vazio'));
    }

    if (params.task.title.trim().isEmpty) {
      return Left(ValidationFailure('Título da tarefa não pode ser vazio'));
    }

    // Cria uma cópia com valores limpos
    final updatedTask = MoveInTaskEntity(
      id: params.task.id,
      title: params.task.title.trim(),
      description: params.task.description.trim(),
      category: params.task.category,
      dueDate: params.task.dueDate,
      isCompleted: params.task.isCompleted,
      isCritical: params.task.isCritical,
      isCustom: params.task.isCustom,
      completedAt: params.task.completedAt,
    );

    return await repository.updateTask(params.projectId, updatedTask);
  }
}

// Made with Bob
