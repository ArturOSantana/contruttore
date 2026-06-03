import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../domain/entities/shopping_item_entity.dart';
import '../cubit/shopping_cubit.dart';
import '../cubit/shopping_state.dart';

/// Página de Lista de Compras
///
/// Exibe todos os itens de compra do projeto com:
/// - Resumo de totais (estimado vs pago)
/// - Lista de itens com checkbox
/// - Filtro por fase e categoria
/// - Marcar como comprado
/// - Sugestões automáticas por fase
class ShoppingPage extends StatefulWidget {
  final String projectId;

  const ShoppingPage({super.key, required this.projectId});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  String? _selectedPhaseFilter;
  ShoppingCategory? _selectedCategoryFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lista de Compras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrar',
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: _showSuggestionsDialog,
            tooltip: 'Gerar sugestões',
          ),
        ],
      ),
      body: BlocConsumer<ShoppingCubit, ShoppingState>(
        listener: (context, state) {
          if (state is ShoppingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is ShoppingOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ShoppingLoading) {
            return const LoadingWidget();
          }

          if (state is ShoppingError) {
            return ErrorWidgetCustom(
              message: state.message,
              onRetry: () => context.read<ShoppingCubit>().loadShoppingItems(
                widget.projectId,
              ),
            );
          }

          if (state is ShoppingLoaded) {
            final filteredItems = _filterItems(state.items);

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<ShoppingCubit>().loadShoppingItems(
                  widget.projectId,
                );
              },
              child: filteredItems.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        _buildSummaryCard(state),
                        if (_selectedPhaseFilter != null ||
                            _selectedCategoryFilter != null)
                          _buildActiveFilters(),
                        Expanded(child: _buildItemsList(filteredItems)),
                      ],
                    ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push(
            '${RouteNames.shoppingCreate}?projectId=${widget.projectId}',
          );
          if (result == true && mounted) {
            context.read<ShoppingCubit>().loadShoppingItems(widget.projectId);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Item'),
      ),
    );
  }

  List<ShoppingItemEntity> _filterItems(List<ShoppingItemEntity> items) {
    var filtered = items;

    if (_selectedPhaseFilter != null) {
      filtered = filtered
          .where((item) => item.phaseId == _selectedPhaseFilter)
          .toList();
    }

    if (_selectedCategoryFilter != null) {
      filtered = filtered
          .where((item) => item.category == _selectedCategoryFilter)
          .toList();
    }

    return filtered;
  }

  Widget _buildSummaryCard(ShoppingLoaded state) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.m),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.pending_outlined,
                  label: 'Pendentes',
                  value: state.pendingCount.toString(),
                  color: AppColors.warning,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.border),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.check_circle_outline,
                  label: 'Comprados',
                  value: state.purchasedCount.toString(),
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.attach_money,
                  label: 'Estimado',
                  value: CurrencyUtils.format(state.totalEstimated),
                  color: AppColors.info,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.border),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.paid_outlined,
                  label: 'Pago',
                  value: CurrencyUtils.format(state.totalPaid),
                  color: AppColors.primary,
                ),
              ),
            ],
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
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(value, style: AppTextStyles.headingMedium.copyWith(color: color)),
      ],
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      color: AppColors.infoLight,
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 16, color: AppColors.info),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Wrap(
              spacing: AppSpacing.s,
              children: [
                if (_selectedPhaseFilter != null)
                  Chip(
                    label: Text('Fase $_selectedPhaseFilter'),
                    onDeleted: () =>
                        setState(() => _selectedPhaseFilter = null),
                    deleteIcon: const Icon(Icons.close, size: 16),
                  ),
                if (_selectedCategoryFilter != null)
                  Chip(
                    label: Text(_selectedCategoryFilter!.displayName),
                    onDeleted: () =>
                        setState(() => _selectedCategoryFilter = null),
                    deleteIcon: const Icon(Icons.close, size: 16),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedPhaseFilter = null;
                _selectedCategoryFilter = null;
              });
            },
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.shopping_cart_outlined,
      title: 'Nenhum item na lista',
      message: _selectedPhaseFilter != null || _selectedCategoryFilter != null
          ? 'Nenhum item encontrado com os filtros aplicados'
          : 'Adicione itens manualmente ou gere sugestões por fase',
      actionLabel: 'Adicionar Item',
      onAction: _showAddItemDialog,
    );
  }

  Widget _buildItemsList(List<ShoppingItemEntity> items) {
    // Agrupar por categoria
    final itemsByCategory = <ShoppingCategory, List<ShoppingItemEntity>>{};
    for (final item in items) {
      itemsByCategory.putIfAbsent(item.category, () => []).add(item);
    }

    final categories = itemsByCategory.keys.toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryItems = itemsByCategory[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.s,
                bottom: AppSpacing.s,
                top: index > 0 ? AppSpacing.m : 0,
              ),
              child: Text(
                category.displayName,
                style: AppTextStyles.headingSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            ...categoryItems.map((item) => _buildItemCard(item)),
          ],
        );
      },
    );
  }

  Widget _buildItemCard(ShoppingItemEntity item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.m),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.isPurchased
              ? null
              : () => _showMarkAsPurchasedDialog(item),
          borderRadius: BorderRadius.circular(AppRadius.m),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                // Checkbox
                Icon(
                  item.isPurchased
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: item.isPurchased
                      ? AppColors.success
                      : AppColors.textTertiary,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.m),
                // Conteúdo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          decoration: item.isPurchased
                              ? TextDecoration.lineThrough
                              : null,
                          color: item.isPurchased
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '${item.quantity} ${item.unit}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (item.store != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Row(
                          children: [
                            Icon(
                              Icons.store,
                              size: 12,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              item.store!,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Preço
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.isPurchased
                          ? CurrencyUtils.format(item.totalActual)
                          : CurrencyUtils.format(item.totalEstimated),
                      style: AppTextStyles.headingSmall.copyWith(
                        color: item.isPurchased
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                    ),
                    if (!item.isPurchased && item.estimatedPrice != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'un: ${CurrencyUtils.format(item.estimatedPrice!)}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
                // Menu de ações
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await context.push(
                        '${RouteNames.shoppingCreate}?projectId=${widget.projectId}',
                        extra: item,
                      );

                      if (mounted) {
                        context.read<ShoppingCubit>().loadShoppingItems(
                          widget.projectId,
                        );
                      }
                    } else if (value == 'return' && item.isPurchased) {
                      await _showReturnItemDialog(item);
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
                        await context.read<ShoppingCubit>().deleteShoppingItem(
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
                    if (!item.isPurchased)
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
                    if (item.isPurchased)
                      const PopupMenuItem(
                        value: 'return',
                        child: Row(
                          children: [
                            Icon(Icons.undo, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Devolver Item'),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filtrar Itens'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Por Fase:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(12, (index) {
                final phase = (index + 1).toString();
                return FilterChip(
                  label: Text('Fase $phase'),
                  selected: _selectedPhaseFilter == phase,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPhaseFilter = selected ? phase : null;
                    });
                    Navigator.pop(dialogContext);
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text(
              'Por Categoria:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ShoppingCategory.values.map((category) {
                return FilterChip(
                  label: Text(category.displayName),
                  selected: _selectedCategoryFilter == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategoryFilter = selected ? category : null;
                    });
                    Navigator.pop(dialogContext);
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedPhaseFilter = null;
                _selectedCategoryFilter = null;
              });
              Navigator.pop(dialogContext);
            },
            child: const Text('Limpar Filtros'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController();
    ShoppingCategory selectedCategory = ShoppingCategory.other;
    String selectedUnit = 'un';

    // Captura o cubit antes de abrir o dialog
    final cubit = context.read<ShoppingCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Adicionar Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do item *',
                    hintText: 'Ex: Piso porcelanato',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ShoppingCategory>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: ShoppingCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantidade *',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedUnit,
                        decoration: const InputDecoration(labelText: 'Unidade'),
                        items: const [
                          DropdownMenuItem(value: 'un', child: Text('un')),
                          DropdownMenuItem(value: 'm²', child: Text('m²')),
                          DropdownMenuItem(value: 'm', child: Text('m')),
                          DropdownMenuItem(value: 'L', child: Text('L')),
                          DropdownMenuItem(value: 'kg', child: Text('kg')),
                          DropdownMenuItem(value: 'sc', child: Text('sc')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => selectedUnit = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Preço estimado (opcional)',
                    prefixText: 'R\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    quantityController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preencha os campos obrigatórios'),
                    ),
                  );
                  return;
                }

                final item = ShoppingItemEntity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  projectId: widget.projectId,
                  name: nameController.text,
                  category: selectedCategory,
                  quantity: double.tryParse(quantityController.text) ?? 1,
                  unit: selectedUnit,
                  estimatedPrice: priceController.text.isEmpty
                      ? null
                      : double.tryParse(
                          priceController.text.replaceAll(',', '.'),
                        ),
                  isPurchased: false,
                  createdAt: DateTime.now(),
                );

                cubit.addShoppingItem(item);
                Navigator.pop(dialogContext);
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMarkAsPurchasedDialog(ShoppingItemEntity item) {
    final priceController = TextEditingController(
      text: item.estimatedPrice?.toStringAsFixed(2) ?? '',
    );
    final storeController = TextEditingController();

    // Captura o cubit antes de abrir o dialog
    final cubit = context.read<ShoppingCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Marcar como Comprado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Preço real pago *',
                prefixText: 'R\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: storeController,
              decoration: const InputDecoration(
                labelText: 'Loja/Fornecedor *',
                hintText: 'Ex: Leroy Merlin',
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (priceController.text.isEmpty ||
                  storeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preencha todos os campos')),
                );
                return;
              }

              final actualPrice = double.tryParse(
                priceController.text.replaceAll(',', '.'),
              );

              if (actualPrice == null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Preço inválido')));
                return;
              }

              context.read<ShoppingCubit>().markAsPurchased(
                projectId: widget.projectId,
                itemId: item.id,
                actualPrice: actualPrice,
                store: storeController.text,
                purchaseDate: DateTime.now(),
              );

              Navigator.pop(dialogContext);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showSuggestionsDialog() {
    // Captura o cubit antes de abrir o dialog
    final cubit = context.read<ShoppingCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Gerar Sugestões'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selecione a fase para gerar sugestões automáticas de itens:'),
            SizedBox(height: 16),
            Text('• Fase 9: Instalações (elétrica e hidráulica)'),
            Text('• Fase 10: Revestimentos e pisos'),
            Text('• Fase 11: Pintura e acabamentos'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              cubit.generateSuggestions(
                projectId: widget.projectId,
                phaseNumber: 9,
              );
            },
            child: const Text('Fase 9'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              cubit.generateSuggestions(
                projectId: widget.projectId,
                phaseNumber: 10,
              );
            },
            child: const Text('Fase 10'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              cubit.generateSuggestions(
                projectId: widget.projectId,
                phaseNumber: 11,
              );
            },
            child: const Text('Fase 11'),
          ),
        ],
      ),
    );
  }

  /// Diálogo para devolver um item (reversal)
  ///
  /// NOVA ARQUITETURA:
  /// - Usa ShoppingCubit.returnItem()
  /// - Cria TransactionEntity de reversal (signedAmount negativo)
  /// - Operação atômica (shopping + reversal)
  Future<void> _showReturnItemDialog(ShoppingItemEntity item) async {
    // Validar se o item tem expenseTransactionId
    if (item.expenseTransactionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não é possível devolver este item. '
            'Transação de despesa não encontrada.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Devolver Item',
      message:
          'Tem certeza que deseja devolver "${item.name}"?\n\n'
          'Quantidade: ${item.quantity} ${item.unit}\n'
          'Valor pago: ${CurrencyUtils.format(item.totalActual)}\n'
          'Loja: ${item.store ?? "N/A"}\n'
          'Comprado em: ${item.purchaseDate != null ? "${item.purchaseDate!.day}/${item.purchaseDate!.month}/${item.purchaseDate!.year}" : "N/A"}\n\n'
          'Esta ação criará um estorno no financeiro e desmarcará o item como comprado.',
      confirmLabel: 'Devolver Item',
      cancelLabel: 'Voltar',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      await context.read<ShoppingCubit>().returnItem(
        projectId: widget.projectId,
        itemId: item.id,
        expenseTransactionId: item.expenseTransactionId!,
      );
    }
  }
}

// Made with Bob
