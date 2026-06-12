import 'package:equatable/equatable.dart';
import '../../domain/entities/move_in_task_entity.dart';

/// Estados do Cubit de Modo Mudança
abstract class MoveInState extends Equatable {
  const MoveInState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class MoveInInitial extends MoveInState {
  const MoveInInitial();
}

/// Estado de carregamento
class MoveInLoading extends MoveInState {
  const MoveInLoading();
}

/// Estado de sucesso com lista de tarefas
class MoveInLoaded extends MoveInState {
  final List<MoveInTaskEntity> tasks;
  final MoveInTaskEntity? nextTask; // Próxima tarefa por prioridade

  const MoveInLoaded({
    required this.tasks,
    this.nextTask,
  });

  /// Tarefas pendentes
  List<MoveInTaskEntity> get pendingTasks =>
      tasks.where((t) => !t.isCompleted).toList();

  /// Tarefas concluídas
  List<MoveInTaskEntity> get completedTasks =>
      tasks.where((t) => t.isCompleted).toList();

  /// Tarefas por categoria
  Map<String, List<MoveInTaskEntity>> get tasksByCategory {
    final map = <String, List<MoveInTaskEntity>>{};
    for (final task in tasks) {
      final categoryKey = task.category.name;
      if (!map.containsKey(categoryKey)) {
        map[categoryKey] = [];
      }
      map[categoryKey]!.add(task);
    }
    return map;
  }

  /// Progresso geral (0.0 a 1.0)
  double get progress {
    if (tasks.isEmpty) return 0.0;
    final completed = completedTasks.length;
    return completed / tasks.length;
  }

  /// Porcentagem de conclusão
  int get completionPercentage => (progress * 100).round();

  @override
  List<Object?> get props => [tasks, nextTask];

  MoveInLoaded copyWith({
    List<MoveInTaskEntity>? tasks,
    MoveInTaskEntity? nextTask,
  }) {
    return MoveInLoaded(
      tasks: tasks ?? this.tasks,
      nextTask: nextTask ?? this.nextTask,
    );
  }
}

/// Estado de erro
class MoveInError extends MoveInState {
  final String message;

  const MoveInError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado de operação em andamento (adicionar, atualizar, deletar)
class MoveInOperationInProgress extends MoveInState {
  final List<MoveInTaskEntity> tasks; // Mantém as tarefas atuais
  final String operation; // 'adding', 'updating', 'deleting', 'toggling'

  const MoveInOperationInProgress({
    required this.tasks,
    required this.operation,
  });

  @override
  List<Object?> get props => [tasks, operation];
}

/// Estado de sucesso de operação
class MoveInOperationSuccess extends MoveInState {
  final String message;
  final List<MoveInTaskEntity> tasks;

  const MoveInOperationSuccess({
    required this.message,
    required this.tasks,
  });

  @override
  List<Object?> get props => [message, tasks];
}

// Made with Bob
