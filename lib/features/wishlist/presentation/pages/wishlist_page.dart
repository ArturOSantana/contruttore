import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../cubit/wishlist_cubit.dart';
import '../cubit/wishlist_state.dart';

class WishlistPage extends StatefulWidget {
  final String projectId;

  const WishlistPage({super.key, required this.projectId});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  late final WishlistCubit _cubit;

  // Filtros
  WishlistCategory? _selectedCategory;
  String _dateFilter = 'all';

  @override
  void initState() {
    super.initState();
    _cubit = getIt<WishlistCubit>();
    _cubit.loadWishlistItems(widget.projectId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  // Aplicar filtros
  List<WishlistItemEntity> _applyFilters(List<WishlistItemEntity> items) {
    var filtered = items;

    if (_selectedCategory != null) {
      filtered =
          filtered.where((item) => item.category == _selectedCategory).toList();
    }

    final now = DateTime.now();
    switch (_dateFilter) {
      case 'today':
        final today = DateTime(now.year, now.month, now.day);
        filtered =
            filtered.where((item) => item.createdAt.isAfter(today)).toList();
        break;
      case 'week':
        final weekAgo = now.subtract(Duration(days: 7));
        filtered =
            filtered.where((item) => item.createdAt.isAfter(weekAgo)).toList();
        break;
      case 'month':
        final monthStart = DateTime(now.year, now.month, 1);
        filtered = filtered
            .where((item) => item.createdAt.isAfter(monthStart))
            .toList();
        break;
    }

    return filtered;
  }

  // Excluir múltiplos selecionados
  Future<void> _deleteSelectedItems(List<WishlistItemEntity> items) async {
    final selectedItems = items.where((item) => item.isSelected).toList();

    if (selectedItems.isEmpty) return;

    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Excluir Selecionados',
      message:
          'Deseja excluir ${selectedItems.length} ${selectedItems.length == 1 ? "item" : "itens"} selecionados?',
      confirmLabel: 'Excluir',
      cancelLabel: 'Cancelar',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      for (final item in selectedItems) {
        await _cubit.deleteWishlistItem(widget.projectId, item.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${selectedItems.length} ${selectedItems.length == 1 ? "item excluído" : "itens excluídos"}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lista de Desejos'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          BlocBuilder<WishlistCubit, WishlistState>(
            bloc: _cubit,
            builder: (context, state) {
              if (state is WishlistLoaded && state.selectedCount > 0) {
                return IconButton(
                  icon: Badge(
                    label: Text('${state.selectedCount}'),
                    child: Icon(Icons.delete_sweep),
                  ),
                  tooltip: 'Excluir ${state.selectedCount} selecionados',
                  onPressed: () => _deleteSelectedItems(state.items),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<WishlistCubit, WishlistState>(
        bloc: _cubit,
        listener: (context, state) {
          if (state is WishlistOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is WishlistError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WishlistLoading) {
            return const LoadingWidget(type: LoadingType.grid);
          }

          if (state is WishlistError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    state.message,
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => _cubit.loadWishlistItems(widget.projectId),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          if (state is WishlistLoaded) {
            final filteredItems = _applyFilters(state.items);

            if (filteredItems.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.favorite_border,
                title: state.items.isEmpty
                    ? 'Nenhum item salvo'
                    : 'Nenhum item encontrado',
                message: state.items.isEmpty
                    ? 'Salve links de produtos que você gostou para não perder'
                    : 'Nenhum item corresponde aos filtros selecionados',
                actionLabel: 'Adicionar Link',
                onAction: () async {
                  final result = await context.push(
                    '${RouteNames.wishlistCreate}?projectId=${widget.projectId}',
                  );
                  if (result == true && mounted) {
                    _cubit.loadWishlistItems(widget.projectId);
                  }
                },
              );
            }

            return Column(
              children: [
                _buildSummaryCard(state),
                _buildFilters(),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _buildWishlistCard(item);
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push(
            '${RouteNames.wishlistCreate}?projectId=${widget.projectId}',
          );
          if (result == true && mounted) {
            _cubit.loadWishlistItems(widget.projectId);
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtros',
              style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: AppSpacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: Text('Todos'),
                  selected: _dateFilter == 'all',
                  onSelected: (_) => setState(() => _dateFilter = 'all'),
                ),
                SizedBox(width: AppSpacing.xs),
                FilterChip(
                  label: Text('Hoje'),
                  selected: _dateFilter == 'today',
                  onSelected: (_) => setState(() => _dateFilter = 'today'),
                ),
                SizedBox(width: AppSpacing.xs),
                FilterChip(
                  label: Text('Semana'),
                  selected: _dateFilter == 'week',
                  onSelected: (_) => setState(() => _dateFilter = 'week'),
                ),
                SizedBox(width: AppSpacing.xs),
                FilterChip(
                  label: Text('Mês'),
                  selected: _dateFilter == 'month',
                  onSelected: (_) => setState(() => _dateFilter = 'month'),
                ),
                SizedBox(width: AppSpacing.md),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: DropdownButton<WishlistCategory?>(
                    value: _selectedCategory,
                    hint: Text('Categoria'),
                    underline: SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(
                          value: null, child: Text('Todas Categorias')),
                      ...WishlistCategory.values.map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat.displayName),
                          )),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(WishlistLoaded state) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            icon: Icons.favorite,
            label: 'Total',
            value: state.totalCount.toString(),
            color: AppColors.primary,
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          _buildSummaryItem(
            icon: Icons.check_circle,
            label: 'Selecionados',
            value: state.selectedCount.toString(),
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: AppTextStyles.headlineLarge.copyWith(color: color)),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildWishlistCard(WishlistItemEntity item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: item.isSelected
            ? Border.all(color: AppColors.success, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: item.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(AppSpacing.radiusMd),
                          ),
                          child: Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: AppColors.textTertiary,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.image,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                ),
                // Badge de selecionado
                if (item.isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.tiny,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 12,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Selecionado',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Informações
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.storeName != null) ...[
                    SizedBox(height: AppSpacing.tiny),
                    Text(
                      item.storeName!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (item.price != null) ...[
                    SizedBox(height: AppSpacing.tiny),
                    Text(
                      'R\$ ${item.price!.toStringAsFixed(2)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      // Botão de abrir link
                      Expanded(
                        child: IconButton(
                          onPressed: () => _openUrl(item.url),
                          icon: const Icon(Icons.open_in_new, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      // Botão de compartilhar
                      IconButton(
                        onPressed: () => _shareItem(item),
                        icon: const Icon(Icons.share, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      // Botão de selecionar
                      IconButton(
                        onPressed: () => _toggleSelected(item),
                        icon: Icon(
                          item.isSelected
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: item.isSelected
                              ? AppColors.success
                              : AppColors.surfaceVariant,
                          foregroundColor:
                              item.isSelected ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      // Menu de opções
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await context.push(
                              '${RouteNames.wishlistCreate}?projectId=${widget.projectId}',
                              extra: item,
                            );

                            if (mounted) {
                              _cubit.loadWishlistItems(widget.projectId);
                            }
                          } else if (value == 'delete') {
                            final confirmed = await ConfirmationDialog.show(
                              context,
                              title: 'Excluir Item',
                              message:
                                  'Tem certeza que deseja excluir "${item.name}"?',
                              confirmLabel: 'Excluir',
                              cancelLabel: 'Cancelar',
                              isDestructive: true,
                            );

                            if (confirmed && mounted) {
                              await _cubit.deleteWishlistItem(
                                widget.projectId,
                                item.id,
                              );

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Item excluído com sucesso'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Excluir'),
                              ],
                            ),
                          ),
                        ],
                        icon: const Icon(Icons.more_vert, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o link')),
        );
      }
    }
  }

  void _shareItem(WishlistItemEntity item) {
    final text = '${item.name}\n'
        '${item.storeName != null ? '${item.storeName}\n' : ''}'
        '${item.price != null ? 'R\$ ${item.price!.toStringAsFixed(2)}\n' : ''}'
        '${item.url}';

    Share.share(text, subject: item.name);
  }

  void _toggleSelected(WishlistItemEntity item) {
    _cubit.toggleSelected(
      projectId: widget.projectId,
      itemId: item.id,
      isSelected: !item.isSelected,
      item: item,
    );
  }
}

// Made with Bob
