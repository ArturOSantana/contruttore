import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../cubit/wishlist_cubit.dart';

class AddWishlistItemPage extends StatefulWidget {
  final String projectId;
  final WishlistItemEntity? item;

  const AddWishlistItemPage({super.key, required this.projectId, this.item});

  @override
  State<AddWishlistItemPage> createState() => _AddWishlistItemPageState();
}

class _AddWishlistItemPageState extends State<AddWishlistItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _storeController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  WishlistCategory _selectedCategory = WishlistCategory.other;
  bool _isLoading = false;
  bool _isLoadingImage = false;
  String? _extractedImageUrl;

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
    _urlController.text = item.url;
    _storeController.text = item.storeName ?? '';
    _priceController.text = item.price?.toStringAsFixed(2) ?? '';
    _notesController.text = item.notes ?? '';
    _selectedCategory = item.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _storeController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Extrair imagem do link
  Future<String?> _extractImageFromUrl(String url) async {
    try {
      setState(() => _isLoadingImage = true);

      final response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);

        // Tentar Open Graph image
        final ogImage = document.querySelector('meta[property="og:image"]');
        if (ogImage != null && ogImage.attributes['content'] != null) {
          return ogImage.attributes['content'];
        }

        // Tentar Twitter image
        final twitterImage =
            document.querySelector('meta[name="twitter:image"]');
        if (twitterImage != null &&
            twitterImage.attributes['content'] != null) {
          return twitterImage.attributes['content'];
        }

        // Tentar meta image
        final metaImage = document.querySelector('meta[name="image"]');
        if (metaImage != null && metaImage.attributes['content'] != null) {
          return metaImage.attributes['content'];
        }
      }
    } catch (e) {
      print('Erro ao extrair imagem: $e');
    } finally {
      if (mounted) setState(() => _isLoadingImage = false);
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Extrair imagem do URL se não tiver
    String? imageUrl = widget.item?.imageUrl ?? _extractedImageUrl;
    if (imageUrl == null && _urlController.text.trim().isNotEmpty) {
      imageUrl = await _extractImageFromUrl(_urlController.text.trim());
    }

    final item = WishlistItemEntity(
      id: widget.item?.id ?? const Uuid().v4(),
      projectId: widget.projectId,
      name: _nameController.text.trim(),
      url: _urlController.text.trim(),
      storeName: _storeController.text.trim().isEmpty
          ? null
          : _storeController.text.trim(),
      price: _priceController.text.trim().isEmpty
          ? null
          : double.parse(_priceController.text.replaceAll(',', '.')),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      category: _selectedCategory,
      isSelected: widget.item?.isSelected ?? false,
      imageUrl: imageUrl,
      createdAt: widget.item?.createdAt ?? DateTime.now(),
    );

    if (widget.item == null) {
      await context.read<WishlistCubit>().addItem(item);
    } else {
      await context.read<WishlistCubit>().updateItem(item);
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
                hintText: 'Ex: Sofá retrátil 3 lugares',
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

            // URL
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Link *',
                hintText: 'https://...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o link';
                }
                if (!Validators.isValidUrl(value)) {
                  return 'Link inválido';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.m),

            // Categoria
            DropdownButtonFormField<WishlistCategory>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoria *',
                border: OutlineInputBorder(),
              ),
              items: WishlistCategory.values.map((category) {
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

            // Loja
            TextFormField(
              controller: _storeController,
              decoration: const InputDecoration(
                labelText: 'Loja (opcional)',
                hintText: 'Nome da loja',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: AppSpacing.m),

            // Preço
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Preço (opcional)',
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

            // Observações
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Observações (opcional)',
                hintText: 'Detalhes, medidas, cores, etc',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: AppSpacing.l),

            // Dica
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Text(
                        'Dica',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Salve links de produtos que você gostou. '
                    'Quando decidir comprar, marque como "Selecionado" '
                    'e o item aparecerá na sua lista de compras.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Made with Bob
