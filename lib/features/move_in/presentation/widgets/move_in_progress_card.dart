import 'package:flutter/material.dart';
import '../../domain/entities/move_in_task_entity.dart';

/// Card que exibe o progresso geral das tarefas de mudança
class MoveInProgressCard extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;
  final double progress;
  final MoveInTaskEntity? nextTask;

  const MoveInProgressCard({
    super.key,
    required this.totalTasks,
    required this.completedTasks,
    required this.progress,
    this.nextTask,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pendingTasks = totalTasks - completedTasks;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                Icon(
                  Icons.moving,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Progresso da Mudança',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Barra de progresso
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}% Concluído',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$completedTasks de $totalTasks tarefas',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(context, progress),
                    ),
                  ),
                ),
              ],
            ),

            // Próxima tarefa prioritária
            if (nextTask != null && pendingTasks > 0) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.priority_high,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Próxima Prioridade',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      nextTask!.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (nextTask!.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        nextTask!.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (nextTask!.isCritical)
                          Chip(
                            label: const Text('Crítico'),
                            avatar: const Icon(Icons.warning, size: 16),
                            backgroundColor:
                                theme.colorScheme.error.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: theme.colorScheme.error,
                              fontSize: 12,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        Chip(
                          label: Text('Score: ${nextTask!.priorityScore}'),
                          avatar: const Icon(Icons.star, size: 16),
                          backgroundColor:
                              theme.colorScheme.tertiary.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: theme.colorScheme.tertiary,
                            fontSize: 12,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Mensagem de conclusão
            if (pendingTasks == 0 && totalTasks > 0) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.celebration,
                      color: Colors.green[700],
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Parabéns!',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Todas as tarefas foram concluídas!',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(BuildContext context, double progress) {
    if (progress < 0.3) {
      return Colors.red;
    } else if (progress < 0.7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}

// Made with Bob
