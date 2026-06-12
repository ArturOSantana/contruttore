import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/move_in_task_entity.dart';

/// Interface do repositório de tarefas do Modo Mudança
abstract class MoveInRepository {
  /// Busca todas as tarefas de mudança de um projeto
  Future<Either<Failure, List<MoveInTaskEntity>>> getMoveInTasks(
    String projectId,
  );

  /// Adiciona uma nova tarefa
  Future<Either<Failure, MoveInTaskEntity>> addTask(
    String projectId,
    MoveInTaskEntity task,
  );

  /// Atualiza uma tarefa existente
  Future<Either<Failure, MoveInTaskEntity>> updateTask(
    String projectId,
    MoveInTaskEntity task,
  );

  /// Marca/desmarca uma tarefa como concluída
  Future<Either<Failure, MoveInTaskEntity>> toggleTaskCompletion(
    String projectId,
    String taskId,
    bool isCompleted,
  );

  /// Deleta uma tarefa (apenas tarefas personalizadas)
  Future<Either<Failure, void>> deleteTask(
    String projectId,
    String taskId,
  );

  /// Observa mudanças nas tarefas em tempo real
  Stream<Either<Failure, List<MoveInTaskEntity>>> watchMoveInTasks(
    String projectId,
  );
}

// Made with Bob
