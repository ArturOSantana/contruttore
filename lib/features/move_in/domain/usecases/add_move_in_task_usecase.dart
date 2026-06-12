import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/move_in_task_entity.dart';
import '../repositories/move_in_repository.dart';

/// Parâmetros para adicionar uma tarefa
class AddMoveInTaskParams {
  final String projectId;
  final MoveInTaskEntity task;

  AddMoveInTaskParams({
    required this.projectId,
    required this.task,
  });
}

/// Use case para adicionar uma nova tarefa personalizada
@lazySingleton
class AddMoveInTaskUseCase {
  final MoveInRepository repository;

  AddMoveInTaskUseCase(this.repository);

  Future<Either<Failure, MoveInTaskEntity>> call(
    AddMoveInTaskParams params,
  ) async {
    if (params.projectId.isEmpty) {
      return Left(ValidationFailure('ID do projeto não pode ser vazio'));
    }

    if (params.task.title.trim().isEmpty) {
      return Left(ValidationFailure('Título da tarefa não pode ser vazio'));
    }

    // Garante que a tarefa é marcada como personalizada
    final customTask = MoveInTaskEntity(
      id: params.task.id,
      title: params.task.title.trim(),
      description: params.task.description.trim(),
      category: params.task.category,
      dueDate: params.task.dueDate,
      isCompleted: false, // Nova tarefa sempre começa não concluída
      isCritical: params.task.isCritical,
      isCustom: true, // Sempre marca como personalizada
      completedAt: null,
    );

    return await repository.addTask(params.projectId, customTask);
  }
}

// Made with Bob
