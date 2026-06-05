import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/supplier_entity.dart';
import '../cubit/suppliers_cubit.dart';

class AddSupplierPage extends StatefulWidget {
  final String projectId;
  final SupplierEntity? supplier;

  const AddSupplierPage({super.key, required this.projectId, this.supplier});

  @override
  State<AddSupplierPage> createState() => _AddSupplierPageState();
}

class _AddSupplierPageState extends State<AddSupplierPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _notesController = TextEditingController();

  SupplierType _selectedType = SupplierType.other;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      _loadSupplierData();
    }
  }

  void _loadSupplierData() {
    final supplier = widget.supplier!;
    _nameController.text = supplier.name;
    _phoneController.text = supplier.phone;
    _emailController.text = supplier.email ?? '';
    _cpfController.text = supplier.cpf ?? '';
    _cnpjController.text = supplier.cnpj ?? '';
    _notesController.text = supplier.notes ?? '';
    _selectedType = supplier.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _cnpjController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final supplier = SupplierEntity(
      id: widget.supplier?.id ?? const Uuid().v4(),
      projectId: widget.projectId,
      name: _nameController.text.trim(),
      type: _selectedType,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      cpf: _cpfController.text.trim().isEmpty
          ? null
          : _cpfController.text.trim(),
      cnpj: _cnpjController.text.trim().isEmpty
          ? null
          : _cnpjController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      status: widget.supplier?.status ?? SupplierStatus.active,
      rating: widget.supplier?.rating,
      createdAt: widget.supplier?.createdAt ?? DateTime.now(),
    );

    if (widget.supplier == null) {
      await context.read<SuppliersCubit>().addSupplier(supplier);
    } else {
      await context.read<SuppliersCubit>().updateSupplier(supplier);
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.supplier != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Fornecedor' : 'Novo Fornecedor'),
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
                labelText: 'Nome *',
                hintText: 'Ex: João Silva',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o nome';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.m),

            // Tipo
            DropdownButtonFormField<SupplierType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo *',
                border: OutlineInputBorder(),
              ),
              items: SupplierType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(type.icon, size: 20),
                      const SizedBox(width: 8),
                      Text(type.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),

            const SizedBox(height: AppSpacing.m),

            // Telefone
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefone *',
                hintText: '(11) 99999-9999',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o telefone';
                }
                if (value.length < 10) {
                  return 'Telefone inválido';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.m),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email (opcional)',
                hintText: 'email@exemplo.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  if (!Validators.isValidEmail(value)) {
                    return 'Email inválido';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.m),

            // CPF
            TextFormField(
              controller: _cpfController,
              decoration: const InputDecoration(
                labelText: 'CPF (opcional)',
                hintText: '000.000.000-00',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
            ),

            const SizedBox(height: AppSpacing.m),

            // CNPJ
            TextFormField(
              controller: _cnpjController,
              decoration: const InputDecoration(
                labelText: 'CNPJ (opcional)',
                hintText: '00.000.000/0000-00',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(14),
                LengthLimitingTextInputFormatter(14),
              ],
            ),

            const SizedBox(height: AppSpacing.m),

            // Observações
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Observações (opcional)',
                hintText: 'Adicione informações sobre o fornecedor',
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
                    'Mantenha os dados dos fornecedores atualizados. '
                    'Você poderá avaliar o trabalho deles após a conclusão do serviço.',
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
