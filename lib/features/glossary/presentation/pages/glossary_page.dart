import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/glossary_term_entity.dart';
import '../cubit/glossary_cubit.dart';
import '../widgets/glossary_category_chip.dart';
import '../widgets/glossary_term_card.dart';
import '../widgets/glossary_shimmer.dart';

class GlossaryPage extends StatefulWidget {
  const GlossaryPage({super.key});

  @override
  State<GlossaryPage> createState() => _GlossaryPageState();
}

class _GlossaryPageState extends State<GlossaryPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Glossário'),
        actions: [
          BlocBuilder<GlossaryCubit, GlossaryState>(
            builder: (context, state) {
              final showOnlyFavorites =
                  state is GlossaryLoaded && state.showOnlyFavorites;
              return IconButton(
                icon: Icon(
                  showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                  color: showOnlyFavorites ? AppColors.error : null,
                ),
                onPressed: () {
                  context.read<GlossaryCubit>().toggleFavoritesFilter();
                },
                tooltip: 'Favoritos',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de busca
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.surface,
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Buscar termo...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<GlossaryCubit>().searchTerms('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              onChanged: (value) {
                context.read<GlossaryCubit>().searchTerms(value);
                setState(() {}); // Para atualizar o botão clear
              },
            ),
          ),

          // Filtros de categoria
          BlocBuilder<GlossaryCubit, GlossaryState>(
            builder: (context, state) {
              final selectedCategory =
                  state is GlossaryLoaded ? state.selectedCategory : null;

              return Container(
                height: 56,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                color: AppColors.surface,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  children: [
                    GlossaryCategoryChip(
                      label: 'Todas',
                      isSelected: selectedCategory == null,
                      onTap: () {
                        context.read<GlossaryCubit>().filterByCategory(null);
                      },
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    ...GlossaryCategory.values.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: GlossaryCategoryChip(
                          label: category.label,
                          category: category,
                          isSelected: selectedCategory == category,
                          onTap: () {
                            context.read<GlossaryCubit>().filterByCategory(
                                  category.name,
                                );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),

          const Divider(height: 1),

          // Lista de termos
          Expanded(
            child: BlocBuilder<GlossaryCubit, GlossaryState>(
              builder: (context, state) {
                if (state is GlossaryLoading) {
                  return const GlossaryShimmer();
                }

                if (state is GlossaryError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.error.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Erro ao carregar glossário',
                            style: AppTextStyles.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            state.message,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<GlossaryCubit>().loadTerms();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is GlossaryLoaded) {
                  if (state.terms.isEmpty) {
                    return _buildEmptyState(context, state);
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: state.terms.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final term = state.terms[index];
                      return GlossaryTermCard(
                        term: term,
                        onTap: () {
                          print(
                              '🔍 Clicou no termo: ${term.term} (ID: ${term.id})');
                          try {
                            context.pushNamed(
                              'glossary-term',
                              pathParameters: {'term': term.id},
                            );
                          } catch (e) {
                            print('❌ Erro ao navegar: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Erro ao abrir termo: $e')),
                            );
                          }
                        },
                        onFavoriteToggle: () {
                          context.read<GlossaryCubit>().toggleFavorite(term.id);
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, GlossaryLoaded state) {
    final hasFilters = state.selectedCategory != null ||
        state.showOnlyFavorites ||
        _searchController.text.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.book_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              hasFilters ? 'Nenhum termo encontrado' : 'Glossário vazio',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hasFilters
                  ? 'Tente ajustar os filtros ou buscar por outro termo'
                  : 'Ainda não há termos cadastrados no glossário',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  context.read<GlossaryCubit>()
                    ..filterByCategory(null)
                    ..searchTerms('');
                  if (state.showOnlyFavorites) {
                    context.read<GlossaryCubit>().toggleFavoritesFilter();
                  }
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpar filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Made with Bob
