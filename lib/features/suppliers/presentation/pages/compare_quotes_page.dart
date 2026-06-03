import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../cubit/suppliers_cubit.dart';
import '../cubit/suppliers_state.dart';
import '../widgets/quote_comparison_card.dart';
import '../widgets/quote_comparison_table.dart';
import '../widgets/savings_banner.dart';

class CompareQuotesPage extends StatefulWidget {
  final String projectId;
  final List<String> quoteIds;

  const CompareQuotesPage({
    super.key,
    required this.projectId,
    required this.quoteIds,
  });

  @override
  State<CompareQuotesPage> createState() => _CompareQuotesPageState();
}

class _CompareQuotesPageState extends State<CompareQuotesPage> {
  @override
  void initState() {
    super.initState();
    // Iniciar comparação
    context.read<SuppliersCubit>().compareQuotes(
      widget.projectId,
      widget.quoteIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Comparar Orçamentos'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: BlocBuilder<SuppliersCubit, SuppliersState>(
        builder: (context, state) {
          if (state is SuppliersLoading) {
            return const LoadingWidget();
          }

          if (state is SuppliersError) {
            return ErrorWidgetCustom(
              message: state.message,
              onRetry: () => context.read<SuppliersCubit>().compareQuotes(
                widget.projectId,
                widget.quoteIds,
              ),
            );
          }

          if (state is QuotesCompared) {
            final comparison = state.comparison;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner de economia
                  SavingsBanner(
                    maxSavings: comparison.maxSavings,
                    savingsPercent: comparison.savingsPercent,
                  ),

                  const SizedBox(height: AppSpacing.l),

                  // Resumo dos orçamentos
                  Text('Resumo', style: AppTextStyles.headingLarge),
                  const SizedBox(height: AppSpacing.m),

                  ...comparison.quotesWithSuppliers.map((qws) {
                    final isCheapest =
                        qws.quote.id == comparison.cheapest.quote.id;
                    final isFastest =
                        qws.quote.id == comparison.fastest.quote.id;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.m),
                      child: QuoteComparisonCard(
                        quoteWithSupplier: qws,
                        isCheapest: isCheapest,
                        isFastest: isFastest,
                        averagePrice: comparison.averagePrice,
                      ),
                    );
                  }),

                  const SizedBox(height: AppSpacing.l),

                  // Tabela comparativa detalhada
                  Text(
                    'Comparação Detalhada',
                    style: AppTextStyles.headingLarge,
                  ),
                  const SizedBox(height: AppSpacing.m),

                  QuoteComparisonTable(
                    quotesWithSuppliers: comparison.quotesWithSuppliers,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Botão para aceitar o melhor orçamento
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showAcceptDialog(
                          context,
                          comparison.cheapest.quote.id,
                          comparison.cheapest.supplier.name,
                          comparison.cheapest.supplier.id,
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Aceitar Melhor Orçamento'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.textInverse,
                        padding: const EdgeInsets.all(AppSpacing.m),
                      ),
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

  void _showAcceptDialog(
    BuildContext context,
    String quoteId,
    String supplierName,
    String supplierId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aceitar Orçamento'),
        content: Text(
          'Deseja aceitar o orçamento de $supplierName?\n\n'
          'Esta ação irá marcar este orçamento como aceito e os demais como rejeitados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Mostrar dialog para configurar parcelas
              _showInstallmentsDialog(context, quoteId, supplierId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Aceitar'),
          ),
        ],
      ),
    );
  }

  void _showInstallmentsDialog(
    BuildContext context,
    String quoteId,
    String supplierId,
  ) {
    int installments = 1;
    DateTime firstPaymentDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Configurar Pagamento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Como deseja pagar este orçamento?'),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: installments,
                decoration: const InputDecoration(
                  labelText: 'Número de Parcelas',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(12, (i) => i + 1)
                    .map(
                      (n) => DropdownMenuItem(
                        value: n,
                        child: Text(n == 1 ? 'À vista' : '$n parcelas'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    installments = value ?? 1;
                  });
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Data da Primeira Parcela'),
                subtitle: Text(
                  '${firstPaymentDate.day}/${firstPaymentDate.month}/${firstPaymentDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: firstPaymentDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      firstPaymentDate = date;
                    });
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
                Navigator.pop(dialogContext);
                // Aceitar orçamento com parcelas
                context.read<SuppliersCubit>().acceptQuote(
                  projectId: widget.projectId,
                  quoteId: quoteId,
                  supplierId: supplierId,
                  installments: installments,
                  firstPaymentDate: firstPaymentDate,
                );
                // Voltar para a tela anterior
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }
}

// Made with Bob
