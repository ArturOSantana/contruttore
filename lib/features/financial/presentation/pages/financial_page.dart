import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../domain/entities/financial_summary_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../cubit/financial_cubit.dart';
import '../cubit/financial_state.dart';

class FinancialPage extends StatelessWidget {
  final String projectId;

  const FinancialPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financeiro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await context.pushNamed(
                'expense-create',
                queryParameters: {'projectId': projectId},
              );
              if (result == true && context.mounted) {
                context.read<FinancialCubit>().loadFinancialData(projectId);
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<FinancialCubit, FinancialState>(
        builder: (context, state) {
          if (state is FinancialLoading) {
            return const LoadingWidget(type: LoadingType.list);
          }

          if (state is FinancialError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FinancialCubit>().loadFinancialData(
                            projectId,
                          );
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (state is FinancialLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<FinancialCubit>().loadFinancialData(projectId);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(context, state.summary),
                    const SizedBox(height: 24),
                    _buildCategoriesList(context, state.summary),
                    const SizedBox(height: 24),
                    _buildExpensesList(context, state),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('Carregue os dados financeiros'));
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    FinancialSummaryEntity summary,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo Financeiro',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              'Orçamento Total',
              CurrencyUtils.format(summary.totalBudget),
              theme.colorScheme.primary,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Gasto Total',
              CurrencyUtils.format(summary.totalSpent),
              summary.percentageUsed > 100 ? Colors.red : Colors.orange,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: summary.percentageUsed / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                summary.percentageUsed > 100
                    ? Colors.red
                    : summary.percentageUsed > 80
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${summary.percentageUsed.toStringAsFixed(1)}% utilizado',
              style: theme.textTheme.bodySmall,
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatusChip(
                    'Confirmado',
                    CurrencyUtils.format(summary.totalConfirmed),
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusChip(
                    'Comprometido',
                    CurrencyUtils.format(summary.totalCommitted),
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildStatusChip(
              'Estimado',
              CurrencyUtils.format(summary.totalEstimated),
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(
    BuildContext context,
    FinancialSummaryEntity summary,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Por Categoria',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...summary.categorySummaries.values.map((category) {
          Color statusColor;
          switch (category.status) {
            case CategoryStatus.ok:
              statusColor = Colors.green;
              break;
            case CategoryStatus.warning:
              statusColor = Colors.orange;
              break;
            case CategoryStatus.exceeded:
              statusColor = Colors.red;
              break;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(category.categoryName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: category.percentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${CurrencyUtils.format(category.spent)} de ${CurrencyUtils.format(category.budget)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${category.percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildExpensesList(BuildContext context, FinancialLoaded state) {
    final theme = Theme.of(context);

    if (state.transactions.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Nenhuma transação registrada',
        message:
            'Comece registrando suas primeiras despesas para acompanhar o orçamento da obra',
        actionLabel: 'Adicionar Despesa',
        onAction: () async {
          final result = await context.pushNamed(
            'expense-create',
            queryParameters: {'projectId': projectId},
          );
          if (result == true && context.mounted) {
            context.read<FinancialCubit>().loadFinancialData(projectId);
          }
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transações Recentes',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...state.transactions.take(10).map((transaction) {
          // Ícone e cor baseado na origem
          IconData sourceIcon;
          Color sourceColor;
          String sourceLabel;

          switch (transaction.source) {
            case TransactionSource.shopping:
              sourceIcon = Icons.shopping_cart;
              sourceColor = Colors.blue;
              sourceLabel = 'Compra';
              break;
            case TransactionSource.installment:
              sourceIcon = Icons.payment;
              sourceColor = Colors.purple;
              sourceLabel = 'Parcela';
              break;
            case TransactionSource.manual:
              sourceIcon = Icons.edit;
              sourceColor = Colors.green;
              sourceLabel = 'Manual';
              break;
            case TransactionSource.contract:
              sourceIcon = Icons.description;
              sourceColor = Colors.orange;
              sourceLabel = 'Contrato';
              break;
            default:
              sourceIcon = Icons.receipt;
              sourceColor = Colors.grey;
              sourceLabel = transaction.source.displayName;
          }

          // Status
          Color statusColor;
          String statusLabel;

          switch (transaction.type) {
            case TransactionType.expense:
              statusColor = Colors.green;
              statusLabel = 'Gasto';
              break;
            case TransactionType.commitment:
              statusColor = Colors.orange;
              statusLabel = 'Compromisso';
              break;
            case TransactionType.estimate:
              statusColor = Colors.blue;
              statusLabel = 'Estimativa';
              break;
            case TransactionType.reversal:
              statusColor = Colors.red;
              statusLabel = 'Estorno';
              break;
          }

          // Apenas transações manuais podem ser editadas/deletadas
          final canEdit = transaction.source == TransactionSource.manual;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: sourceColor.withValues(alpha: 0.1),
                child: Icon(sourceIcon, color: sourceColor),
              ),
              title: Row(
                children: [
                  Expanded(child: Text(transaction.description)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: sourceColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      sourceLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: sourceColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyUtils.format(transaction.amount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (canEdit)
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await context.push(
                            '${RouteNames.expenseCreate}?projectId=$projectId',
                            extra: transaction,
                          );

                          if (context.mounted) {
                            context.read<FinancialCubit>().loadFinancialData(
                                  projectId,
                                );
                          }
                        } else if (value == 'delete') {
                          final confirmed = await ConfirmationDialog.show(
                            context,
                            title: 'Excluir Transação',
                            message:
                                'Tem certeza que deseja excluir esta transação?',
                            confirmLabel: 'Excluir',
                            cancelLabel: 'Cancelar',
                            isDestructive: true,
                          );

                          if (confirmed && context.mounted) {
                            await context
                                .read<FinancialCubit>()
                                .deleteTransaction(
                                  projectId,
                                  transaction.id,
                                  phaseId: transaction.phaseId,
                                  description: transaction.description,
                                );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Transação excluída com sucesso'),
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
              ),
            ),
          );
        }),
      ],
    );
  }
}

// Made with Bob
