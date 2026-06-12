import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/move_in_task_entity.dart';
import '../repositories/move_in_repository.dart';

/// Use case para buscar todas as tarefas do Modo Mudança
@lazySingleton
class GetMoveInTasksUseCase implements UseCase<List<MoveInTaskEntity>, String> {
  final MoveInRepository repository;

  GetMoveInTasksUseCase(this.repository);

  @override
  Future<Either<Failure, List<MoveInTaskEntity>>> call(String projectId) async {
    if (projectId.isEmpty) {
      return Left(ValidationFailure('ID do projeto não pode ser vazio'));
    }

    final result = await repository.getMoveInTasks(projectId);

    return result.fold(
      (failure) => Left(failure),
      (tasks) {
        // Ordena as tarefas por prioridade (maior prioridade primeiro)
        final sortedTasks = List<MoveInTaskEntity>.from(tasks)
          ..sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
        return Right(sortedTasks);
      },
    );
  }
}

// Made with Bob
