import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../injection_container.dart';
import '../../../suppliers/domain/entities/supplier_entity.dart';
import '../../../suppliers/domain/usecases/get_suppliers_usecase.dart';
import '../../../suppliers/domain/usecases/add_supplier_usecase.dart';
import '../../domain/entities/shopping_item_entity.dart';
import '../cubit/shopping_cubit.dart';

class AddShoppingItemPage extends StatefulWidget {
  final String projectId;
  final ShoppingItemEntity? item;

  const AddShoppingItemPage({super.key, required this.projectId, this.item});

  @override
  State<AddShoppingItemPage> createState() => _AddShoppingItemPageState();
}

class _AddShoppingItemPageState extends State<AddShoppingItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _estimatedPriceController = TextEditingController();
  final _notesController = TextEditingController();

  ShoppingCategory _selectedCategory = ShoppingCategory.other;
  String _selectedUnit = 'un';
  bool _isLoading = false;

  // Fornecedores
  List<SupplierEntity> _suppliers = [];
  SupplierEntity? _selectedSupplier;
  bool _loadingSuppliers = true;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
    if (widget.item != null) {
      _loadItemData();
    }
  }

  Future<void> _loadSuppliers() async {
    setState(() => _loadingSuppliers = true);

    final getSuppliersUseCase = getIt<GetSuppliersUseCase>();
    final result = await getSuppliersUseCase(widget.projectId);

    result.fold(
      (failure) {
        setState(() => _loadingSuppliers = false);
      },
      (suppliers) {
        // Filtrar apenas lojas (materialsStore e furnitureStore)
        final stores = suppliers
            .where((s) =>
                s.type == SupplierType.materialsStore ||
                s.type == SupplierType.furnitureStore)
            .toList();

        setState(() {
          _suppliers = stores;
          _loadingSuppliers = false;

          // Se está editando e tem supplierId, seleciona o fornecedor
          if (widget.item?.supplierId != null) {
            _selectedSupplier = stores.firstWhere(
              (s) => s.id == widget.item!.supplierId,
              orElse: () => stores.first,
            );
          }
        });
      },
    );
  }

  void _loadItemData() {
    final item = widget.item!;
    _nameController.text = item.name;
    _quantityController.text = item.quantity.toString();
    _estimatedPriceController.text =
        item.estimatedPrice?.toStringAsFixed(2) ?? '';
    _notesController.text = item.notes ?? '';
    _selectedCategory = item.category;
    _selectedUnit = item.unit;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _estimatedPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _showAddSupplierDialog() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    SupplierType selectedType = SupplierType.materialsStore;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Loja'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome da Loja *',
                hintText: 'Ex: Leroy Merlin',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefone *',
                hintText: '(11) 99999-9999',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.m),
            DropdownButtonFormField<SupplierType>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo',
              ),
              items: [
                SupplierType.materialsStore,
                SupplierType.furnitureStore,
              ].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) selectedType = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  phoneController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Preencha todos os campos obrigatórios'),
                  ),
                );
                return;
              }

              final supplier = SupplierEntity(
                id: const Uuid().v4(),
                projectId: widget.projectId,
                name: nameController.text.trim(),
                type: selectedType,
                phone: phoneController.text.trim(),
                status: SupplierStatus.active,
                createdAt: DateTime.now(),
              );

              final addSupplierUseCase = getIt<AddSupplierUseCase>();
              final result = await addSupplierUseCase(supplier);

              result.fold(
                (failure) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro: ${failure.message}')),
                    );
                  }
                },
                (_) {
                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
              );
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _loadSuppliers();
      if (_suppliers.isNotEmpty) {
        setState(() {
          _selectedSupplier = _suppliers.last;
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final item = ShoppingItemEntity(
      id: widget.item?.id ?? const Uuid().v4(),
      projectId: widget.projectId,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      quantity: double.parse(_quantityController.text.replaceAll(',', '.')),
      unit: _selectedUnit,
      estimatedPrice: _estimatedPriceController.text.trim().isEmpty
          ? null
          : double.parse(_estimatedPriceController.text.replaceAll(',', '.')),
      store: _selectedSupplier?.name,
      supplierId: _selectedSupplier?.id,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      isPurchased: widget.item?.isPurchased ?? false,
      actualPrice: widget.item?.actualPrice,
      purchaseDate: widget.item?.purchaseDate,
      createdAt: widget.item?.createdAt ?? DateTime.now(),
    );

    if (widget.item == null) {
      await context.read<ShoppingCubit>().addItem(item);
    } else {
      await context.read<ShoppingCubit>().updateItem(item);
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Item' : 'Novo Item'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.m),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: Text(
                'SALVAR',
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.m),
          children: [
            // Nome
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Item *',
                hintText: 'Ex: Piso porcelanato',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o nome do item';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.m),

            // Categoria
            DropdownButtonFormField<ShoppingCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoria *',
                border: OutlineInputBorder(),
              ),
              items: ShoppingCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),

            const SizedBox(height: AppSpacing.m),

            // Quantidade e Unidade
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe';
                      }
                      final qty = double.tryParse(value.replaceAll(',', '.'));
                      if (qty == null || qty <= 0) {
                        return 'Inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unidade',
                      border: OutlineInputBorder(),
                    ),
                    items: ['un', 'm²', 'm', 'L', 'kg', 'sc', 'cx']
                        .map(
                          (unit) =>
                              DropdownMenuItem(value: unit, child: Text(unit)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedUnit = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.m),

            // Preço Estimado
            TextFormField(
              controller: _estimatedPriceController,
              decoration: const InputDecoration(
                labelText: 'Preço Estimado (opcional)',
                hintText: '0,00',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
            ),

            const SizedBox(height: AppSpacing.m),

            // Fornecedor/Loja
            if (_loadingSuppliers)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.m),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<SupplierEntity>(
                          value: _selectedSupplier,
                          decoration: const InputDecoration(
                            labelText: 'Loja (opcional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.store),
                          ),
                          hint: const Text('Selecione uma loja'),
                          items: _suppliers.map((supplier) {
                            return DropdownMenuItem(
                              value: supplier,
                              child: Text(supplier.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSupplier = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      IconButton.filled(
                        onPressed: _showAddSupplierDialog,
                        icon: const Icon(Icons.add),
                        tooltip: 'Adicionar nova loja',
                      ),
                    ],
                  ),
                  if (_selectedSupplier != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.s),
                      child: Text(
                        '${_selectedSupplier!.type.displayName} • ${_selectedSupplier!.phone}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

            const SizedBox(height: AppSpacing.m),

            // Observações
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Observações (opcional)',
                hintText: 'Detalhes sobre o item',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
    );
  }
}

// Made with Bob
