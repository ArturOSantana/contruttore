import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/glossary_term_entity.dart';

class GlossaryTermCard extends StatelessWidget {
  final GlossaryTermEntity term;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const GlossaryTermCard({
    super.key,
    required this.term,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  Color _getCategoryColor() {
    switch (term.category) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return Card(
      elevation: 2,
      shadowColor: AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.5), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Termo + Favorito
              Row(
                children: [
                  Expanded(
                    child: Text(
                      term.term,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: AppColors.error,
                      size: 20,
                    ),
                    onPressed: onFavoriteToggle,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xs),

              // Categoria
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs / 2,
                ),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: categoryColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  term.category.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: categoryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Definição (preview)
              Text(
                term.definition,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Fase relacionada (se houver)
              if (term.relatedPhase != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.construction,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: AppSpacing.xs / 2),
                    Text(
                      'Fase ${term.relatedPhase}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Made with Bob
