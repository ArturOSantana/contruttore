import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/move_in_task_entity.dart';

/// Card para exibir uma tarefa de mudança
class MoveInTaskCard extends StatelessWidget {
  final MoveInTaskEntity task;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MoveInTaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = task.isOverdue;
    final daysUntilDue = task.daysUntilDue;

    return Card(
      elevation: task.isCompleted ? 0 : 2,
      color: task.isCompleted
          ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.5)
          : null,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com checkbox e título
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) => onToggle(),
                  ),
                  const SizedBox(width: 8),

                  // Título e descrição
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted
                                ? theme.colorScheme.onSurfaceVariant
                                : null,
                          ),
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Ações
                  if (!task.isCompleted) ...[
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: onEdit,
                        tooltip: 'Editar',
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: onDelete,
                        tooltip: 'Excluir',
                      ),
                  ],
                ],
              ),

              // Badges e informações
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Categoria
                  _buildBadge(
                    context,
                    _getCategoryLabel(task.category),
                    _getCategoryIcon(task.category),
                    _getCategoryColor(context, task.category),
                  ),

                  // Crítico
                  if (task.isCritical)
                    _buildBadge(
                      context,
                      'Crítico',
                      Icons.priority_high,
                      theme.colorScheme.error,
                    ),

                  // Data de vencimento
                  if (task.dueDate != null)
                    _buildBadge(
                      context,
                      _formatDueDate(task.dueDate!),
                      Icons.calendar_today,
                      isOverdue
                          ? theme.colorScheme.error
                          : daysUntilDue <= 7
                              ? Colors.orange
                              : theme.colorScheme.primary,
                    ),

                  // Prioridade (score)
                  if (!task.isCompleted)
                    _buildBadge(
                      context,
                      'Prioridade: ${task.priorityScore}',
                      Icons.star,
                      theme.colorScheme.tertiary,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(MoveInTaskCategory category) {
    return category.label;
  }

  IconData _getCategoryIcon(MoveInTaskCategory category) {
    switch (category) {
      case MoveInTaskCategory.essentials:
        return Icons.home;
      case MoveInTaskCategory.utilities:
        return Icons.build;
      case MoveInTaskCategory.cleaning:
        return Icons.cleaning_services;
      case MoveInTaskCategory.inspection:
        return Icons.search;
      case MoveInTaskCategory.documentation:
        return Icons.description;
      case MoveInTaskCategory.moving:
        return Icons.local_shipping;
      case MoveInTaskCategory.decoration:
        return Icons.palette;
    }
  }

  Color _getCategoryColor(BuildContext context, MoveInTaskCategory category) {
    switch (category) {
      case MoveInTaskCategory.essentials:
        return Colors.blue;
      case MoveInTaskCategory.utilities:
        return Colors.orange;
      case MoveInTaskCategory.cleaning:
        return Colors.green;
      case MoveInTaskCategory.inspection:
        return Colors.purple;
      case MoveInTaskCategory.documentation:
        return Colors.indigo;
      case MoveInTaskCategory.moving:
        return Colors.brown;
      case MoveInTaskCategory.decoration:
        return Colors.pink;
    }
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return 'Atrasado ${-difference}d';
    } else if (difference == 0) {
      return 'Hoje';
    } else if (difference == 1) {
      return 'Amanhã';
    } else if (difference <= 7) {
      return 'Em ${difference}d';
    } else {
      return DateFormat('dd/MM').format(date);
    }
  }
}

// Made with Bob
