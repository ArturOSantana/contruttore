import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// Widget para exibir barras de progresso customizadas
class ProgressBar extends StatelessWidget {
  final double value; // 0.0 a 1.0
  final double height;
  final Color? color;
  final Color? backgroundColor;
  final bool showPercentage;
  final String? label;
  final BorderRadius? borderRadius;

  const ProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.color,
    this.backgroundColor,
    this.showPercentage = false,
    this.label,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value * 100).clamp(0, 100);
    final progressColor = color ?? _getColorForProgress(percentage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label!, style: AppTextStyles.bodySmall),
              if (showPercentage)
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.xxs),
        ],
        ClipRRect(
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppSpacing.radiusSm),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: height,
            backgroundColor: backgroundColor ?? AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }

  Color _getColorForProgress(num percentage) {
    if (percentage >= 100) {
      return AppColors.success;
    } else if (percentage >= 80) {
      return AppColors.warning;
    } else if (percentage >= 50) {
      return AppColors.info;
    } else {
      return AppColors.primary;
    }
  }
}

/// Widget para exibir progresso circular
class CircularProgress extends StatelessWidget {
  final double value; // 0.0 a 1.0
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final bool showPercentage;
  final Widget? child;

  const CircularProgress({
    super.key,
    required this.value,
    this.size = 48,
    this.strokeWidth = 4,
    this.color,
    this.backgroundColor,
    this.showPercentage = true,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value * 100).clamp(0, 100);
    final progressColor = color ?? _getColorForProgress(percentage);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value.clamp(0.0, 1.0),
            strokeWidth: strokeWidth,
            backgroundColor: backgroundColor ?? AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
          if (child != null)
            child!
          else if (showPercentage)
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Color _getColorForProgress(num percentage) {
    if (percentage >= 100) {
      return AppColors.success;
    } else if (percentage >= 80) {
      return AppColors.warning;
    } else if (percentage >= 50) {
      return AppColors.info;
    } else {
      return AppColors.primary;
    }
  }
}

/// Widget para exibir progresso de subtarefas
class SubtaskProgress extends StatelessWidget {
  final int completed;
  final int total;
  final bool showLabel;

  const SubtaskProgress({
    super.key,
    required this.completed,
    required this.total,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;

    return ProgressBar(
      value: progress,
      label: showLabel ? '$completed de $total concluídas' : null,
      showPercentage: true,
    );
  }
}

// Made with Bob
