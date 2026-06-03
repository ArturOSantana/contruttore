import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// Widget para exibir badges de status com cores e ícones
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
    this.icon,
  });

  /// Badge para status de fase
  factory StatusBadge.phaseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'locked':
        return StatusBadge(
          label: 'Bloqueada',
          color: AppColors.textSecondary,
          backgroundColor: AppColors.surfaceVariant,
          icon: Icons.lock_outline,
        );
      case 'active':
        return StatusBadge(
          label: 'Em andamento',
          color: AppColors.info,
          backgroundColor: AppColors.infoLight,
          icon: Icons.play_circle_outline,
        );
      case 'done':
        return StatusBadge(
          label: 'Concluída',
          color: AppColors.success,
          backgroundColor: AppColors.successLight,
          icon: Icons.check_circle_outline,
        );
      case 'done_no_record':
        return StatusBadge(
          label: 'Concluída',
          color: AppColors.success,
          backgroundColor: AppColors.successLight,
          icon: Icons.check_circle,
        );
      default:
        return StatusBadge(label: status, color: AppColors.textSecondary);
    }
  }

  /// Badge para status de fornecedor
  factory StatusBadge.forSupplierStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return StatusBadge(
          label: 'Ativo',
          color: AppColors.info,
          backgroundColor: AppColors.infoLight,
          icon: Icons.work_outline,
        );
      case 'completed':
        return StatusBadge(
          label: 'Concluído',
          color: AppColors.success,
          backgroundColor: AppColors.successLight,
          icon: Icons.check_circle_outline,
        );
      case 'problem':
        return StatusBadge(
          label: 'Problema',
          color: AppColors.error,
          backgroundColor: AppColors.errorLight,
          icon: Icons.warning_amber_outlined,
        );
      default:
        return StatusBadge(label: status, color: AppColors.textSecondary);
    }
  }

  /// Badge para status de parcela
  factory StatusBadge.paymentStatus({
    required bool isPaid,
    required DateTime dueDate,
  }) {
    if (isPaid) {
      return StatusBadge(
        label: 'Pago',
        color: AppColors.success,
        backgroundColor: AppColors.successLight,
        icon: Icons.check_circle,
      );
    }

    final now = DateTime.now();
    final daysUntilDue = dueDate.difference(now).inDays;

    if (daysUntilDue < 0) {
      return StatusBadge(
        label: 'Vencido',
        color: AppColors.error,
        backgroundColor: AppColors.errorLight,
        icon: Icons.error_outline,
      );
    } else if (daysUntilDue <= 3) {
      return StatusBadge(
        label: 'Vence em breve',
        color: AppColors.warning,
        backgroundColor: AppColors.warningLight,
        icon: Icons.warning_amber_outlined,
      );
    } else {
      return StatusBadge(
        label: 'Pendente',
        color: AppColors.info,
        backgroundColor: AppColors.infoLight,
        icon: Icons.schedule,
      );
    }
  }

  /// Alias para compatibilidade - status de parcela
  factory StatusBadge.payment(String status) {
    // Converte string status para o formato esperado
    if (status.toLowerCase() == 'paid' || status.toLowerCase() == 'pago') {
      return StatusBadge(
        label: 'Pago',
        color: AppColors.success,
        backgroundColor: AppColors.successLight,
        icon: Icons.check_circle,
      );
    } else if (status.toLowerCase() == 'overdue' ||
        status.toLowerCase() == 'vencido') {
      return StatusBadge(
        label: 'Vencido',
        color: AppColors.error,
        backgroundColor: AppColors.errorLight,
        icon: Icons.error_outline,
      );
    } else if (status.toLowerCase() == 'pending' ||
        status.toLowerCase() == 'pendente') {
      return StatusBadge(
        label: 'Pendente',
        color: AppColors.info,
        backgroundColor: AppColors.infoLight,
        icon: Icons.schedule,
      );
    } else {
      return StatusBadge(label: status, color: AppColors.textSecondary);
    }
  }

  /// Alias para compatibilidade - status de fornecedor
  factory StatusBadge.forSupplier(String status) {
    return StatusBadge.forSupplierStatus(status);
  }

  /// Badge para prioridade de alerta
  factory StatusBadge.alertPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return StatusBadge(
          label: 'Crítico',
          color: AppColors.error,
          backgroundColor: AppColors.errorLight,
          icon: Icons.error,
        );
      case 'high':
        return StatusBadge(
          label: 'Alto',
          color: AppColors.warning,
          backgroundColor: AppColors.warningLight,
          icon: Icons.warning,
        );
      case 'medium':
        return StatusBadge(
          label: 'Médio',
          color: AppColors.info,
          backgroundColor: AppColors.infoLight,
          icon: Icons.info,
        );
      case 'low':
        return StatusBadge(
          label: 'Baixo',
          color: AppColors.textSecondary,
          backgroundColor: AppColors.surfaceVariant,
          icon: Icons.info_outline,
        );
      default:
        return StatusBadge(label: priority, color: AppColors.textSecondary);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Made with Bob
