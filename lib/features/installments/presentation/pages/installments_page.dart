import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../domain/entities/installment_entity.dart';
import '../cubit/installments_cubit.dart';
import '../cubit/installments_state.dart';

/// Página de Parcelas (Installments/Payments)
///
/// Gerencia contratos com fornecedores e suas parcelas de pagamento.
/// Permite visualizar, adicionar contratos e marcar parcelas como pagas.
class InstallmentsPage extends StatefulWidget {
  final String projectId;

  const InstallmentsPage({super.key, required this.projectId});

  @override
  State<InstallmentsPage> createState() => _InstallmentsPageState();
}

class _InstallmentsPageState extends State<InstallmentsPage> {
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Parcelas'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: BlocConsumer<InstallmentsCubit, InstallmentsState>(
        listener: (context, state) {
          if (state is InstallmentOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is InstallmentsLoading) {
            return const LoadingWidget();
          }

          if (state is InstallmentsError) {
            return ErrorWidgetCustom(
              message: state.message,
              onRetry: () => context.read<InstallmentsCubit>().loadInstallments(
                widget.projectId,
              ),
            );
          }

          if (state is InstallmentsLoaded) {
            if (state.installments.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.receipt_long_outlined,
                title: 'Nenhum contrato cadastrado',
                message:
                    'Adicione contratos com fornecedores\npara gerenciar parcelas de pagamento',
                actionLabel: 'Adicionar Contrato',
                onAction: () async {
                  final result = await context.push(
                    '${RouteNames.paymentCreate}?projectId=${widget.projectId}',
                  );
                  if (result == true && context.mounted) {
                    context.read<InstallmentsCubit>().loadInstallments(
                      widget.projectId,
                    );
                  }
                },
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<InstallmentsCubit>().loadInstallments(
                  widget.projectId,
                );
              },
              child: CustomScrollView(
                slivers: [
                  // Card de resumo
                  SliverToBoxAdapter(child: _buildSummaryCard(state)),

                  // Lista de contratos
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final installment = state.installments[index];
                        return _buildContractCard(context, installment);
                      }, childCount: state.installments.length),
                    ),
                  ),
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
            '${RouteNames.paymentCreate}?projectId=${widget.projectId}',
          );
          if (result == true && mounted) {
            context.read<InstallmentsCubit>().loadInstallments(
              widget.projectId,
            );
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Novo Contrato'),
      ),
    );
  }

  Widget _buildSummaryCard(InstallmentsLoaded state) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Próximos 30 dias',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _currencyFormat.format(state.totalPendingNext30Days),
            style: AppTextStyles.moneyLarge.copyWith(color: AppColors.primary),
          ),
          if (state.overdueCount > 0) ...[
            const SizedBox(height: AppSpacing.m),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(AppRadius.s),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${state.overdueCount} ${state.overdueCount == 1 ? 'parcela vencida' : 'parcelas vencidas'}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContractCard(
    BuildContext context,
    InstallmentEntity installment,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do contrato
          InkWell(
            onTap: () => _showContractDetails(context, installment),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.m),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              installment.supplierName,
                              style: AppTextStyles.headingMedium,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              installment.serviceDescription,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge.payment(installment.status.name),
                      const SizedBox(width: AppSpacing.xs),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await context.push(
                              '${RouteNames.paymentCreate}?projectId=${widget.projectId}',
                              extra: installment,
                            );

                            if (mounted) {
                              context
                                  .read<InstallmentsCubit>()
                                  .loadInstallments(widget.projectId);
                            }
                          } else if (value == 'delete') {
                            final confirmed = await ConfirmationDialog.show(
                              context,
                              title: 'Excluir Contrato',
                              message:
                                  'Tem certeza que deseja excluir o contrato com "${installment.supplierName}"? Todas as parcelas serão removidas.',
                              confirmLabel: 'Excluir',
                              cancelLabel: 'Cancelar',
                              isDestructive: true,
                            );

                            if (confirmed && mounted) {
                              await context
                                  .read<InstallmentsCubit>()
                                  .deleteInstallment(
                                    widget.projectId,
                                    installment.id,
                                  );
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
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'Valor Total',
                          _currencyFormat.format(installment.totalValue),
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'Parcelas',
                          '${installment.paidCount}/${installment.totalInstallments}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  // Barra de progresso
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.s),
                    child: LinearProgressIndicator(
                      value:
                          installment.paidCount / installment.totalInstallments,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        installment.isCompleted
                            ? AppColors.success
                            : installment.hasOverdue
                            ? AppColors.error
                            : AppColors.primary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Lista de parcelas (próximas 3)
          ...installment.payments
              .where((p) => !p.isPaid)
              .take(3)
              .map(
                (payment) => _buildPaymentItem(context, installment, payment),
              ),

          // Ver todas as parcelas
          if (installment.payments.length > 3)
            InkWell(
              onTap: () => _showContractDetails(context, installment),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ver todas as parcelas',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildPaymentItem(
    BuildContext context,
    InstallmentEntity installment,
    PaymentEntity payment,
  ) {
    final status = payment.status;
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case PaymentStatus.paid:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case PaymentStatus.overdue:
        statusColor = AppColors.error;
        statusIcon = Icons.error;
        break;
      case PaymentStatus.dueSoon:
        statusColor = AppColors.warning;
        statusIcon = Icons.warning_amber_rounded;
        break;
      case PaymentStatus.upcoming:
        statusColor = AppColors.info;
        statusIcon = Icons.schedule;
        break;
      case PaymentStatus.future:
        statusColor = AppColors.textTertiary;
        statusIcon = Icons.circle_outlined;
        break;
    }

    return InkWell(
      onTap: payment.isPaid
          ? null
          : () => _showMarkAsPaidDialog(context, installment, payment),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: Row(
          children: [
            Icon(statusIcon, size: 20, color: statusColor),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parcela ${payment.number}/${installment.totalInstallments}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Vencimento: ${_dateFormat.format(payment.dueDate)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (payment.isPaid && payment.paidAt != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Pago em: ${_dateFormat.format(payment.paidAt!)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              _currencyFormat.format(payment.paidAmount ?? payment.amount),
              style: AppTextStyles.moneyMedium.copyWith(
                color: payment.isPaid
                    ? AppColors.success
                    : AppColors.textPrimary,
              ),
            ),
            // Botão de cancelar pagamento (apenas para parcelas pagas)
            if (payment.isPaid)
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'cancel') {
                    await _showCancelPaymentDialog(
                      context,
                      installment,
                      payment,
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(Icons.undo, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Cancelar Pagamento'),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showContractDetails(
    BuildContext context,
    InstallmentEntity installment,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.l),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      installment.supplierName,
                      style: AppTextStyles.headingLarge,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      installment.serviceDescription,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            'Valor Total',
                            _currencyFormat.format(installment.totalValue),
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            'Data do Contrato',
                            _dateFormat.format(installment.contractDate),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Lista de todas as parcelas
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: installment.payments.length,
                  itemBuilder: (context, index) {
                    final payment = installment.payments[index];
                    return _buildPaymentItem(context, installment, payment);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMarkAsPaidDialog(
    BuildContext context,
    InstallmentEntity installment,
    PaymentEntity payment,
  ) {
    final amountController = TextEditingController(
      text: payment.amount.toStringAsFixed(2),
    );
    final dateController = TextEditingController(
      text: _dateFormat.format(DateTime.now()),
    );
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Marcar como Paga'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parcela ${payment.number}/${installment.totalInstallments}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Valor Pago',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'Data do Pagamento',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: dialogContext,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  selectedDate = date;
                  dateController.text = _dateFormat.format(date);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final paidAmount = double.tryParse(
                amountController.text.replaceAll(',', '.'),
              );

              if (paidAmount == null || paidAmount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Valor inválido'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              context.read<InstallmentsCubit>().markPaymentAsPaid(
                projectId: widget.projectId,
                installmentId: installment.id,
                paymentId: payment.id,
                paidAmount: paidAmount,
                paidAt: selectedDate,
                supplierName: installment.supplierName,
                serviceDescription: installment.serviceDescription,
                supplierId: installment.supplierId,
                phaseId: installment.phaseId,
              );

              Navigator.pop(dialogContext);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showAddContractDialog(BuildContext context) {
    // TODO: Implementar formulário completo de adicionar contrato
    // Por ora, apenas mostra um placeholder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Contrato'),
        content: const Text(
          'Formulário de adicionar contrato será implementado em breve.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  /// Diálogo para cancelar um pagamento (reversal)
  ///
  /// NOVA ARQUITETURA:
  /// - Usa InstallmentsCubit.cancelPayment()
  /// - Cria TransactionEntity de reversal (signedAmount negativo)
  /// - Operação atômica (installment + reversal)
  Future<void> _showCancelPaymentDialog(
    BuildContext context,
    InstallmentEntity installment,
    PaymentEntity payment,
  ) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Cancelar Pagamento',
      message:
          'Tem certeza que deseja cancelar o pagamento da parcela ${payment.number}?\n\n'
          'Valor: ${_currencyFormat.format(payment.paidAmount ?? payment.amount)}\n'
          'Pago em: ${payment.paidAt != null ? _dateFormat.format(payment.paidAt!) : "N/A"}\n\n'
          'Esta ação criará um estorno no financeiro e desmarcará a parcela como paga.',
      confirmLabel: 'Cancelar Pagamento',
      cancelLabel: 'Voltar',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      // Buscar o expenseTransactionId
      // TODO: Precisamos armazenar o transactionId no PaymentEntity
      // Por ora, vamos usar o paymentId como referência
      final expenseTransactionId = payment.id; // Temporário

      await context.read<InstallmentsCubit>().cancelPayment(
        projectId: widget.projectId,
        installmentId: installment.id,
        paymentId: payment.id,
        supplierId: installment.supplierId,
        supplierName: installment.supplierName,
        serviceDescription: installment.serviceDescription,
        paidAmount: payment.paidAmount ?? payment.amount,
        phaseId: installment.phaseId,
        categoryId: null,
        originalTransactionId: expenseTransactionId,
      );
    }
  }
}

// Made with Bob
