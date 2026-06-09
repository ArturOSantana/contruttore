import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

/// Widget que mostra mensagens positivas e encorajadoras
///
/// Sistema Anti-Ansiedade:
/// - Sempre mostra o lado positivo
/// - Nunca usa linguagem alarmista
/// - Foca no que foi conquistado
/// - Minimiza o que falta
/// - Celebra pequenas vitórias
class PositiveMessageWidget extends StatelessWidget {
  final int completedPhases;
  final int totalPhases;
  final int healthScore;
  final int openProblems;
  final bool hasOverdueTasks;

  const PositiveMessageWidget({
    super.key,
    required this.completedPhases,
    required this.totalPhases,
    required this.healthScore,
    required this.openProblems,
    required this.hasOverdueTasks,
  });

  @override
  Widget build(BuildContext context) {
    final message = _getPositiveMessage();
    final icon = _getIcon();
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// Gera mensagem positiva baseada no contexto
  String _getPositiveMessage() {
    // Celebrar conclusões
    if (completedPhases == totalPhases) {
      return 'Parabéns! Você concluiu todas as etapas da reforma!';
    }

    if (completedPhases > 0) {
      final percentage = (completedPhases / totalPhases * 100).round();
      if (percentage >= 80) {
        return 'Você está quase lá! Já concluiu $completedPhases de $totalPhases etapas.';
      }
      if (percentage >= 50) {
        return 'Mais da metade concluída! Você já passou por $completedPhases etapas.';
      }
      return 'Ótimo progresso! Você já concluiu $completedPhases de $totalPhases etapas.';
    }

    // Saúde excelente
    if (healthScore >= 90) {
      return 'Sua reforma está excelente! Continue assim.';
    }

    // Saúde boa
    if (healthScore >= 70) {
      return 'Sua reforma está avançando bem!';
    }

    // Sem problemas críticos
    if (openProblems == 0 && !hasOverdueTasks) {
      return 'Nenhuma pendência crítica identificada.';
    }

    // Poucos problemas
    if (openProblems <= 2) {
      return 'Apenas ${openProblems == 1 ? 'um ponto' : 'alguns pontos'} precisam de atenção.';
    }

    // Mensagem padrão positiva
    return 'Sua reforma está em andamento. Vamos juntos!';
  }

  /// Retorna ícone baseado no contexto
  IconData _getIcon() {
    if (completedPhases == totalPhases) {
      return Icons.celebration;
    }

    if (healthScore >= 90) {
      return Icons.star;
    }

    if (healthScore >= 70) {
      return Icons.thumb_up;
    }

    if (openProblems == 0) {
      return Icons.check_circle;
    }

    return Icons.info;
  }

  /// Retorna cor baseada no contexto
  Color _getColor() {
    if (completedPhases == totalPhases) {
      return AppColors.success;
    }

    if (healthScore >= 90) {
      return AppColors.success;
    }

    if (healthScore >= 70) {
      return AppColors.primary;
    }

    if (healthScore >= 50) {
      return AppColors.warning;
    }

    return AppColors.info;
  }
}

/// Widget que mostra estatísticas de forma positiva
class PositiveStatsWidget extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final double spentAmount;
  final double budgetAmount;
  final int daysElapsed;
  final int? estimatedDays;

  const PositiveStatsWidget({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
    required this.spentAmount,
    required this.budgetAmount,
    required this.daysElapsed,
    this.estimatedDays,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seu Progresso',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildPositiveStat(
          context,
          icon: Icons.check_circle_outline,
          label: 'Tarefas concluídas',
          value: '$completedTasks de $totalTasks',
          color: AppColors.success,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildPositiveStat(
          context,
          icon: Icons.account_balance_wallet_outlined,
          label: 'Orçamento utilizado',
          value: _formatBudget(),
          color: _getBudgetColor(),
        ),
        if (estimatedDays != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildPositiveStat(
            context,
            icon: Icons.calendar_today_outlined,
            label: 'Tempo decorrido',
            value: _formatDays(),
            color: _getTimeColor(),
          ),
        ],
      ],
    );
  }

  Widget _buildPositiveStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatBudget() {
    final percentage = (spentAmount / budgetAmount * 100).round();
    if (percentage <= 80) {
      return '$percentage% (dentro do planejado)';
    }
    if (percentage <= 100) {
      return '$percentage% (próximo do limite)';
    }
    return '$percentage% (requer atenção)';
  }

  Color _getBudgetColor() {
    final percentage = spentAmount / budgetAmount;
    if (percentage <= 0.8) return AppColors.success;
    if (percentage <= 1.0) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDays() {
    if (estimatedDays == null) return '$daysElapsed dias';

    final percentage = (daysElapsed / estimatedDays! * 100).round();
    if (percentage <= 80) {
      return '$daysElapsed de $estimatedDays dias (no prazo)';
    }
    if (percentage <= 100) {
      return '$daysElapsed de $estimatedDays dias (próximo do fim)';
    }
    return '$daysElapsed dias (requer atenção)';
  }

  Color _getTimeColor() {
    if (estimatedDays == null) return AppColors.info;

    final percentage = daysElapsed / estimatedDays!;
    if (percentage <= 0.8) return AppColors.success;
    if (percentage <= 1.0) return AppColors.warning;
    return AppColors.error;
  }
}

/// Widget que mostra próximas ações de forma simples
class SimplifiedNextActionsWidget extends StatelessWidget {
  final String nextAction;
  final VoidCallback? onActionTap;

  const SimplifiedNextActionsWidget({
    super.key,
    required this.nextAction,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Próxima Ação',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            nextAction,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          if (onActionTap != null) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onActionTap,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Fazer Agora'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget que mostra mensagens de encorajamento
class EncouragementWidget extends StatelessWidget {
  final int completedPhases;
  final int totalPhases;

  const EncouragementWidget({
    super.key,
    required this.completedPhases,
    required this.totalPhases,
  });

  @override
  Widget build(BuildContext context) {
    final messages = _getEncouragementMessages();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_emotions,
                color: AppColors.success,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Você está indo bem!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...messages.map((message) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(color: AppColors.success),
                    ),
                    Expanded(
                      child: Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  List<String> _getEncouragementMessages() {
    final messages = <String>[];

    if (completedPhases > 0) {
      messages.add(
          'Você já concluiu $completedPhases etapa${completedPhases > 1 ? 's' : ''}');
    }

    final remaining = totalPhases - completedPhases;
    if (remaining > 0) {
      messages.add(
          'Faltam apenas $remaining etapa${remaining > 1 ? 's' : ''} para concluir');
    }

    messages.add('Cada etapa concluída te aproxima do seu objetivo');
    messages.add('Você está no controle da sua reforma');

    return messages;
  }
}

// Made with Bob
