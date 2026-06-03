import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/glossary_term_entity.dart';
import '../cubit/glossary_cubit.dart';

class GlossaryTermPage extends StatelessWidget {
  final String termId;

  const GlossaryTermPage({super.key, required this.termId});

  Color _getCategoryColor(GlossaryCategory category) {
    switch (category) {
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
    return BlocBuilder<GlossaryCubit, GlossaryState>(
      builder: (context, state) {
        GlossaryTermEntity? term;

        if (state is GlossaryLoaded) {
          try {
            term = state.terms.firstWhere((t) => t.id == termId);
          } catch (e) {
            // Termo não encontrado
          }
        }

        if (term == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Termo não encontrado')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Termo não encontrado',
                      style: AppTextStyles.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'O termo que você está procurando não existe ou foi removido',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Voltar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final categoryColor = _getCategoryColor(term.category);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(term.term),
            actions: [
              IconButton(
                icon: Icon(Icons.favorite, color: AppColors.error),
                onPressed: () {
                  context.read<GlossaryCubit>().toggleFavorite(term!.id);
                },
                tooltip: 'Favoritar',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título do termo
                Text(
                  term.term,
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Categoria
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: categoryColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    term.category.label,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: categoryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Definição
                _buildSection(
                  icon: Icons.description,
                  title: 'Definição',
                  content: term.definition,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Por que isso importa
                _buildHighlightSection(
                  icon: Icons.lightbulb,
                  title: 'Por que isso importa?',
                  content: term.whyItMatters,
                  color: AppColors.warning,
                ),

                // Erro comum (se houver)
                if (term.commonMistake != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _buildHighlightSection(
                    icon: Icons.warning,
                    title: 'Erro comum',
                    content: term.commonMistake!,
                    color: AppColors.error,
                  ),
                ],

                // Fase relacionada (se houver)
                if (term.relatedPhase != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _buildPhaseCard(context, term.relatedPhase!),
                ],

                // Termos relacionados (se houver)
                if (term.relatedTerms.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _buildRelatedTerms(context, term.relatedTerms, state),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          content,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseCard(BuildContext context, int phaseNumber) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navegar para a fase
          context.pushNamed(
            RouteNames.phaseDetail,
            pathParameters: {'phaseId': phaseNumber.toString()},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.construction,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fase relacionada',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs / 2),
                    Text(
                      'Fase $phaseNumber',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedTerms(
    BuildContext context,
    List<String> relatedTermIds,
    GlossaryState state,
  ) {
    if (state is! GlossaryLoaded) return const SizedBox.shrink();

    final relatedTerms = state.terms
        .where((t) => relatedTermIds.contains(t.id))
        .toList();

    if (relatedTerms.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.link, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Termos relacionados',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: relatedTerms.map((relatedTerm) {
            return ActionChip(
              label: Text(relatedTerm.term),
              onPressed: () {
                context.pushReplacementNamed(
                  RouteNames.glossaryTerm,
                  pathParameters: {'termId': relatedTerm.id},
                );
              },
              backgroundColor: AppColors.surface,
              side: BorderSide(color: AppColors.border),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Made with Bob
