import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/move_in_repository.dart';

/// Parâmetros para deletar uma tarefa
class DeleteMoveInTaskParams {
  final String projectId;
  final String taskId;

  DeleteMoveInTaskParams({
    required this.projectId,
    required this.taskId,
  });
}

/// Use case para deletar uma tarefa personalizada
/// Apenas tarefas personalizadas (isCustom = true) podem ser deletadas
class DeleteMoveInTaskUseCase {
  final MoveInRepository repository;

  DeleteMoveInTaskUseCase(this.repository);

  Future<Either<Failure, void>> call(
    DeleteMoveInTaskParams params,
  ) async {
    if (params.projectId.isEmpty) {
      return Left(ValidationFailure('ID do projeto não pode ser vazio'));
    }

    if (params.taskId.isEmpty) {
      return Left(ValidationFailure('ID da tarefa não pode ser vazio'));
    }

    return await repository.deleteTask(params.projectId, params.taskId);
  }
}

// Made with Bob
