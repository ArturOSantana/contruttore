import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../injection_container.dart';
import '../cubit/move_in_cubit.dart';
import '../cubit/move_in_state.dart';
import '../widgets/move_in_task_card.dart';
import '../widgets/move_in_progress_card.dart';
import '../widgets/add_task_dialog.dart';

/// Página de gerenciamento de tarefas de mudança
class MoveInPage extends StatelessWidget {
  final String projectId;

  const MoveInPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MoveInCubit>()..loadTasks(projectId),
      child: _MoveInPageContent(projectId: projectId),
    );
  }
}

class _MoveInPageContent extends StatelessWidget {
  final String projectId;

  const _MoveInPageContent({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Mudança'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTaskDialog(context),
            tooltip: 'Adicionar tarefa',
          ),
        ],
      ),
      body: BlocBuilder<MoveInCubit, MoveInState>(
        builder: (context, state) {
          if (state is MoveInLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MoveInError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<MoveInCubit>().loadTasks(projectId),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (state is MoveInLoaded) {
            if (state.tasks.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.moving,
                title: 'Nenhuma tarefa de mudança',
                message: 'Adicione tarefas para organizar sua mudança',
                actionLabel: 'Adicionar Tarefa',
                onAction: () => _showAddTaskDialog(context),
              );
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<MoveInCubit>().loadTasks(projectId),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Card de progresso
                  MoveInProgressCard(
                    totalTasks: state.tasks.length,
                    completedTasks: state.completedTasks.length,
                    progress: state.progress,
                    nextTask: state.nextTask,
                  ),
                  const SizedBox(height: 24),

                  // Tarefas pendentes
                  if (state.pendingTasks.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      'Tarefas Pendentes',
                      state.pendingTasks.length,
                    ),
                    const SizedBox(height: 12),
                    ...state.pendingTasks.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MoveInTaskCard(
                          task: task,
                          onToggle: () => context
                              .read<MoveInCubit>()
                              .toggleTaskCompletion(task.id, !task.isCompleted),
                          onEdit: () => _showEditTaskDialog(context, task),
                          onDelete: task.isCustom
                              ? () => _showDeleteConfirmation(context, task.id)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Tarefas concluídas
                  if (state.completedTasks.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      'Tarefas Concluídas',
                      state.completedTasks.length,
                    ),
                    const SizedBox(height: 12),
                    ...state.completedTasks.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MoveInTaskCard(
                          task: task,
                          onToggle: () => context
                              .read<MoveInCubit>()
                              .toggleTaskCompletion(task.id, !task.isCompleted),
                          onEdit: () => _showEditTaskDialog(context, task),
                          onDelete: task.isCustom
                              ? () => _showDeleteConfirmation(context, task.id)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<MoveInCubit>(),
        child: const AddTaskDialog(),
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, dynamic task) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<MoveInCubit>(),
        child: AddTaskDialog(taskToEdit: task),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir Tarefa'),
        content: const Text(
          'Tem certeza que deseja excluir esta tarefa? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              context.read<MoveInCubit>().deleteTask(taskId);
              Navigator.of(dialogContext).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

// Made with Bob
