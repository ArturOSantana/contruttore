import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';

class SavingsBanner extends StatelessWidget {
  final double maxSavings;
  final double savingsPercent;

  const SavingsBanner({
    super.key,
    required this.maxSavings,
    required this.savingsPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.success, AppColors.success.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.savings_outlined,
            color: AppColors.textInverse,
            size: 32,
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Economia Potencial',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textInverse,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  CurrencyUtils.format(maxSavings),
                  style: AppTextStyles.moneyLarge.copyWith(
                    color: AppColors.textInverse,
                  ),
                ),
                Text(
                  '${savingsPercent.toStringAsFixed(1)}% de diferença',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textInverse.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Made with Bob
