import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom;
import '../../domain/entities/quote_entity.dart';
import '../../domain/entities/supplier_entity.dart';
import '../cubit/suppliers_cubit.dart';
import '../cubit/suppliers_state.dart';

/// Página de Orçamentos de um Fornecedor
///
/// Exibe todos os orçamentos de um fornecedor específico
class SupplierQuotesPage extends StatefulWidget {
  final String projectId;
  final String supplierId;
  final String supplierName;

  const SupplierQuotesPage({
    super.key,
    required this.projectId,
    required this.supplierId,
    required this.supplierName,
  });

  @override
  State<SupplierQuotesPage> createState() => _SupplierQuotesPageState();
}

class _SupplierQuotesPageState extends State<SupplierQuotesPage> {
  @override
  void initState() {
    super.initState();
    // Carregar orçamentos do fornecedor
    context.read<SuppliersCubit>().loadQuotes(
      widget.projectId,
      widget.supplierId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SuppliersCubit, SuppliersState>(
      listener: (context, state) {
        if (state is SupplierOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is SuppliersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: BlocBuilder<SuppliersCubit, SuppliersState>(
        builder: (context, state) {
          // Conta quantos orçamentos pendentes existem
          final canCompare =
              state is QuotesLoaded &&
              state.quotes
                      .where((q) => q.status == QuoteStatus.pending)
                      .length >=
                  2;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text('Orçamentos - ${widget.supplierName}'),
              backgroundColor: AppColors.surface,
              actions: [
                if (canCompare)
                  IconButton(
                    icon: const Icon(Icons.compare_arrows),
                    tooltip: 'Comparar Orçamentos',
                    onPressed: () => _compareQuotes(state.quotes),
                  ),
              ],
            ),
            body: Builder(
              builder: (innerContext) {
                print(
                  '🎨 UI: BlocBuilder recebeu estado: ${state.runtimeType}',
                );

                if (state is SuppliersLoading) {
                  print('🎨 UI: Mostrando loading...');
                  return const LoadingWidget();
                }

                if (state is SuppliersError) {
                  print('🎨 UI: Mostrando erro: ${state.message}');
                  return custom.ErrorWidgetCustom(
                    message: state.message,
                    onRetry: () => context.read<SuppliersCubit>().loadQuotes(
                      widget.projectId,
                      widget.supplierId,
                    ),
                  );
                }

                // Aceita tanto QuotesLoaded quanto SupplierDetailLoaded
                if (state is QuotesLoaded || state is SupplierDetailLoaded) {
                  final quotes = state is QuotesLoaded
                      ? state.quotes
                      : (state as SupplierDetailLoaded).quotes;

                  print(
                    '🎨 UI: ${state.runtimeType} com ${quotes.length} orçamentos',
                  );

                  if (quotes.isEmpty) {
                    print('🎨 UI: Lista vazia, mostrando empty state');
                    return EmptyStateWidget(
                      icon: Icons.receipt_long,
                      title: 'Nenhum orçamento',
                      message:
                          'Este fornecedor ainda não tem orçamentos cadastrados',
                      actionLabel: 'Adicionar Orçamento',
                      onAction: () => _showAddQuoteDialog(),
                    );
                  }

                  print(
                    '🎨 UI: Renderizando ListView com ${quotes.length} itens',
                  );
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    itemCount: quotes.length,
                    itemBuilder: (context, index) {
                      final quote = quotes[index];
                      print(
                        '🎨 UI: Renderizando item $index: ${quote.description}',
                      );
                      return _buildQuoteCard(quote);
                    },
                  );
                }

                print(
                  '🎨 UI: Estado não reconhecido, mostrando SizedBox.shrink()',
                );
                return const SizedBox.shrink();
              },
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _showAddQuoteDialog,
              icon: const Icon(Icons.add),
              label: const Text('Novo Orçamento'),
              backgroundColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuoteCard(QuoteEntity quote) {
    final statusColor = _getStatusColor(quote.status);
    final statusText = _getStatusText(quote.status);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    quote.description,
                    style: AppTextStyles.headingMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.s),
                  ),
                  child: Text(
                    statusText,
                    style: AppTextStyles.label.copyWith(color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'R\$ ${quote.totalValue.toStringAsFixed(2)}',
              style: AppTextStyles.headingLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Válido até: ${_formatDate(quote.validUntil)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (quote.notes != null && quote.notes!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                quote.notes!,
                style: AppTextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showQuoteDetails(quote),
                    child: const Text('Ver Detalhes'),
                  ),
                ),
                if (quote.status == QuoteStatus.pending) ...[
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _acceptQuote(quote),
                      child: const Text('Aceitar'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(QuoteStatus status) {
    switch (status) {
      case QuoteStatus.pending:
        return AppColors.warning;
      case QuoteStatus.accepted:
        return AppColors.success;
      case QuoteStatus.rejected:
        return AppColors.error;
      case QuoteStatus.expired:
        return AppColors.textTertiary;
    }
  }

  String _getStatusText(QuoteStatus status) {
    switch (status) {
      case QuoteStatus.pending:
        return 'Pendente';
      case QuoteStatus.accepted:
        return 'Aceito';
      case QuoteStatus.rejected:
        return 'Rejeitado';
      case QuoteStatus.expired:
        return 'Expirado';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showAddQuoteDialog() {
    final descriptionController = TextEditingController();
    final notesController = TextEditingController();
    final deliveryDaysController = TextEditingController(text: '30');
    final downPaymentController = TextEditingController(text: '0');
    final warrantyMonthsController = TextEditingController();
    final shippingCostController = TextEditingController();
    DateTime validUntil = DateTime.now().add(const Duration(days: 30));
    final items = <QuoteItemEntity>[];
    int installments = 1;
    final selectedPaymentMethods = <PaymentMethod>[];
    final cubit = context
        .read<SuppliersCubit>(); // Captura o cubit antes do modal

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: AppSpacing.l,
            right: AppSpacing.l,
            top: AppSpacing.l,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.l,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Novo Orçamento', style: AppTextStyles.headingLarge),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Descrição
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição do Serviço *',
                          hintText: 'Ex: Instalação elétrica completa',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppSpacing.m),

                      // Data de validade
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: validUntil,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setState(() => validUntil = date);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Válido até',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(_formatDate(validUntil)),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),

                      // Observações
                      TextField(
                        controller: notesController,
                        decoration: const InputDecoration(
                          labelText: 'Observações',
                          hintText: 'Informações adicionais',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppSpacing.m),

                      // Prazo de Entrega (OBRIGATÓRIO)
                      TextField(
                        controller: deliveryDaysController,
                        decoration: const InputDecoration(
                          labelText: 'Prazo de Entrega (dias) *',
                          hintText: 'Ex: 30',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.schedule),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: AppSpacing.m),

                      // Parcelas (OBRIGATÓRIO)
                      DropdownButtonFormField<int>(
                        initialValue: installments,
                        decoration: const InputDecoration(
                          labelText: 'Número de Parcelas *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.payment),
                        ),
                        items: [1, 2, 3, 4, 5, 6, 10, 12, 18, 24]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(
                                  value == 1 ? 'À vista' : '$value parcelas',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => installments = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.m),

                      // Formas de Pagamento (OBRIGATÓRIO)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Formas de Pagamento Aceitas *',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s),
                          Wrap(
                            spacing: AppSpacing.s,
                            runSpacing: AppSpacing.s,
                            children: PaymentMethod.values.map((method) {
                              final isSelected = selectedPaymentMethods
                                  .contains(method);
                              return FilterChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      method.icon,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(method.displayName),
                                  ],
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedPaymentMethods.add(method);
                                    } else {
                                      selectedPaymentMethods.remove(method);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.m),

                      // Entrada (OBRIGATÓRIO)
                      TextField(
                        controller: downPaymentController,
                        decoration: const InputDecoration(
                          labelText: 'Valor de Entrada *',
                          hintText: 'Ex: 5000.00',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                          prefixText: 'R\$ ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),

                      // Garantia (OPCIONAL)
                      TextField(
                        controller: warrantyMonthsController,
                        decoration: const InputDecoration(
                          labelText: 'Garantia (meses)',
                          hintText: 'Ex: 12',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.verified_user),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: AppSpacing.m),

                      // Frete (OPCIONAL)
                      TextField(
                        controller: shippingCostController,
                        decoration: const InputDecoration(
                          labelText: 'Custo de Frete',
                          hintText: 'Ex: 150.00',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.local_shipping),
                          prefixText: 'R\$ ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),

                      // Itens
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Itens do Orçamento',
                              style: AppTextStyles.headingMedium,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                _showAddItemDialog(context, setState, items),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Adicionar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s),

                      if (items.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.l),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(AppSpacing.s),
                          ),
                          child: Center(
                            child: Text(
                              'Nenhum item adicionado',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      else
                        ...items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppSpacing.s),
                            child: ListTile(
                              title: Text(item.description),
                              subtitle: Text(
                                '${item.quantity} ${item.unit} × R\$ ${item.unitPrice.toStringAsFixed(2)}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'R\$ ${item.totalPrice.toStringAsFixed(2)}',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: AppColors.error,
                                    ),
                                    onPressed: () {
                                      setState(() => items.removeAt(index));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                      if (items.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.m),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.m),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(AppSpacing.s),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total', style: AppTextStyles.headingMedium),
                              Text(
                                'R\$ ${items.fold<double>(0, (sum, item) => sum + item.totalPrice).toStringAsFixed(2)}',
                                style: AppTextStyles.headingLarge.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: items.isEmpty || descriptionController.text.isEmpty
                      ? null
                      : () {
                          final totalValue = items.fold<double>(
                            0,
                            (sum, item) => sum + item.totalPrice,
                          );

                          final quote = QuoteEntity(
                            id: '', // Será gerado pelo repository
                            projectId: widget.projectId,
                            supplierId: widget.supplierId,
                            description: descriptionController.text,
                            totalValue: totalValue,
                            validUntil: validUntil,
                            status: QuoteStatus.pending,
                            items: items,
                            notes: notesController.text.isEmpty
                                ? null
                                : notesController.text,
                            deliveryDays:
                                int.tryParse(deliveryDaysController.text) ?? 30,
                            installments: installments,
                            paymentMethods: selectedPaymentMethods,
                            downPayment:
                                double.tryParse(downPaymentController.text) ??
                                0,
                            warrantyMonths:
                                warrantyMonthsController.text.isEmpty
                                ? null
                                : int.tryParse(warrantyMonthsController.text),
                            shippingCost: shippingCostController.text.isEmpty
                                ? null
                                : double.tryParse(shippingCostController.text),
                            createdAt: DateTime.now(),
                          );

                          print('🔵 DEBUG: Salvando orçamento...');
                          print('  ProjectId: ${widget.projectId}');
                          print('  SupplierId: ${widget.supplierId}');
                          print('  Description: ${descriptionController.text}');
                          print(
                            '  Total: R\$ ${totalValue.toStringAsFixed(2)}',
                          );
                          print('  Items: ${items.length}');

                          Navigator.pop(modalContext);
                          cubit.addQuote(quote);
                        },
                  child: const Text('Salvar Orçamento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddItemDialog(
    BuildContext parentContext,
    StateSetter parentSetState,
    List<QuoteItemEntity> items,
  ) {
    final descriptionController = TextEditingController();
    final quantityController = TextEditingController();
    final unitController = TextEditingController(text: 'un');
    final priceController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição *',
                  hintText: 'Ex: Tomada 2P+T',
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade *',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: TextField(
                      controller: unitController,
                      decoration: const InputDecoration(labelText: 'Unidade *'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Preço Unitário *',
                  prefixText: 'R\$ ',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (descriptionController.text.isEmpty ||
                  quantityController.text.isEmpty ||
                  unitController.text.isEmpty ||
                  priceController.text.isEmpty) {
                return;
              }

              final item = QuoteItemEntity(
                description: descriptionController.text,
                quantity: double.tryParse(quantityController.text) ?? 0,
                unit: unitController.text,
                unitPrice: double.tryParse(priceController.text) ?? 0,
              );

              parentSetState(() => items.add(item));
              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _showQuoteDetails(QuoteEntity quote) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Detalhes do Orçamento',
                    style: AppTextStyles.headingLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Descrição', style: AppTextStyles.headingSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(quote.description, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.m),
                    Text('Valor Total', style: AppTextStyles.headingSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'R\$ ${quote.totalValue.toStringAsFixed(2)}',
                      style: AppTextStyles.headingLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text('Válido até', style: AppTextStyles.headingSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _formatDate(quote.validUntil),
                      style: AppTextStyles.bodyMedium,
                    ),
                    if (quote.notes != null && quote.notes!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.m),
                      Text('Observações', style: AppTextStyles.headingSmall),
                      const SizedBox(height: AppSpacing.xs),
                      Text(quote.notes!, style: AppTextStyles.bodyMedium),
                    ],
                    if (quote.items.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.m),
                      Text('Itens', style: AppTextStyles.headingSmall),
                      const SizedBox(height: AppSpacing.s),
                      ...quote.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.s),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.description} (${item.quantity} ${item.unit})',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ),
                              Text(
                                'R\$ ${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _compareQuotes(List<QuoteEntity> allQuotes) {
    // Filtra apenas orçamentos pendentes
    final pendingQuotes = allQuotes
        .where((q) => q.status == QuoteStatus.pending)
        .toList();

    if (pendingQuotes.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'É necessário ter pelo menos 2 orçamentos pendentes para comparar',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Navega para tela de comparação (será implementada)
    context.push(
      RouteNames.compareQuotes,
      extra: {
        'projectId': widget.projectId,
        'supplierId': widget.supplierId,
        'quotes': pendingQuotes,
      },
    );
  }

  void _acceptQuote(QuoteEntity quote) {
    showDialog(
      context: context,
      builder: (dialogContext) => _AcceptQuoteDialog(
        quote: quote,
        projectId: widget.projectId,
        supplierId: widget.supplierId,
        onAccept: (installments, firstPaymentDate) {
          context.read<SuppliersCubit>().acceptQuote(
            projectId: widget.projectId,
            quoteId: quote.id,
            supplierId: widget.supplierId,
            installments: installments,
            firstPaymentDate: firstPaymentDate,
          );
        },
      ),
    );
  }
}

class _AcceptQuoteDialog extends StatefulWidget {
  final QuoteEntity quote;
  final String projectId;
  final String supplierId;
  final Function(int installments, DateTime firstPaymentDate) onAccept;

  const _AcceptQuoteDialog({
    required this.quote,
    required this.projectId,
    required this.supplierId,
    required this.onAccept,
  });

  @override
  State<_AcceptQuoteDialog> createState() => _AcceptQuoteDialogState();
}

class _AcceptQuoteDialogState extends State<_AcceptQuoteDialog> {
  int _installments = 1;
  DateTime _firstPaymentDate = DateTime.now().add(const Duration(days: 30));

  @override
  Widget build(BuildContext context) {
    final installmentValue = widget.quote.totalValue / _installments;

    return AlertDialog(
      title: const Text('Aceitar Orçamento'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.quote.description, style: AppTextStyles.headingMedium),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Valor Total: R\$ ${widget.quote.totalValue.toStringAsFixed(2)}',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Text('Configurar Pagamento', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Número de Parcelas',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Row(
              children: [
                IconButton(
                  onPressed: _installments > 1
                      ? () => setState(() => _installments--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Expanded(
                  child: Text(
                    '$_installments ${_installments == 1 ? 'parcela' : 'parcelas'}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headingMedium,
                  ),
                ),
                IconButton(
                  onPressed: _installments < 120
                      ? () => setState(() => _installments++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.s),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Valor por parcela:'),
                      Text(
                        'R\$ ${installmentValue.toStringAsFixed(2)}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Data da Primeira Parcela',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            OutlinedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _firstPaymentDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _firstPaymentDate = date);
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(
                '${_firstPaymentDate.day.toString().padLeft(2, '0')}/'
                '${_firstPaymentDate.month.toString().padLeft(2, '0')}/'
                '${_firstPaymentDate.year}',
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(AppSpacing.s),
                border: Border.all(color: AppColors.info),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.info),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      'Ao aceitar, este orçamento será registrado no financeiro e as parcelas serão criadas automaticamente.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            widget.onAccept(_installments, _firstPaymentDate);
            Navigator.pop(context);
          },
          child: const Text('Aceitar Orçamento'),
        ),
      ],
    );
  }
}

// Made with Bob
