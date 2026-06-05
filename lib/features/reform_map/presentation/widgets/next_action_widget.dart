import 'package:flutter/material.dart';
import '../../domain/entities/next_action_entity.dart';

/// Widget que mostra a próxima ação recomendada
///
/// O sistema analisa tudo e sugere UMA ação prioritária
class NextActionWidget extends StatelessWidget {
  final NextActionEntity nextAction;
  final VoidCallback? onActionTap;

  const NextActionWidget({
    super.key,
    required this.nextAction,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: _getPriorityColor().withOpacity(0.1),
      child: InkWell(
        onTap: onActionTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getPriorityIcon(),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Próxima Ação',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          _getPriorityText(),
                          style: TextStyle(
                            color: _getPriorityColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                nextAction.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                nextAction.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (nextAction.reason.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          nextAction.reason,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor() {
    switch (nextAction.priority) {
      case ActionPriority.critical:
        return Colors.red;
      case ActionPriority.high:
        return Colors.orange;
      case ActionPriority.medium:
        return Colors.blue;
      case ActionPriority.low:
        return Colors.green;
    }
  }

  IconData _getPriorityIcon() {
    switch (nextAction.priority) {
      case ActionPriority.critical:
        return Icons.error;
      case ActionPriority.high:
        return Icons.warning;
      case ActionPriority.medium:
        return Icons.info;
      case ActionPriority.low:
        return Icons.check_circle;
    }
  }

  String _getPriorityText() {
    switch (nextAction.priority) {
      case ActionPriority.critical:
        return 'URGENTE';
      case ActionPriority.high:
        return 'ALTA PRIORIDADE';
      case ActionPriority.medium:
        return 'PRIORIDADE MÉDIA';
      case ActionPriority.low:
        return 'BAIXA PRIORIDADE';
    }
  }
}

// Made with Bob
