import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../domain/entities/quote_entity.dart';
import '../../domain/usecases/compare_quotes_usecase.dart';

class QuoteComparisonTable extends StatelessWidget {
  final List<QuoteWithSupplier> quotesWithSuppliers;

  const QuoteComparisonTable({super.key, required this.quotesWithSuppliers});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.m),
                topRight: Radius.circular(AppRadius.m),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Critério',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                ...quotesWithSuppliers.map(
                  (qws) => Expanded(
                    child: Text(
                      qws.supplier.name,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Rows
          _buildRow(
            'Valor Total',
            quotesWithSuppliers
                .map((qws) => CurrencyUtils.format(qws.quote.totalValue))
                .toList(),
          ),
          _buildRow(
            'Qtd. Itens',
            quotesWithSuppliers
                .map((qws) => '${qws.quote.items.length}')
                .toList(),
          ),
          _buildRow(
            'Validade',
            quotesWithSuppliers
                .map(
                  (qws) => DateFormat('dd/MM/yy').format(qws.quote.validUntil),
                )
                .toList(),
          ),
          _buildRow(
            'Status',
            quotesWithSuppliers
                .map((qws) => qws.quote.status.displayName)
                .toList(),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, List<String> values, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...values.map(
            (value) => Expanded(
              child: Text(
                value,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Made with Bob
