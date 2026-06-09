import 'package:flutter/material.dart';
import '../../domain/entities/pending_decision_entity.dart';

/// Widget que exibe as decisões pendentes mais urgentes
///
/// Mostra até 3 decisões ordenadas por urgência
/// Design: Card branco com lista de decisões e badges coloridos
class PendingDecisionsCard extends StatelessWidget {
  final List<PendingDecisionEntity> decisions;
  final VoidCallback? onViewAll;
  final Function(PendingDecisionEntity)? onDecisionTap;

  const PendingDecisionsCard({
    super.key,
    required this.decisions,
    this.onViewAll,
    this.onDecisionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (decisions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Mostrar apenas as 3 mais urgentes
    final topDecisions = decisions.take(3).toList();
    final hasMore = decisions.length > 3;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getHeaderColor(topDecisions.first.urgency)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFF59E0B),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Decisões Pendentes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${decisions.length} ${decisions.length == 1 ? 'decisão precisa' : 'decisões precisam'} de atenção',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Lista de decisões
            ...topDecisions.map((decision) => _buildDecisionItem(
                  context,
                  decision,
                )),

            // Footer - Ver todas
            if (hasMore) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: onViewAll,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ver todas as ${decisions.length} decisões',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDecisionItem(
    BuildContext context,
    PendingDecisionEntity decision,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => onDecisionTap?.call(decision),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getUrgencyColor(decision.urgency).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getUrgencyColor(decision.urgency).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título e badge de urgência
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ícone da categoria
                  Text(
                    decision.categoryIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          decision.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        if (decision.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            decision.description,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Badge de urgência
                  _buildUrgencyBadge(decision),
                ],
              ),

              // Prazo (se houver)
              if (decision.deadline != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      decision.isOverdue
                          ? Icons.error_outline
                          : Icons.schedule_rounded,
                      size: 16,
                      color: decision.isOverdue
                          ? const Color(0xFFEF4444)
                          : decision.isNearDeadline
                              ? const Color(0xFFF59E0B)
                              : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getDeadlineText(decision),
                      style: TextStyle(
                        fontSize: 13,
                        color: decision.isOverdue
                            ? const Color(0xFFEF4444)
                            : decision.isNearDeadline
                                ? const Color(0xFFF59E0B)
                                : Colors.grey[600],
                        fontWeight:
                            decision.isOverdue || decision.isNearDeadline
                                ? FontWeight.w600
                                : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],

              // Fase relacionada (se houver)
              if (decision.phaseName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.construction_rounded,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      decision.phaseName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],

              // Recomendação (se houver)
              if (decision.recommendedOption != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 16,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Recomendado: ${decision.recommendedOption}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w500,
                          ),
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

  Widget _buildUrgencyBadge(PendingDecisionEntity decision) {
    final color = _getUrgencyColor(decision.urgency);
    final text = _getUrgencyText(decision.urgency);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getUrgencyColor(DecisionUrgency urgency) {
    switch (urgency) {
      case DecisionUrgency.critical:
        return const Color(0xFFEF4444); // Vermelho
      case DecisionUrgency.high:
        return const Color(0xFFF59E0B); // Laranja
      case DecisionUrgency.medium:
        return const Color(0xFF3B82F6); // Azul
      case DecisionUrgency.low:
        return const Color(0xFF10B981); // Verde
    }
  }

  String _getUrgencyText(DecisionUrgency urgency) {
    switch (urgency) {
      case DecisionUrgency.critical:
        return 'URGENTE';
      case DecisionUrgency.high:
        return 'ALTA';
      case DecisionUrgency.medium:
        return 'MÉDIA';
      case DecisionUrgency.low:
        return 'BAIXA';
    }
  }

  Color _getHeaderColor(DecisionUrgency urgency) {
    switch (urgency) {
      case DecisionUrgency.critical:
        return const Color(0xFFEF4444);
      case DecisionUrgency.high:
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  String _getDeadlineText(PendingDecisionEntity decision) {
    if (decision.isOverdue) {
      final daysOverdue = decision.daysUntilDeadline!.abs();
      return 'Atrasado há $daysOverdue ${daysOverdue == 1 ? 'dia' : 'dias'}';
    }

    final days = decision.daysUntilDeadline!;
    if (days == 0) {
      return 'Prazo hoje!';
    } else if (days == 1) {
      return 'Prazo amanhã';
    } else if (days <= 7) {
      return 'Prazo em $days dias';
    } else {
      return 'Prazo em ${(days / 7).round()} ${(days / 7).round() == 1 ? 'semana' : 'semanas'}';
    }
  }
}

// Made with Bob
