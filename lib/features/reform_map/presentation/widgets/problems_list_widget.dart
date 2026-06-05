import 'package:flutter/material.dart';
import '../../domain/entities/problem_entity.dart';

/// Widget que mostra lista de problemas ativos
class ProblemsListWidget extends StatelessWidget {
  final List<ProblemEntity> problems;
  final Function(String) onProblemTap;
  final VoidCallback onAddProblem;

  const ProblemsListWidget({
    super.key,
    required this.problems,
    required this.onProblemTap,
    required this.onAddProblem,
  });

  @override
  Widget build(BuildContext context) {
    final activeProblems =
        problems.where((p) => p.status != ProblemStatus.resolved).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Problemas Ativos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (activeProblems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${activeProblems.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (activeProblems.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: Colors.green[300],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nenhum problema ativo',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...activeProblems.map((problem) => _buildProblemItem(
                    context,
                    problem,
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemItem(BuildContext context, ProblemEntity problem) {
    return InkWell(
      onTap: () => onProblemTap(problem.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getSeverityColor(problem.severity).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getSeverityColor(problem.severity).withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getSeverityIcon(problem.severity),
                  color: _getSeverityColor(problem.severity),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    problem.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (problem.status == ProblemStatus.inProgress)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Em andamento',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            if (problem.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                problem.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (problem.financialImpact != null && problem.financialImpact! > 0 || problem.delayDays != null && problem.delayDays! > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (problem.financialImpact != null && problem.financialImpact! > 0) ...[
                    Icon(
                      Icons.attach_money,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    Text(
                      'R\$ ${problem.financialImpact!.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (problem.delayDays != null && problem.delayDays! > 0) ...[
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${problem.delayDays} dias',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(ProblemSeverity severity) {
    switch (severity) {
      case ProblemSeverity.critical:
        return Colors.red;
      case ProblemSeverity.high:
        return Colors.orange;
      case ProblemSeverity.medium:
        return Colors.yellow[700]!;
      case ProblemSeverity.low:
        return Colors.blue;
    }
  }

  IconData _getSeverityIcon(ProblemSeverity severity) {
    switch (severity) {
      case ProblemSeverity.critical:
        return Icons.error;
      case ProblemSeverity.high:
        return Icons.warning;
      case ProblemSeverity.medium:
        return Icons.info;
      case ProblemSeverity.low:
        return Icons.info_outline;
    }
  }
}

// Made with Bob
