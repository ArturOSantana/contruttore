import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/entities/quote_entity.dart';
import '../cubit/suppliers_cubit.dart';
import '../cubit/suppliers_state.dart';

/// Página de Comparação de Fornecedores
///
/// Compara múltiplos fornecedores da mesma categoria lado a lado
/// Mostra: Nome, Avaliação, Telefone, Email, Status
class CompareSuppliersPage extends StatefulWidget {
  final String projectId;
  final List<String> supplierIds;

  const CompareSuppliersPage({
    super.key,
    required this.projectId,
    required this.supplierIds,
  });

  @override
  State<CompareSuppliersPage> createState() => _CompareSuppliersPageState();
}

class _CompareSuppliersPageState extends State<CompareSuppliersPage> {
  final Map<String, List<QuoteEntity>> _quotesCache = {};
  bool _isLoadingQuotes = false;

  @override
  void initState() {
    super.initState();
    _loadAllQuotes();
  }

  Future<void> _loadAllQuotes() async {
    setState(() => _isLoadingQuotes = true);

    final cubit = context.read<SuppliersCubit>();

    for (final supplierId in widget.supplierIds) {
      await cubit.loadQuotes(widget.projectId, supplierId);
      final state = cubit.state;
      if (state is QuotesLoaded) {
        _quotesCache[supplierId] = state.quotes;
      }
    }

    setState(() => _isLoadingQuotes = false);
  }

  @override
  Widget build(BuildContext context) {
    // Garantir que os fornecedores sejam carregados ao entrar na página
    context.read<SuppliersCubit>().loadSuppliers(widget.projectId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Comparar Fornecedores')),
      body: BlocBuilder<SuppliersCubit, SuppliersState>(
        builder: (context, state) {
          if (state is SuppliersLoading) {
            return const LoadingWidget();
          }

          if (state is SuppliersError) {
            return ErrorWidgetCustom(
              message: state.message,
              onRetry: () => context.read<SuppliersCubit>().loadSuppliers(
                    widget.projectId,
                  ),
            );
          }

          if (state is SuppliersLoaded) {
            final suppliers = state.suppliers
                .where((s) => widget.supplierIds.contains(s.id))
                .toList();

            if (suppliers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'Nenhum fornecedor encontrado',
                      style: AppTextStyles.headingMedium,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      'IDs selecionados: ${widget.supplierIds.join(", ")}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return _buildComparisonTable(context, suppliers);
          }

          // Estado inicial ou desconhecido
          return const Center(child: LoadingWidget());
        },
      ),
    );
  }

  Widget _buildComparisonTable(
    BuildContext context,
    List<SupplierEntity> suppliers,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com categoria
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.m),
            ),
            child: Row(
              children: [
                Icon(
                  suppliers.first.type.icon,
                  size: 32,
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comparando ${suppliers.length} ${suppliers.first.type.displayName}s',
                        style: AppTextStyles.headingMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Escolha o melhor fornecedor para seu projeto',
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
          const SizedBox(height: AppSpacing.l),

          // Cards de comparação
          ...suppliers.map(
            (supplier) =>
                _buildSupplierComparisonCard(context, supplier, suppliers),
          ),

          const SizedBox(height: AppSpacing.l),

          // Resumo da comparação
          _buildComparisonSummary(suppliers),
        ],
      ),
    );
  }

  Widget _buildSupplierComparisonCard(
    BuildContext context,
    SupplierEntity supplier,
    List<SupplierEntity> allSuppliers,
  ) {
    // Determinar se é o melhor avaliado
    final bestRated =
        allSuppliers.where((s) => s.rating != null).fold<SupplierEntity?>(
              null,
              (best, current) =>
                  best == null || (current.rating ?? 0) > (best.rating ?? 0)
                      ? current
                      : best,
            );

    final isBestRated = bestRated?.id == supplier.id && supplier.rating != null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border:
            isBestRated ? Border.all(color: AppColors.success, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com nome e badge
            Row(
              children: [
                Expanded(
                  child: Text(supplier.name, style: AppTextStyles.headingSmall),
                ),
                if (isBestRated)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(AppRadius.s),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.white),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          'Melhor Avaliado',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),

            // Avaliação
            if (supplier.rating != null) ...[
              _buildComparisonRow(
                icon: Icons.star,
                label: 'Avaliação',
                value: Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < supplier.rating!.round()
                            ? Icons.star
                            : Icons.star_border,
                        size: 16,
                        color: AppColors.warning,
                      );
                    }),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      supplier.rating!.toStringAsFixed(1),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              _buildComparisonRow(
                icon: Icons.star_border,
                label: 'Avaliação',
                value: Text(
                  'Sem avaliação',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],

            const Divider(height: AppSpacing.m),

            // Valor Total
            if (supplier.totalValue != null) ...[
              _buildComparisonRow(
                icon: Icons.attach_money,
                label: 'Valor Total',
                value: Text(
                  CurrencyUtils.format(supplier.totalValue!),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Divider(height: AppSpacing.m),
            ],

            // Parcelas
            if (supplier.totalValue != null) ...[
              _buildComparisonRow(
                icon: Icons.calendar_today,
                label: 'Parcelas',
                value: Text(
                  supplier.installments == 1
                      ? 'À vista'
                      : '${supplier.installments}x de ${CurrencyUtils.format(supplier.totalValue! / supplier.installments)}',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              const Divider(height: AppSpacing.m),
            ],

            // Formas de Pagamento
            if (supplier.paymentMethods.isNotEmpty) ...[
              _buildComparisonRow(
                icon: Icons.payment,
                label: 'Pagamento',
                value: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: supplier.paymentMethods.map((method) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.s),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            method.icon,
                            size: 12,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            method.displayName,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: AppSpacing.m),
            ],

            // Lista de Orçamentos
            _buildComparisonRow(
              icon: Icons.description,
              label: 'Orçamentos',
              value: _buildQuotesList(supplier.id),
            ),

            const Divider(height: AppSpacing.m),

            // Prazo de Entrega (Média)
            _buildComparisonRow(
              icon: Icons.schedule,
              label: 'Prazo',
              value: _buildQuoteValue(supplier.id, (quotes) {
                if (quotes.isEmpty) return 'Sem orçamentos';
                final avgDays =
                    quotes.map((q) => q.deliveryDays).reduce((a, b) => a + b) ~/
                        quotes.length;
                return '$avgDays dias';
              }),
            ),

            const Divider(height: AppSpacing.m),

            // Entrada
            _buildComparisonRow(
              icon: Icons.attach_money,
              label: 'Entrada',
              value: _buildQuoteValue(supplier.id, (quotes) {
                if (quotes.isEmpty) return 'Sem orçamentos';
                final avgDown =
                    quotes.map((q) => q.downPayment).reduce((a, b) => a + b) /
                        quotes.length;
                return CurrencyUtils.format(avgDown);
              }),
            ),

            const Divider(height: AppSpacing.m),

            // Garantia
            _buildComparisonRow(
              icon: Icons.verified_user,
              label: 'Garantia',
              value: _buildQuoteValue(supplier.id, (quotes) {
                if (quotes.isEmpty) return 'Sem orçamentos';
                final withWarranty = quotes.where(
                  (q) => q.warrantyMonths != null,
                );
                if (withWarranty.isEmpty) return 'Sem garantia';
                final avgWarranty = withWarranty
                        .map((q) => q.warrantyMonths!)
                        .reduce((a, b) => a + b) ~/
                    withWarranty.length;
                return '$avgWarranty meses';
              }),
            ),

            const Divider(height: AppSpacing.m),

            // Frete
            _buildComparisonRow(
              icon: Icons.local_shipping,
              label: 'Frete',
              value: _buildQuoteValue(supplier.id, (quotes) {
                if (quotes.isEmpty) return 'Sem orçamentos';
                final withShipping = quotes.where(
                  (q) => q.shippingCost != null,
                );
                if (withShipping.isEmpty) return 'Grátis';
                final avgShipping = withShipping
                        .map((q) => q.shippingCost!)
                        .reduce((a, b) => a + b) /
                    withShipping.length;
                return CurrencyUtils.format(avgShipping);
              }),
            ),

            const Divider(height: AppSpacing.m),

            // Telefone
            _buildComparisonRow(
              icon: Icons.phone,
              label: 'Telefone',
              value: Text(supplier.phone, style: AppTextStyles.bodyMedium),
            ),

            // Email
            if (supplier.email != null) ...[
              const Divider(height: AppSpacing.m),
              _buildComparisonRow(
                icon: Icons.email,
                label: 'E-mail',
                value: Text(
                  supplier.email!,
                  style: AppTextStyles.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            // Observações
            if (supplier.notes != null && supplier.notes!.isNotEmpty) ...[
              const Divider(height: AppSpacing.m),
              _buildComparisonRow(
                icon: Icons.note,
                label: 'Observações',
                value: Text(
                  supplier.notes!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            // Status
            const Divider(height: AppSpacing.m),
            _buildComparisonRow(
              icon: Icons.info_outline,
              label: 'Status',
              value: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    supplier.status,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.s),
                ),
                child: Text(
                  supplier.status.displayName,
                  style: AppTextStyles.caption.copyWith(
                    color: _getStatusColor(supplier.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Botões de ação
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _makePhoneCall(context, supplier.phone),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Ligar'),
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _selectSupplier(context, supplier),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Escolher'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow({
    required IconData icon,
    required String label,
    required Widget value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.s),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(child: value),
        ],
      ),
    );
  }

  Widget _buildComparisonSummary(List<SupplierEntity> suppliers) {
    final withRating = suppliers.where((s) => s.rating != null).toList();
    final avgRating = withRating.isEmpty
        ? 0.0
        : withRating.fold<double>(0, (sum, s) => sum + s.rating!) /
            withRating.length;

    final withValue = suppliers.where((s) => s.totalValue != null).toList();
    final minValue = withValue.isEmpty
        ? null
        : withValue.map((s) => s.totalValue!).reduce((a, b) => a < b ? a : b);
    final maxValue = withValue.isEmpty
        ? null
        : withValue.map((s) => s.totalValue!).reduce((a, b) => a > b ? a : b);
    final avgValue = withValue.isEmpty
        ? null
        : withValue.fold<double>(0, (sum, s) => sum + s.totalValue!) /
            withValue.length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.infoLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: AppColors.info),
              const SizedBox(width: AppSpacing.s),
              Text(
                'Resumo da Comparação',
                style: AppTextStyles.headingSmall.copyWith(
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          _buildSummaryRow('Total de fornecedores', '${suppliers.length}'),

          // Avaliações
          if (withRating.isNotEmpty) ...[
            const Divider(height: AppSpacing.m),
            _buildSummaryRow('Com avaliação', '${withRating.length}'),
            _buildSummaryRow(
              'Avaliação média',
              '⭐ ${avgRating.toStringAsFixed(1)}',
            ),
          ],

          // Valores
          if (withValue.isNotEmpty) ...[
            const Divider(height: AppSpacing.m),
            _buildSummaryRow('Com orçamento', '${withValue.length}'),
            if (minValue != null)
              _buildSummaryRow('Menor valor', CurrencyUtils.format(minValue)),
            if (maxValue != null)
              _buildSummaryRow('Maior valor', CurrencyUtils.format(maxValue)),
            if (avgValue != null)
              _buildSummaryRow('Valor médio', CurrencyUtils.format(avgValue)),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
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
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SupplierStatus status) {
    switch (status) {
      case SupplierStatus.active:
        return AppColors.success;
      case SupplierStatus.completed:
        return AppColors.info;
      case SupplierStatus.problem:
        return AppColors.error;
    }
  }

  Widget _buildQuoteValue(
    String supplierId,
    String Function(List<QuoteEntity>) calculator,
  ) {
    if (_isLoadingQuotes) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final quotes = _quotesCache[supplierId] ?? [];
    final value = calculator(quotes);

    return Text(
      value,
      style: AppTextStyles.bodyMedium.copyWith(
        color: quotes.isEmpty ? AppColors.textTertiary : null,
      ),
    );
  }

  Widget _buildQuotesList(String supplierId) {
    if (_isLoadingQuotes) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final quotes = _quotesCache[supplierId] ?? [];

    if (quotes.isEmpty) {
      return Text(
        'Sem orçamentos',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: quotes.map((quote) {
        final isExpired = quote.validUntil.isBefore(DateTime.now());

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
          padding: const EdgeInsets.all(AppSpacing.s),
          decoration: BoxDecoration(
            color: isExpired
                ? AppColors.error.withValues(alpha: 0.1)
                : AppColors.primaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.s),
            border: Border.all(
              color: isExpired ? AppColors.error : AppColors.primary,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      quote.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(AppRadius.s),
                      ),
                      child: Text(
                        'EXPIRADO',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color:
                        isExpired ? AppColors.error : AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    'Válido até: ${_formatDate(quote.validUntil)}',
                    style: AppTextStyles.caption.copyWith(
                      color:
                          isExpired ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                CurrencyUtils.format(quote.totalValue),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _makePhoneCall(BuildContext context, String phone) {
    // Implementação já existe na suppliers_page
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Ligando para $phone...')));
  }

  void _selectSupplier(BuildContext context, SupplierEntity supplier) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Escolha'),
        content: Text(
          'Deseja escolher ${supplier.name} como fornecedor?\n\n'
          'Você poderá criar um orçamento e gerenciar o contrato.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context, supplier);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}

// Made with Bob
