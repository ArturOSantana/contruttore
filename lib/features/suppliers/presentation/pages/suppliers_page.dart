import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../domain/entities/supplier_entity.dart';
import '../cubit/suppliers_cubit.dart';
import '../cubit/suppliers_state.dart';

/// Página de Fornecedores
///
/// Exibe todos os fornecedores do projeto com:
/// - Lista de fornecedores com status e avaliação
/// - Filtro por tipo e status
/// - Ações rápidas (ligar, avaliar)
/// - Adicionar fornecedor
/// - Ver orçamentos
class SuppliersPage extends StatefulWidget {
  final String projectId;

  const SuppliersPage({super.key, required this.projectId});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  SupplierType? _selectedTypeFilter;
  SupplierStatus? _selectedStatusFilter;
  bool _isComparisonMode = false;
  final Set<String> _selectedSupplierIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isComparisonMode ? 'Selecionar Fornecedores' : 'Fornecedores',
        ),
        actions: [
          if (!_isComparisonMode) ...[
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
              tooltip: 'Filtrar',
            ),
            IconButton(
              icon: const Icon(Icons.compare_arrows),
              onPressed: _enableComparisonMode,
              tooltip: 'Comparar Fornecedores',
            ),
          ] else ...[
            TextButton(
              onPressed: _cancelComparisonMode,
              child: const Text('Cancelar'),
            ),
          ],
        ],
      ),
      body: BlocConsumer<SuppliersCubit, SuppliersState>(
        listener: (context, state) {
          if (state is SuppliersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is SupplierOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SuppliersLoading) {
            return const LoadingWidget();
          }

          if (state is SuppliersError) {
            return ErrorWidgetCustom(
              message: state.message,
              onRetry: () => context.read<SuppliersCubit>().loadSuppliers(
                widget.projectId,
              ),
            );
          }

          if (state is SuppliersLoaded) {
            final filteredSuppliers = _filterSuppliers(state.suppliers);

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<SuppliersCubit>().loadSuppliers(
                  widget.projectId,
                );
              },
              child: filteredSuppliers.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        if (_selectedTypeFilter != null ||
                            _selectedStatusFilter != null)
                          _buildActiveFilters(),
                        if (_isComparisonMode &&
                            _selectedSupplierIds.length >= 2)
                          _buildCompareButton(),
                        Expanded(child: _buildSuppliersList(filteredSuppliers)),
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
            '${RouteNames.supplierCreate}?projectId=${widget.projectId}',
          );
          if (result == true && mounted) {
            context.read<SuppliersCubit>().loadSuppliers(widget.projectId);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Fornecedor'),
      ),
    );
  }

  List<SupplierEntity> _filterSuppliers(List<SupplierEntity> suppliers) {
    var filtered = suppliers;

    if (_selectedTypeFilter != null) {
      filtered = context.read<SuppliersCubit>().filterSuppliersByType(
        filtered,
        _selectedTypeFilter,
      );
    }

    if (_selectedStatusFilter != null) {
      filtered = context.read<SuppliersCubit>().filterSuppliersByStatus(
        filtered,
        _selectedStatusFilter,
      );
    }

    return filtered;
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
                if (_selectedTypeFilter != null)
                  Chip(
                    label: Text(_selectedTypeFilter!.displayName),
                    onDeleted: () => setState(() => _selectedTypeFilter = null),
                    deleteIcon: const Icon(Icons.close, size: 16),
                  ),
                if (_selectedStatusFilter != null)
                  Chip(
                    label: Text(_selectedStatusFilter!.displayName),
                    onDeleted: () =>
                        setState(() => _selectedStatusFilter = null),
                    deleteIcon: const Icon(Icons.close, size: 16),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedTypeFilter = null;
                _selectedStatusFilter = null;
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
      icon: Icons.people_outline,
      title: 'Nenhum fornecedor cadastrado',
      message: _selectedTypeFilter != null || _selectedStatusFilter != null
          ? 'Nenhum fornecedor encontrado com os filtros aplicados'
          : 'Adicione fornecedores para gerenciar seus contatos e orçamentos',
      actionLabel: 'Adicionar Fornecedor',
      onAction: () async {
        final result = await context.push(
          '${RouteNames.supplierCreate}?projectId=${widget.projectId}',
        );
        if (result == true && mounted) {
          context.read<SuppliersCubit>().loadSuppliers(widget.projectId);
        }
      },
    );
  }

  Widget _buildSuppliersList(List<SupplierEntity> suppliers) {
    // Agrupar por tipo
    final suppliersByType = <SupplierType, List<SupplierEntity>>{};
    for (final supplier in suppliers) {
      suppliersByType.putIfAbsent(supplier.type, () => []).add(supplier);
    }

    final types = suppliersByType.keys.toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final typeSuppliers = suppliersByType[type]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.s,
                bottom: AppSpacing.s,
                top: index > 0 ? AppSpacing.m : 0,
              ),
              child: Row(
                children: [
                  Text(type.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    type.displayName,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.s),
                    ),
                    child: Text(
                      '${typeSuppliers.length}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...typeSuppliers.map((supplier) => _buildSupplierCard(supplier)),
          ],
        );
      },
    );
  }

  Widget _buildSupplierCard(SupplierEntity supplier) {
    final isSelected = _selectedSupplierIds.contains(supplier.id);
    final canSelect =
        !_isComparisonMode ||
        _selectedTypeFilter == null ||
        supplier.type == _selectedTypeFilter;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: isSelected
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
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
          onTap: _isComparisonMode && canSelect
              ? () => _toggleSupplierSelection(supplier)
              : () => _showSupplierDetail(supplier),
          borderRadius: BorderRadius.circular(AppRadius.m),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (_isComparisonMode) ...[
                      Checkbox(
                        value: isSelected,
                        onChanged: canSelect
                            ? (value) => _toggleSupplierSelection(supplier)
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.s),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            supplier.name,
                            style: AppTextStyles.headingSmall,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          if (supplier.rating != null)
                            Row(
                              children: [
                                ...List.generate(5, (index) {
                                  return Icon(
                                    index < supplier.rating!.round()
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 16,
                                    color: AppColors.warning,
                                  );
                                }),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  supplier.rating!.toStringAsFixed(1),
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    if (!_isComparisonMode) ...[
                      StatusBadge.forSupplier(supplier.status.name),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await context.push(
                              '${RouteNames.supplierCreate}?projectId=${widget.projectId}',
                              extra: supplier,
                            );

                            if (mounted) {
                              context.read<SuppliersCubit>().loadSuppliers(
                                widget.projectId,
                              );
                            }
                          } else if (value == 'delete') {
                            final confirmed = await ConfirmationDialog.show(
                              context,
                              title: 'Excluir Fornecedor',
                              message:
                                  'Tem certeza que deseja excluir ${supplier.name}?',
                              confirmLabel: 'Excluir',
                              cancelLabel: 'Cancelar',
                              isDestructive: true,
                            );

                            if (confirmed && mounted) {
                              await context
                                  .read<SuppliersCubit>()
                                  .deleteSupplier(
                                    widget.projectId,
                                    supplier.id,
                                  );

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Fornecedor excluído com sucesso',
                                    ),
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
                      ),
                    ],
                  ],
                ),
                if (!_isComparisonMode) ...[
                  const SizedBox(height: AppSpacing.s),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 16,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        supplier.phone,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (supplier.email != null) ...[
                        const SizedBox(width: AppSpacing.m),
                        Icon(
                          Icons.email,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            supplier.email!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _makePhoneCall(supplier.phone),
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Ligar'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.s,
                            ),
                          ),
                        ),
                      ),
                      if (supplier.status == SupplierStatus.completed) ...[
                        const SizedBox(width: AppSpacing.s),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showRatingDialog(supplier),
                            icon: const Icon(Icons.star, size: 18),
                            label: const Text('Avaliar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.s,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
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
        title: const Text('Filtrar Fornecedores'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Por Tipo:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: SupplierType.values.map((type) {
                  return FilterChip(
                    label: Text('${type.icon} ${type.displayName}'),
                    selected: _selectedTypeFilter == type,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTypeFilter = selected ? type : null;
                      });
                      Navigator.pop(dialogContext);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Por Status:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: SupplierStatus.values.map((status) {
                  return FilterChip(
                    label: Text(status.displayName),
                    selected: _selectedStatusFilter == status,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatusFilter = selected ? status : null;
                      });
                      Navigator.pop(dialogContext);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedTypeFilter = null;
                _selectedStatusFilter = null;
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

  void _showAddSupplierDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final cnpjController = TextEditingController();
    SupplierType selectedType = SupplierType.other;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Adicionar Fornecedor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome *',
                    hintText: 'Ex: João Silva',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<SupplierType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Tipo *'),
                  items: SupplierType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text('${type.icon} ${type.displayName}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefone *',
                    hintText: '(11) 99999-9999',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail (opcional)',
                    hintText: 'email@exemplo.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cnpjController,
                  decoration: const InputDecoration(
                    labelText: 'CNPJ/CPF (opcional)',
                    hintText: '00.000.000/0000-00',
                  ),
                  keyboardType: TextInputType.number,
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
                    phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preencha os campos obrigatórios'),
                    ),
                  );
                  return;
                }

                final supplier = SupplierEntity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  projectId: widget.projectId,
                  name: nameController.text,
                  type: selectedType,
                  phone: phoneController.text,
                  email: emailController.text.isEmpty
                      ? null
                      : emailController.text,
                  cnpj: cnpjController.text.isEmpty
                      ? null
                      : cnpjController.text,
                  status: SupplierStatus.active,
                  createdAt: DateTime.now(),
                );

                context.read<SuppliersCubit>().addSupplier(supplier);
                Navigator.pop(dialogContext);
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupplierDetail(SupplierEntity supplier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    supplier.type.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(supplier.name, style: AppTextStyles.displayMedium),
                        Text(
                          supplier.type.displayName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge.forSupplier(supplier.status.name),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              _buildDetailRow(Icons.phone, 'Telefone', supplier.phone),
              if (supplier.email != null)
                _buildDetailRow(Icons.email, 'E-mail', supplier.email!),
              if (supplier.cnpj != null)
                _buildDetailRow(Icons.badge, 'CNPJ/CPF', supplier.cnpj!),
              if (supplier.rating != null) ...[
                const SizedBox(height: AppSpacing.m),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.s),
                    Text(
                      'Avaliação: ${supplier.rating!.toStringAsFixed(1)}',
                      style: AppTextStyles.bodyLarge,
                    ),
                  ],
                ),
              ],
              if (supplier.notes != null) ...[
                const SizedBox(height: AppSpacing.m),
                Text('Observações:', style: AppTextStyles.headingSmall),
                const SizedBox(height: AppSpacing.s),
                Text(
                  supplier.notes!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _makePhoneCall(supplier.phone);
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Ligar'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navegar para tela de orçamentos deste fornecedor
                        context.push(
                          '/suppliers/${supplier.id}/quotes?projectId=${widget.projectId}&supplierName=${Uri.encodeComponent(supplier.name)}',
                        );
                      },
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('Orçamentos'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.s),
          Text(
            '$label: ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  void _showRatingDialog(SupplierEntity supplier) {
    double rating = supplier.rating ?? 3.0;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Avaliar Fornecedor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                supplier.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating.round() ? Icons.star : Icons.star_border,
                      size: 40,
                      color: AppColors.warning,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        rating = (index + 1).toDouble();
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                rating.toStringAsFixed(1),
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.warning,
                ),
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
                context.read<SuppliersCubit>().updateSupplierRating(
                  supplier,
                  rating,
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível fazer a ligação')),
        );
      }
    }
  }

  void _enableComparisonMode() {
    if (_selectedTypeFilter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma categoria antes de comparar'),
          backgroundColor: AppColors.warning,
        ),
      );
      _showFilterDialog();
      return;
    }

    setState(() {
      _isComparisonMode = true;
      _selectedSupplierIds.clear();
    });
  }

  void _cancelComparisonMode() {
    setState(() {
      _isComparisonMode = false;
      _selectedSupplierIds.clear();
    });
  }

  void _toggleSupplierSelection(SupplierEntity supplier) {
    setState(() {
      if (_selectedSupplierIds.contains(supplier.id)) {
        _selectedSupplierIds.remove(supplier.id);
      } else {
        _selectedSupplierIds.add(supplier.id);
      }
    });
  }

  Widget _buildCompareButton() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      color: AppColors.primaryLight.withValues(alpha: 0.1),
      child: SafeArea(
        top: false,
        child: FilledButton.icon(
          onPressed: _navigateToComparison,
          icon: const Icon(Icons.compare_arrows),
          label: Text('Comparar ${_selectedSupplierIds.length} Fornecedores'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ),
    );
  }

  void _navigateToComparison() {
    context.push(
      '/suppliers/compare?projectId=${widget.projectId}&supplierIds=${_selectedSupplierIds.join(',')}',
    );
  }
}

// Made with Bob
