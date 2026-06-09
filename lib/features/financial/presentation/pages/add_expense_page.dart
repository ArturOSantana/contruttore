import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/transaction_entity.dart';
import '../cubit/financial_cubit.dart';

class AddExpensePage extends StatefulWidget {
  final String projectId;
  final TransactionEntity? transaction; // null = adicionar, não-null = editar

  const AddExpensePage({super.key, required this.projectId, this.transaction});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedPhaseId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _loadTransactionData();
    }
  }

  void _loadTransactionData() {
    final transaction = widget.transaction!;
    _descriptionController.text = transaction.description;
    _amountController.text = transaction.amount.toStringAsFixed(2);
    _selectedCategoryId = transaction.categoryId;
    _selectedPhaseId = transaction.phaseId;
    _selectedDate = transaction.date;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
        _selectedDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final amount = double.parse(_amountController.text.replaceAll(',', '.'));
    final description = _descriptionController.text.trim();

    if (widget.transaction == null) {
      // Adicionar nova transação
      await context.read<FinancialCubit>().addTransaction(
            projectId: widget.projectId,
            description: description,
            amount: amount,
            date: _selectedDate,
            phaseId: _selectedPhaseId,
            categoryId: _selectedCategoryId,
          );
    } else {
      // Atualizar transação existente
      await context.read<FinancialCubit>().updateTransaction(
            projectId: widget.projectId,
            transactionId: widget.transaction!.id,
            description: description,
            amount: amount,
            date: _selectedDate,
            phaseId: _selectedPhaseId,
            categoryId: _selectedCategoryId,
          );
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Transação' : 'Nova Despesa'),
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
            // Descrição
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Ex: Compra de cimento',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe a descrição';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.m),

            // Valor
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Valor',
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

            // Categoria (opcional)
            DropdownButtonFormField<String>(
              initialValue: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Categoria (opcional)',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Selecione uma categoria'),
              items: _buildCategoryItems(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),

            const SizedBox(height: AppSpacing.m),

            // Data
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  AppDateUtils.formatDate(_selectedDate),
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.l),

            // Informações sobre status
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
                      Icon(Icons.info_outline, size: 20, color: AppColors.info),
                      const SizedBox(width: AppSpacing.s),
                      Text(
                        'Sobre os status',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    '• Estimado: valor previsto no orçamento\n'
                    '• Comprometido: orçamento aceito, mas não pago\n'
                    '• Confirmado: valor já pago',
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

  List<DropdownMenuItem<String>> _buildCategoryItems() {
    // Categorias padrão do sistema
    final categories = [
      {'id': 'eletrica', 'name': 'Elétrica'},
      {'id': 'hidraulica', 'name': 'Hidráulica'},
      {'id': 'revestimentos', 'name': 'Revestimentos'},
      {'id': 'pisos', 'name': 'Pisos'},
      {'id': 'pintura', 'name': 'Pintura'},
      {'id': 'marcenaria', 'name': 'Marcenaria'},
      {'id': 'mobiliario', 'name': 'Mobiliário'},
      {'id': 'demolicao', 'name': 'Demolição'},
      {'id': 'gesso', 'name': 'Gesso e Forro'},
      {'id': 'loucas', 'name': 'Louças e Metais'},
      {'id': 'esquadrias', 'name': 'Esquadrias'},
      {'id': 'projeto', 'name': 'Projeto'},
      {'id': 'outros', 'name': 'Outros'},
    ];

    return categories.map((cat) {
      return DropdownMenuItem<String>(
        value: cat['id'],
        child: Text(cat['name']!),
      );
    }).toList();
  }
}

// Made with Bob
