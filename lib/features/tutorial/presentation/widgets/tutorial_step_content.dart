import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/tutorial_step.dart';

/// Widget que exibe o conteúdo de um passo do tutorial
class TutorialStepContent extends StatelessWidget {
  final TutorialStep step;
  final bool isFirstPage;
  final bool isLastPage;

  const TutorialStepContent({
    super.key,
    required this.step,
    this.isFirstPage = false,
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone ou ilustração
          _buildIllustration(),

          const SizedBox(height: AppSpacing.xl),

          // Título
          Text(
            step.title,
            style: AppTextStyles.displayMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.m),

          // Descrição
          Text(
            step.description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xl),

          // Highlights (pontos principais)
          if (step.highlights.isNotEmpty) _buildHighlights(),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    // Como não temos imagens reais, vamos usar ícones grandes e coloridos
    final IconData icon = _getIconFromString(step.iconData);
    final Color iconColor = _getColorForStep();

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(child: Icon(icon, size: 100, color: iconColor)),
    );
  }

  Widget _buildHighlights() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Principais recursos:',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          ...step.highlights.map(
            (highlight) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _getColorForStep(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      highlight,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconFromString(String? iconName) {
    switch (iconName) {
      case 'home_work':
        return Icons.home_work;
      case 'timeline':
        return Icons.timeline;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'store':
        return Icons.store;
      case 'photo_camera':
        return Icons.photo_camera;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'notifications_active':
        return Icons.notifications_active;
      case 'rocket_launch':
        return Icons.rocket_launch;
      default:
        return Icons.info_outline;
    }
  }

  Color _getColorForStep() {
    if (isFirstPage) return AppColors.primary;
    if (isLastPage) return AppColors.success;

    // Cores variadas para cada step
    final colors = [
      AppColors.primary,
      AppColors.phaseBlue,
      AppColors.phaseGreen,
      AppColors.phaseOrange,
      AppColors.phasePurple,
      AppColors.secondary,
      AppColors.warning,
      AppColors.success,
    ];

    return colors[step.title.hashCode % colors.length];
  }
}

// Made with Bob
