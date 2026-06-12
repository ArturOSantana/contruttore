import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/move_in_task_entity.dart';
import '../repositories/move_in_repository.dart';

/// Parâmetros para marcar/desmarcar tarefa como concluída
class ToggleTaskCompletionParams {
  final String projectId;
  final String taskId;
  final bool isCompleted;

  ToggleTaskCompletionParams({
    required this.projectId,
    required this.taskId,
    required this.isCompleted,
  });
}

/// Use case para marcar/desmarcar uma tarefa como concluída
@lazySingleton
class ToggleTaskCompletionUseCase {
  final MoveInRepository repository;

  ToggleTaskCompletionUseCase(this.repository);

  Future<Either<Failure, MoveInTaskEntity>> call(
    ToggleTaskCompletionParams params,
  ) async {
    if (params.projectId.isEmpty) {
      return Left(ValidationFailure('ID do projeto não pode ser vazio'));
    }

    if (params.taskId.isEmpty) {
      return Left(ValidationFailure('ID da tarefa não pode ser vazio'));
    }

    return await repository.toggleTaskCompletion(
      params.projectId,
      params.taskId,
      params.isCompleted,
    );
  }
}

// Made with Bob
