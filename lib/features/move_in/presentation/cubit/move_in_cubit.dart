import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/move_in_task_entity.dart';
import '../../domain/usecases/add_move_in_task_usecase.dart';
import '../../domain/usecases/delete_move_in_task_usecase.dart';
import '../../domain/usecases/get_move_in_tasks_usecase.dart';
import '../../domain/usecases/toggle_task_completion_usecase.dart';
import '../../domain/usecases/update_move_in_task_usecase.dart';
import 'move_in_state.dart';

/// Cubit para gerenciar o estado do Modo Mudança
class MoveInCubit extends Cubit<MoveInState> {
  final GetMoveInTasksUseCase getMoveInTasksUseCase;
  final AddMoveInTaskUseCase addMoveInTaskUseCase;
  final UpdateMoveInTaskUseCase updateMoveInTaskUseCase;
  final ToggleTaskCompletionUseCase toggleTaskCompletionUseCase;
  final DeleteMoveInTaskUseCase deleteMoveInTaskUseCase;

  StreamSubscription? _tasksSubscription;
  String? _currentProjectId;

  MoveInCubit({
    required this.getMoveInTasksUseCase,
    required this.addMoveInTaskUseCase,
    required this.updateMoveInTaskUseCase,
    required this.toggleTaskCompletionUseCase,
    required this.deleteMoveInTaskUseCase,
  }) : super(const MoveInInitial());

  /// Carrega as tarefas de um projeto
  Future<void> loadTasks(String projectId) async {
    _currentProjectId = projectId;
    emit(const MoveInLoading());

    final result = await getMoveInTasksUseCase(projectId);

    result.fold(
      (failure) => emit(MoveInError(failure.message)),
      (tasks) {
        final nextTask = _getNextTask(tasks);
        emit(MoveInLoaded(tasks: tasks, nextTask: nextTask));
      },
    );
  }

  /// Adiciona uma nova tarefa personalizada
  Future<void> addTask(MoveInTaskEntity task) async {
    if (_currentProjectId == null) {
      emit(const MoveInError('Nenhum projeto selecionado'));
      return;
    }

    final currentState = state;
    if (currentState is MoveInLoaded) {
      emit(MoveInOperationInProgress(
        tasks: currentState.tasks,
        operation: 'adding',
      ));
    }

    final result = await addMoveInTaskUseCase(
      AddMoveInTaskParams(
        projectId: _currentProjectId!,
        task: task,
      ),
    );

    result.fold(
      (failure) {
        if (currentState is MoveInLoaded) {
          emit(MoveInLoaded(
            tasks: currentState.tasks,
            nextTask: currentState.nextTask,
          ));
        }
        emit(MoveInError(failure.message));
      },
      (newTask) async {
        // Recarrega as tarefas para atualizar a lista
        await loadTasks(_currentProjectId!);
        emit(MoveInOperationSuccess(
          message: 'Tarefa adicionada com sucesso',
          tasks: (state as MoveInLoaded).tasks,
        ));
      },
    );
  }

  /// Atualiza uma tarefa existente
  Future<void> updateTask(MoveInTaskEntity task) async {
    if (_currentProjectId == null) {
      emit(const MoveInError('Nenhum projeto selecionado'));
      return;
    }

    final currentState = state;
    if (currentState is MoveInLoaded) {
      emit(MoveInOperationInProgress(
        tasks: currentState.tasks,
        operation: 'updating',
      ));
    }

    final result = await updateMoveInTaskUseCase(
      UpdateMoveInTaskParams(
        projectId: _currentProjectId!,
        task: task,
      ),
    );

    result.fold(
      (failure) {
        if (currentState is MoveInLoaded) {
          emit(MoveInLoaded(
            tasks: currentState.tasks,
            nextTask: currentState.nextTask,
          ));
        }
        emit(MoveInError(failure.message));
      },
      (updatedTask) async {
        // Recarrega as tarefas para atualizar a lista
        await loadTasks(_currentProjectId!);
        emit(MoveInOperationSuccess(
          message: 'Tarefa atualizada com sucesso',
          tasks: (state as MoveInLoaded).tasks,
        ));
      },
    );
  }

  /// Marca/desmarca uma tarefa como concluída
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    if (_currentProjectId == null) {
      emit(const MoveInError('Nenhum projeto selecionado'));
      return;
    }

    final currentState = state;
    if (currentState is MoveInLoaded) {
      // Atualização otimista na UI
      final updatedTasks = currentState.tasks.map((task) {
        if (task.id == taskId) {
          return MoveInTaskEntity(
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
        }
        return task;
      }).toList();

      final nextTask = _getNextTask(updatedTasks);
      emit(MoveInLoaded(tasks: updatedTasks, nextTask: nextTask));
    }

    final result = await toggleTaskCompletionUseCase(
      ToggleTaskCompletionParams(
        projectId: _currentProjectId!,
        taskId: taskId,
        isCompleted: isCompleted,
      ),
    );

    result.fold(
      (failure) {
        // Reverte em caso de erro
        if (currentState is MoveInLoaded) {
          emit(MoveInLoaded(
            tasks: currentState.tasks,
            nextTask: currentState.nextTask,
          ));
        }
        emit(MoveInError(failure.message));
      },
      (_) {
        // Sucesso - já atualizamos otimisticamente
      },
    );
  }

  /// Deleta uma tarefa personalizada
  Future<void> deleteTask(String taskId) async {
    if (_currentProjectId == null) {
      emit(const MoveInError('Nenhum projeto selecionado'));
      return;
    }

    final currentState = state;
    if (currentState is MoveInLoaded) {
      emit(MoveInOperationInProgress(
        tasks: currentState.tasks,
        operation: 'deleting',
      ));
    }

    final result = await deleteMoveInTaskUseCase(
      DeleteMoveInTaskParams(
        projectId: _currentProjectId!,
        taskId: taskId,
      ),
    );

    result.fold(
      (failure) {
        if (currentState is MoveInLoaded) {
          emit(MoveInLoaded(
            tasks: currentState.tasks,
            nextTask: currentState.nextTask,
          ));
        }
        emit(MoveInError(failure.message));
      },
      (_) async {
        // Recarrega as tarefas para atualizar a lista
        await loadTasks(_currentProjectId!);
        emit(MoveInOperationSuccess(
          message: 'Tarefa deletada com sucesso',
          tasks: (state as MoveInLoaded).tasks,
        ));
      },
    );
  }

  /// Retorna a próxima tarefa baseada na prioridade
  /// Tarefas não concluídas são ordenadas por priorityScore (maior primeiro)
  MoveInTaskEntity? _getNextTask(List<MoveInTaskEntity> tasks) {
    final pendingTasks = tasks.where((t) => !t.isCompleted).toList();
    if (pendingTasks.isEmpty) return null;

    // Ordena por prioridade (maior primeiro)
    pendingTasks.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
    return pendingTasks.first;
  }

  /// Limpa o estado de sucesso/erro e volta para loaded
  void clearOperationState() {
    final currentState = state;
    if (currentState is MoveInOperationSuccess) {
      final nextTask = _getNextTask(currentState.tasks);
      emit(MoveInLoaded(tasks: currentState.tasks, nextTask: nextTask));
    } else if (currentState is MoveInError && _currentProjectId != null) {
      loadTasks(_currentProjectId!);
    }
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}

// Made with Bob
