import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/glossary_term_entity.dart';

class GlossaryCategoryChip extends StatelessWidget {
  final String label;
  final GlossaryCategory? category;
  final bool isSelected;
  final VoidCallback onTap;

  const GlossaryCategoryChip({
    super.key,
    required this.label,
    this.category,
    required this.isSelected,
    required this.onTap,
  });

  Color _getCategoryColor() {
    if (category == null) return AppColors.primary;

    switch (category!) {
      case GlossaryCategory.documentation:
        return AppColors.info;
      case GlossaryCategory.structure:
        return const Color(0xFF795548); // Brown
      case GlossaryCategory.installations:
        return const Color(0xFFFF9800); // Orange
      case GlossaryCategory.finishing:
        return const Color(0xFF9C27B0); // Purple
      case GlossaryCategory.financial:
        return AppColors.success;
      case GlossaryCategory.condominium:
        return const Color(0xFF607D8B); // Blue Grey
      case GlossaryCategory.safety:
        return const Color(0xFFF44336); // Red
      case GlossaryCategory.sustainability:
        return const Color(0xFF4CAF50); // Green
      case GlossaryCategory.maintenance:
        return const Color(0xFF2196F3); // Blue
      case GlossaryCategory.technology:
        return const Color(0xFF00BCD4); // Cyan
      case GlossaryCategory.landscaping:
        return const Color(0xFF8BC34A); // Light Green
      case GlossaryCategory.accessibility:
        return const Color(0xFF673AB7); // Deep Purple
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor();

    return Material(
      color: isSelected ? color : AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: isSelected ? AppColors.textOnPrimary : color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// Made with Bob
