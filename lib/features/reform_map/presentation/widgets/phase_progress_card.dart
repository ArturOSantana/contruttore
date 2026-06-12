import 'package:flutter/material.dart';
import '../../domain/entities/phase_analysis_entity.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../../../../app/theme/app_spacing.dart';

/// Card que mostra o progresso REAL da fase atual
///
/// Usa dados reais do Firestore através do PhaseAnalysisEntity:
/// - Conclusão percentual (baseado em fornecedores, compras, pagamentos)
/// - Status de saúde (excellent/good/warning/critical)
/// - Itens faltantes (o que precisa ser feito)
/// - Recomendações personalizadas
///
/// Este card substitui o NextPhasePreparationCard quando queremos
/// mostrar o progresso da fase ATUAL em vez da preparação da próxima.
class PhaseProgressCard extends StatelessWidget {
  final PhaseEntity phase;
  final PhaseAnalysisEntity analysis;
  final VoidCallback? onTap;

  const PhaseProgressCard({
    super.key,
    required this.phase,
    required this.analysis,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getGradientColors(),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppSpacing.md),
                _buildProgressSection(context),
                if (analysis.missingItems.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  _buildMissingItems(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Retorna as cores do gradiente baseado no status de saúde
  List<Color> _getGradientColors() {
    switch (analysis.healthStatus) {
      case PhaseHealthStatus.excellent:
        return [Colors.green.shade400, Colors.teal.shade600];
      case PhaseHealthStatus.good:
        return [Colors.blue.shade400, Colors.indigo.shade600];
      case PhaseHealthStatus.warning:
        return [Colors.orange.shade400, Colors.deepOrange.shade600];
      case PhaseHealthStatus.critical:
        return [Colors.red.shade400, Colors.pink.shade600];
    }
  }

  /// Header com ícone e título
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getStatusIcon(),
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Progresso da Fase',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                phase.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getStatusText(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Seção de progresso com barra e percentual
  Widget _buildProgressSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Conclusão',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${analysis.completionPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: analysis.completionPercentage / 100,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildProgressDetails(),
        ],
      ),
    );
  }

  /// Detalhes do progresso (fornecedores, compras, pagamentos)
  Widget _buildProgressDetails() {
    return Column(
      children: [
        _buildProgressItem(
          'Fornecedores',
          analysis.actualSuppliersCount,
          analysis.expectedSupplierTypes.length,
          Icons.person,
        ),
        const SizedBox(height: 4),
        _buildProgressItem(
          'Compras',
          analysis.purchasedItemsCount,
          analysis.expectedPurchaseCategories.length,
          Icons.shopping_cart,
        ),
        const SizedBox(height: 4),
        _buildProgressItem(
          'Pagamentos',
          analysis.paidPaymentsCount,
          analysis.totalPaymentsCount,
          Icons.payment,
        ),
      ],
    );
  }

  /// Item individual de progresso
  Widget _buildProgressItem(
    String label,
    int current,
    int total,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$current/$total',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Lista de itens faltantes
  Widget _buildMissingItems(BuildContext context) {
    final itemsToShow = analysis.missingItems.take(3).toList();
    final hasMore = analysis.missingItems.length > 3;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.checklist,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Falta fazer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...itemsToShow.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          if (hasMore)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+ ${analysis.missingItems.length - 3} itens',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Retorna o ícone baseado no status
  IconData _getStatusIcon() {
    switch (analysis.healthStatus) {
      case PhaseHealthStatus.excellent:
        return Icons.check_circle;
      case PhaseHealthStatus.good:
        return Icons.thumb_up;
      case PhaseHealthStatus.warning:
        return Icons.warning_amber;
      case PhaseHealthStatus.critical:
        return Icons.error;
    }
  }

  /// Retorna o texto do status
  String _getStatusText() {
    switch (analysis.healthStatus) {
      case PhaseHealthStatus.excellent:
        return 'Excelente';
      case PhaseHealthStatus.good:
        return 'Bom';
      case PhaseHealthStatus.warning:
        return 'Atenção';
      case PhaseHealthStatus.critical:
        return 'Crítico';
    }
  }
}

// Made with Bob
