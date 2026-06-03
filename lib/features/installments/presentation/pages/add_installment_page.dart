import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/installment_entity.dart';
import '../cubit/installments_cubit.dart';

class AddInstallmentPage extends StatefulWidget {
  final String projectId;
  final InstallmentEntity? installment;

  const AddInstallmentPage({
    super.key,
    required this.projectId,
    this.installment,
  });

  @override
  State<AddInstallmentPage> createState() => _AddInstallmentPageState();
}

class _AddInstallmentPageState extends State<AddInstallmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _supplierNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalValueController = TextEditingController();
  final _installmentsController = TextEditingController();

  DateTime _contractDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.installment != null) {
      _loadInstallmentData();
    }
  }

  void _loadInstallmentData() {
    final inst = widget.installment!;
    _supplierNameController.text = inst.supplierName;
    _descriptionController.text = inst.serviceDescription;
    _totalValueController.text = inst.totalValue.toStringAsFixed(2);
    _installmentsController.text = inst.totalInstallments.toString();
    _contractDate = inst.contractDate;
  }

  @override
  void dispose() {
    _supplierNameController.dispose();
    _descriptionController.dispose();
    _totalValueController.dispose();
    _installmentsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _contractDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _contractDate = picked;
      });
    }
  }

  List<PaymentEntity> _generatePayments() {
    final totalValue = double.parse(
      _totalValueController.text.replaceAll(',', '.'),
    );
    final totalInstallments = int.parse(_installmentsController.text);
    final valuePerInstallment = totalValue / totalInstallments;

    final payments = <PaymentEntity>[];
    for (int i = 0; i < totalInstallments; i++) {
      final dueDate = DateTime(
        _contractDate.year,
        _contractDate.month + i + 1,
        _contractDate.day,
      );

      payments.add(
        PaymentEntity(
          id: const Uuid().v4(),
          number: i + 1,
          amount: valuePerInstallment,
          dueDate: dueDate,
          isPaid: false,
        ),
      );
    }

    return payments;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final installment = InstallmentEntity(
      id: widget.installment?.id ?? const Uuid().v4(),
      projectId: widget.projectId,
      supplierId: widget.installment?.supplierId ?? '',
      supplierName: _supplierNameController.text.trim(),
      serviceDescription: _descriptionController.text.trim(),
      totalValue: double.parse(_totalValueController.text.replaceAll(',', '.')),
      totalInstallments: int.parse(_installmentsController.text),
      contractDate: _contractDate,
      status: widget.installment?.status ?? InstallmentStatus.active,
      payments: widget.installment?.payments ?? _generatePayments(),
      createdAt: widget.installment?.createdAt ?? DateTime.now(),
    );

    if (widget.installment == null) {
      await context.read<InstallmentsCubit>().createInstallment(installment);
    } else {
      await context.read<InstallmentsCubit>().updateInstallment(installment);
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.installment != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Contrato' : 'Novo Contrato'),
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
            // Nome do Fornecedor
            TextFormField(
              controller: _supplierNameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Fornecedor *',
                hintText: 'Ex: João Marceneiro',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o nome do fornecedor';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.m),

            // Descrição do Serviço
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição do Serviço *',
                hintText: 'Ex: Marcenaria completa da cozinha',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe a descrição';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.m),

            // Valor Total
            TextFormField(
              controller: _totalValueController,
              decoration: const InputDecoration(
                labelText: 'Valor Total *',
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
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o valor';
                }
                final amount = double.tryParse(value.replaceAll(',', '.'));
                if (amount == null || amount <= 0) {
                  return 'Valor inválido';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.m),

            // Número de Parcelas
            TextFormField(
              controller: _installmentsController,
              decoration: const InputDecoration(
                labelText: 'Número de Parcelas *',
                hintText: 'Ex: 6',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o número de parcelas';
                }
                final num = int.tryParse(value);
                if (num == null || num <= 0 || num > 60) {
                  return 'Número inválido (1-60)';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.m),

            // Data do Contrato
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data do Contrato',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  '${_contractDate.day.toString().padLeft(2, '0')}/${_contractDate.month.toString().padLeft(2, '0')}/${_contractDate.year}',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.l),

            // Preview do Valor por Parcela
            if (_totalValueController.text.isNotEmpty &&
                _installmentsController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calculate,
                          size: 20,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Text(
                          'Valor por Parcela',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      _calculateInstallmentValue(),
                      style: AppTextStyles.moneyMedium.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppSpacing.m),

            // Informação
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: AppColors.info),
                      const SizedBox(width: AppSpacing.s),
                      Text(
                        'Como funciona',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'As parcelas serão geradas automaticamente com vencimento mensal. '
                    'Você receberá alertas 7 e 3 dias antes de cada vencimento.',
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

  String _calculateInstallmentValue() {
    try {
      final total = double.parse(
        _totalValueController.text.replaceAll(',', '.'),
      );
      final installments = int.parse(_installmentsController.text);
      final value = total / installments;
      return 'R\$ ${value.toStringAsFixed(2)}';
    } catch (e) {
      return 'R\$ 0,00';
    }
  }
}

// Made with Bob
