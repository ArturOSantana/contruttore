import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/payment_generator.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../suppliers/domain/entities/supplier_entity.dart';
import '../../../suppliers/presentation/cubit/suppliers_cubit.dart';
import '../../../suppliers/presentation/cubit/suppliers_state.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../cubit/payments_cubit.dart';
import '../cubit/payments_state.dart';
import '../../../../injection_container.dart';

/// Página de Parcelas (Payments)
///
/// Gerencia todas as parcelas do projeto:
/// - Parcelas de fornecedores
/// - Parcelas de compras
/// - Parcelas avulsas
class PaymentsPage extends StatefulWidget {
  final String projectId;

  const PaymentsPage({super.key, required this.projectId});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Parcelas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPaymentDialog(),
            tooltip: 'Adicionar Parcela',
          ),
        ],
      ),
      body: BlocConsumer<PaymentsCubit, PaymentsState>(
        listener: (context, state) {
          if (state is PaymentOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PaymentsLoading) {
            return const LoadingWidget();
          }

          if (state is PaymentsError) {
            return ErrorWidgetCustom(
              message: state.message,
              onRetry: () =>
                  context.read<PaymentsCubit>().loadPayments(widget.projectId),
            );
          }

          if (state is PaymentsLoaded) {
            if (state.payments.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.payment_outlined,
                title: 'Nenhuma parcela cadastrada',
                message:
                    'Adicione parcelas manualmente ou\ncadastre fornecedores com parcelamento',
                actionLabel: 'Adicionar Parcela',
                onAction: () => _showAddPaymentDialog(),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PaymentsCubit>().loadPayments(widget.projectId);
              },
              child: CustomScrollView(
                slivers: [
                  // Resumo
                  SliverToBoxAdapter(child: _buildSummaryCard(state)),

                  // Lista de parcelas
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final payment = state.payments[index];
                        return _buildPaymentCard(payment);
                      }, childCount: state.payments.length),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummaryCard(PaymentsLoaded state) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.m),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumo', style: AppTextStyles.headingMedium),
          const SizedBox(height: AppSpacing.m),
          _buildSummaryRow(
            'Total de parcelas',
            '${state.payments.length}',
            AppColors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.s),
          _buildSummaryRow(
            'Pendentes',
            '${state.pendingCount}',
            AppColors.warning,
          ),
          const SizedBox(height: AppSpacing.s),
          _buildSummaryRow(
            'Vencidas',
            '${state.overdueCount}',
            AppColors.error,
          ),
          const SizedBox(height: AppSpacing.s),
          _buildSummaryRow(
            'Total pendente',
            CurrencyUtils.format(state.totalPending),
            AppColors.info,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(PaymentEntity payment) {
    final isOverdue = payment.isOverdue;
    final isDueSoon = payment.isDueSoon;

    Color statusColor = AppColors.textSecondary;
    if (payment.paid) {
      statusColor = AppColors.success;
    } else if (isOverdue) {
      statusColor = AppColors.error;
    } else if (isDueSoon) {
      statusColor = AppColors.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.m),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPaymentDetail(payment),
          borderRadius: BorderRadius.circular(AppSpacing.m),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getPaymentTitle(payment),
                            style: AppTextStyles.headingSmall,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            _getPaymentSubtitle(payment),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(payment, statusColor),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),

                // Informações
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Valor',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          CurrencyUtils.format(payment.amount),
                          style: AppTextStyles.moneyMedium,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Vencimento',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          _dateFormat.format(payment.dueDate),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Botão de ação
                if (!payment.paid) ...[
                  const SizedBox(height: AppSpacing.m),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showMarkAsPaidDialog(payment),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Marcar como Pago'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.success,
                        side: BorderSide(color: AppColors.success),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PaymentEntity payment, Color color) {
    String label;
    IconData icon;

    if (payment.paid) {
      label = 'Pago';
      icon = Icons.check_circle;
    } else if (payment.isOverdue) {
      label = 'Vencido';
      icon = Icons.error;
    } else if (payment.isDueSoon) {
      label = 'Vence em breve';
      icon = Icons.warning;
    } else {
      label = 'Pendente';
      icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.s),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentTitle(PaymentEntity payment) {
    return payment.name;
  }

  String _getPaymentSubtitle(PaymentEntity payment) {
    return 'Parcela ${payment.installmentNumber}/${payment.totalInstallments}';
  }

  void _showAddPaymentDialog() {
    // Captura os cubits antes de abrir o dialog
    final paymentsCubit = context.read<PaymentsCubit>();
    final suppliersCubit = context.read<SuppliersCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => _AddPaymentDialog(
        projectId: widget.projectId,
        paymentsCubit: paymentsCubit,
        suppliersCubit: suppliersCubit,
      ),
    );
  }

  void _showMarkAsPaidDialog(PaymentEntity payment) {
    // Captura o cubit antes de abrir o dialog
    final cubit = context.read<PaymentsCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Marcar como Pago'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confirmar pagamento de:'),
            const SizedBox(height: AppSpacing.s),
            Text(
              CurrencyUtils.format(payment.amount),
              style: AppTextStyles.moneyLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Vencimento: ${_dateFormat.format(payment.dueDate)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
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
              cubit.markAsPaid(widget.projectId, payment.id);
              Navigator.pop(dialogContext);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDetail(PaymentEntity payment) {
    showDialog(
      context: context,
      builder: (dialogContext) => _PaymentDetailDialog(
        payment: payment,
        onMarkAsPaid: () {
          Navigator.pop(dialogContext);
          _showMarkAsPaidDialog(payment);
        },
      ),
    );
  }
}

/// Dialog de detalhes do pagamento
class _PaymentDetailDialog extends StatelessWidget {
  final PaymentEntity payment;
  final VoidCallback? onMarkAsPaid;

  const _PaymentDetailDialog({required this.payment, this.onMarkAsPaid});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final paidCount = payment.installmentNumber - 1;
    final remainingCount =
        payment.totalInstallments - payment.installmentNumber + 1;
    final remainingAmount = payment.amount * remainingCount;

    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(_getPaymentTitle(), style: AppTextStyles.headingMedium),
          ),
          _buildStatusIcon(),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Valor desta parcela
            _buildInfoSection(
              'Valor desta parcela',
              CurrencyUtils.format(payment.amount),
              AppColors.primary,
              isLarge: true,
            ),
            const Divider(height: AppSpacing.l),

            // Informações da parcela
            _buildInfoRow(
              'Parcela',
              '${payment.installmentNumber} de ${payment.totalInstallments}',
            ),
            const SizedBox(height: AppSpacing.s),
            _buildInfoRow('Vencimento', dateFormat.format(payment.dueDate)),
            const SizedBox(height: AppSpacing.s),
            _buildInfoRow('Status', _getStatusText()),

            if (payment.paidAt != null) ...[
              const SizedBox(height: AppSpacing.s),
              _buildInfoRow('Pago em', dateFormat.format(payment.paidAt!)),
            ],

            const Divider(height: AppSpacing.l),

            // Resumo do parcelamento
            Text('Resumo do Parcelamento', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.s),
            _buildInfoRow(
              'Parcelas pagas',
              '$paidCount de ${payment.totalInstallments}',
            ),
            const SizedBox(height: AppSpacing.s),
            _buildInfoRow('Parcelas restantes', '$remainingCount'),
            const SizedBox(height: AppSpacing.s),
            _buildInfoSection(
              'Valor restante',
              CurrencyUtils.format(remainingAmount),
              AppColors.warning,
            ),

            if (payment.sourceType == 'supplier' &&
                payment.sourceId.isNotEmpty) ...[
              const Divider(height: AppSpacing.l),
              Text('Vinculado a', style: AppTextStyles.headingSmall),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Fornecedor',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            if (payment.sourceType == 'purchase' &&
                payment.sourceId.isNotEmpty) ...[
              const Divider(height: AppSpacing.l),
              Text('Vinculado a', style: AppTextStyles.headingSmall),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Compra',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
        if (!payment.paid && onMarkAsPaid != null)
          FilledButton.icon(
            onPressed: onMarkAsPaid,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Marcar como Pago'),
          ),
      ],
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    if (payment.paid) {
      icon = Icons.check_circle;
      color = AppColors.success;
    } else if (payment.isOverdue) {
      icon = Icons.error;
      color = AppColors.error;
    } else if (payment.isDueSoon) {
      icon = Icons.warning;
      color = AppColors.warning;
    } else {
      icon = Icons.schedule;
      color = AppColors.info;
    }

    return Icon(icon, color: color, size: 28);
  }

  Widget _buildInfoSection(
    String label,
    String value,
    Color valueColor, {
    bool isLarge = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: isLarge ? AppTextStyles.moneyLarge : AppTextStyles.moneyMedium,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _getPaymentTitle() {
    if (payment.sourceType == 'supplier') {
      return 'Fornecedor';
    } else if (payment.sourceType == 'purchase') {
      return 'Compra';
    } else {
      return 'Parcela Avulsa';
    }
  }

  String _getStatusText() {
    if (payment.paid) {
      return 'Pago';
    } else if (payment.isOverdue) {
      return 'Vencido';
    } else if (payment.isDueSoon) {
      return 'Vence em breve';
    } else {
      return 'Pendente';
    }
  }
}

/// Dialog para adicionar nova parcela
class _AddPaymentDialog extends StatefulWidget {
  final String projectId;
  final PaymentsCubit paymentsCubit;
  final SuppliersCubit suppliersCubit;

  const _AddPaymentDialog({
    required this.projectId,
    required this.paymentsCubit,
    required this.suppliersCubit,
  });

  @override
  State<_AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<_AddPaymentDialog> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _installmentsController = TextEditingController(text: '1');
  DateTime _firstDueDate = DateTime.now().add(const Duration(days: 30));
  String? _selectedSupplierId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Parcela'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome da parcela (obrigatório)
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome da parcela *',
                hintText: 'Ex: Marcenaria da cozinha',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.m),

            // Seleção de fornecedor (opcional)
            Text(
              'Fornecedor (opcional)',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            BlocBuilder<SuppliersCubit, SuppliersState>(
              bloc: widget.suppliersCubit,
              builder: (context, state) {
                if (state is SuppliersLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.m),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state is SuppliersError) {
                  return Text(
                    'Erro ao carregar fornecedores',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                      fontStyle: FontStyle.italic,
                    ),
                  );
                }

                final suppliers = state is SuppliersLoaded
                    ? state.suppliers
                    : <SupplierEntity>[];

                if (suppliers.isEmpty) {
                  return Text(
                    'Nenhum fornecedor cadastrado',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  initialValue: _selectedSupplierId,
                  decoration: const InputDecoration(
                    hintText: 'Selecione um fornecedor',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Sem fornecedor'),
                    ),
                    for (final supplier in suppliers)
                      DropdownMenuItem<String>(
                        value: supplier.id,
                        child: Text(supplier.name),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSupplierId = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: AppSpacing.m),

            // Valor
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Valor total *',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: AppSpacing.m),

            // Número de parcelas
            TextField(
              controller: _installmentsController,
              decoration: const InputDecoration(
                labelText: 'Número de parcelas *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.m),

            // Data da primeira parcela
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Primeira parcela'),
              subtitle: Text(
                DateFormat('dd/MM/yyyy').format(_firstDueDate),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _firstDueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (date != null) {
                  setState(() {
                    _firstDueDate = date;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _handleSubmit, child: const Text('Adicionar')),
      ],
    );
  }

  void _handleSubmit() async {
    if (_nameController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _installmentsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    final installments = int.tryParse(_installmentsController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Valor inválido')));
      return;
    }

    if (installments == null || installments <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Número de parcelas inválido')),
      );
      return;
    }

    // Gera os payments usando PaymentGenerator
    final payments = PaymentGenerator.generatePayments(
      name: _nameController.text.trim(),
      projectId: widget.projectId,
      totalAmount: amount,
      installments: installments,
      firstPaymentDate: _firstDueDate,
      sourceType: 'manual',
      sourceId: _selectedSupplierId ?? '',
    );

    // Adiciona todos os payments via repository
    final repository = getIt<PaymentRepository>();
    await repository.createPayments(payments);

    // Recarrega a lista
    widget.paymentsCubit.loadPayments(widget.projectId);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          installments == 1
              ? 'Pagamento adicionado com sucesso!'
              : '$installments parcelas adicionadas com sucesso!',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _installmentsController.dispose();
    super.dispose();
  }
}

// Made with Bob
