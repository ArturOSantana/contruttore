import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
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
  final _storeController = TextEditingController();
  final _notesController = TextEditingController();

  ShoppingCategory _selectedCategory = ShoppingCategory.other;
  String _selectedUnit = 'un';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _loadItemData();
    }
  }

  void _loadItemData() {
    final item = widget.item!;
    _nameController.text = item.name;
    _quantityController.text = item.quantity.toString();
    _estimatedPriceController.text =
        item.estimatedPrice?.toStringAsFixed(2) ?? '';
    _storeController.text = item.store ?? '';
    _notesController.text = item.notes ?? '';
    _selectedCategory = item.category;
    _selectedUnit = item.unit;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _estimatedPriceController.dispose();
    _storeController.dispose();
    _notesController.dispose();
    super.dispose();
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
      store: _storeController.text.trim().isEmpty
          ? null
          : _storeController.text.trim(),
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
              initialValue: _selectedCategory,
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
                    initialValue: _selectedUnit,
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

            // Loja
            TextFormField(
              controller: _storeController,
              decoration: const InputDecoration(
                labelText: 'Loja (opcional)',
                hintText: 'Onde pretende comprar',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
              textCapitalization: TextCapitalization.words,
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
