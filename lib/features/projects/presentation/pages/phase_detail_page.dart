import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../domain/entities/phase_entity.dart';

class PhaseDetailPage extends StatelessWidget {
  final PhaseEntity phase;
  final Function(String phaseId, SubtaskEntity subtask)? onToggleSubtask;

  const PhaseDetailPage({
    super.key,
    required this.phase,
    this.onToggleSubtask,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(phase.name),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de informações gerais
            _buildInfoCard(context),

            const SizedBox(height: 24),

            // Seção "O que acontece"
            if (phase.description.isNotEmpty) ...[
              _buildSectionTitle(context, 'Sobre esta fase'),
              const SizedBox(height: 12),
              _buildDescriptionCard(context),
              const SizedBox(height: 24),
            ],

            // Seção de tarefas
            _buildSectionTitle(context, 'Tarefas'),
            const SizedBox(height: 12),
            _buildSubtasksList(context),

            const SizedBox(height: 24),

            // Seção financeira
            if (phase.estimatedBudget > 0) ...[
              _buildSectionTitle(context, 'Orçamento'),
              const SizedBox(height: 12),
              _buildBudgetCard(context),
              const SizedBox(height: 24),
            ],

            // Erro comum
            if (phase.commonMistake != null &&
                phase.commonMistake!.isNotEmpty) ...[
              _buildSectionTitle(context, '⚠️ Atenção'),
              const SizedBox(height: 12),
              _buildWarningCard(context),
              const SizedBox(height: 24),
            ],

            // Informações adicionais
            if (phase.expectedSupplierTypes.isNotEmpty ||
                phase.expectedPurchaseCategories.isNotEmpty) ...[
              _buildSectionTitle(context, 'Informações Adicionais'),
              const SizedBox(height: 12),
              _buildAdditionalInfoCard(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getPhaseColor(phase.status),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${phase.number}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phase.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _StatusBadge(status: phase.status),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Progresso
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progresso',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${phase.progressPercentage.toStringAsFixed(0)}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getPhaseColor(phase.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: phase.progressPercentage / 100,
                minHeight: 10,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getPhaseColor(phase.status),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Informações de data e duração
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.calendar_today,
                    label: 'Início',
                    value: phase.startDate != null
                        ? _formatDate(phase.startDate!)
                        : 'Não iniciada',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.access_time,
                    label: 'Duração',
                    value: '${phase.estimatedDurationDays} dias',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          phase.description,
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildSubtasksList(BuildContext context) {
    if (phase.subtasks.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Nenhuma tarefa definida',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: phase.subtasks.map((subtask) {
        return _SubtaskItem(
          subtask: subtask,
          onToggle: onToggleSubtask != null
              ? () => onToggleSubtask!(phase.id, subtask)
              : null,
        );
      }).toList(),
    );
  }

  Widget _buildBudgetCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Orçamento Previsto',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  CurrencyUtils.format(phase.estimatedBudget),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gasto até agora',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  CurrencyUtils.format(phase.totalSpent),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: phase.isOverBudget
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saldo Restante',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  CurrencyUtils.format(phase.remainingBudget),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: phase.remainingBudget < 0
                        ? AppColors.error
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: AppColors.warning.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                phase.commonMistake!,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (phase.expectedSupplierTypes.isNotEmpty) ...[
              Text(
                'Profissionais Necessários',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: phase.expectedSupplierTypes.map((type) {
                  return Chip(
                    label: Text(type),
                    backgroundColor: AppColors.secondary,
                  );
                }).toList(),
              ),
            ],
            if (phase.expectedSupplierTypes.isNotEmpty &&
                phase.expectedPurchaseCategories.isNotEmpty)
              const SizedBox(height: 16),
            if (phase.expectedPurchaseCategories.isNotEmpty) ...[
              Text(
                'Categorias de Compras',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: phase.expectedPurchaseCategories.map((category) {
                  return Chip(
                    label: Text(category),
                    backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Color _getPhaseColor(PhaseStatus status) {
    switch (status) {
      case PhaseStatus.locked:
        return AppColors.phaseNotStarted;
      case PhaseStatus.active:
        return AppColors.phaseInProgress;
      case PhaseStatus.done:
      case PhaseStatus.doneNoRecord:
        return AppColors.phaseCompleted;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SubtaskItem extends StatelessWidget {
  final SubtaskEntity subtask;
  final VoidCallback? onToggle;

  const _SubtaskItem({
    required this.subtask,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: subtask.isDone,
        onChanged: onToggle != null ? (_) => onToggle!() : null,
        title: Text(
          subtask.name,
          style: theme.textTheme.bodyMedium?.copyWith(
            decoration: subtask.isDone ? TextDecoration.lineThrough : null,
            color: subtask.isDone
                ? AppColors.textSecondary
                : AppColors.textPrimary,
          ),
        ),
        subtitle: subtask.isRequired
            ? Text(
                'Obrigatória',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              )
            : null,
        secondary: subtask.isDone
            ? const Icon(Icons.check_circle, color: AppColors.success)
            : (subtask.isRequired
                ? const Icon(Icons.star, color: AppColors.warning)
                : null),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PhaseStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String label;
    Color color;
    IconData icon;

    switch (status) {
      case PhaseStatus.locked:
        label = 'Bloqueada';
        color = AppColors.phaseNotStarted;
        icon = Icons.lock;
        break;
      case PhaseStatus.active:
        label = 'Em Andamento';
        color = AppColors.phaseInProgress;
        icon = Icons.play_circle_filled;
        break;
      case PhaseStatus.done:
        label = 'Concluída';
        color = AppColors.phaseCompleted;
        icon = Icons.check_circle;
        break;
      case PhaseStatus.doneNoRecord:
        label = 'Concluída';
        color = AppColors.phaseCompleted;
        icon = Icons.check_circle_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Made with Bob
