import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../domain/entities/quote_entity.dart';
import '../../domain/usecases/compare_quotes_usecase.dart';

class QuoteComparisonCard extends StatelessWidget {
  final QuoteWithSupplier quoteWithSupplier;
  final bool isCheapest;
  final bool isFastest;
  final double averagePrice;

  const QuoteComparisonCard({
    super.key,
    required this.quoteWithSupplier,
    required this.isCheapest,
    required this.isFastest,
    required this.averagePrice,
  });

  @override
  Widget build(BuildContext context) {
    final quote = quoteWithSupplier.quote;
    final supplier = quoteWithSupplier.supplier;

    final diffFromAverage = quote.totalValue - averagePrice;
    final diffPercent = (diffFromAverage / averagePrice) * 100;
    final isAboveAverage = diffFromAverage > 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: isCheapest
            ? Border.all(color: AppColors.success, width: 2)
            : null,
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
          Row(
            children: [
              Expanded(
                child: Text(supplier.name, style: AppTextStyles.headingMedium),
              ),
              if (isCheapest)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(AppRadius.s),
                  ),
                  child: Text(
                    'MELHOR PREÇO',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
              if (isFastest && !isCheapest)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.s),
                  ),
                  child: Text(
                    'MAIS RÁPIDO',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),

          // Valor total
          Text(
            CurrencyUtils.format(quote.totalValue),
            style: AppTextStyles.moneyLarge,
          ),

          // Diferença da média
          Row(
            children: [
              Icon(
                isAboveAverage ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: isAboveAverage ? AppColors.error : AppColors.success,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                '${diffPercent.abs().toStringAsFixed(1)}% ${isAboveAverage ? 'acima' : 'abaixo'} da média',
                style: AppTextStyles.caption.copyWith(
                  color: isAboveAverage ? AppColors.error : AppColors.success,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.m),

          // Informações adicionais
          _buildInfoRow('Validade', _formatDate(quote.validUntil)),
          _buildInfoRow('Itens', '${quote.items.length}'),
          _buildInfoRow('Status', quote.status.displayName),

          if (quote.notes != null && quote.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              'Observações:',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              quote.notes!,
              style: AppTextStyles.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

// Made with Bob
