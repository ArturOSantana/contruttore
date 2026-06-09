import 'package:flutter/material.dart';
import '../../domain/entities/next_phase_preparation_entity.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

/// Card que mostra a preparação para a próxima etapa
///
/// Exibe:
/// - Nome da próxima fase
/// - Score de prontidão
/// - Checklist de preparação
/// - Alertas importantes
/// - Dias até o início
///
/// Design:
/// - Gradiente laranja/vermelho
/// - Ícone de foguete
/// - Barra de progresso
/// - Lista de itens por categoria
class NextPhasePreparationCard extends StatelessWidget {
  final NextPhasePreparationEntity preparation;
  final VoidCallback? onTap;

  const NextPhasePreparationCard({
    super.key,
    required this.preparation,
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
              colors: [
                Colors.orange.shade400,
                Colors.deepOrange.shade600,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppSpacing.md),
                _buildReadinessScore(),
                const SizedBox(height: AppSpacing.md),
                _buildAlerts(),
                const SizedBox(height: AppSpacing.md),
                _buildChecklist(),
                const SizedBox(height: AppSpacing.sm),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Header com ícone e título
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.rocket_launch,
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
                'Preparação',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                preparation.nextPhaseName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (preparation.daysUntilStart > 0)
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
              '${preparation.daysUntilStart}d',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  /// Score de prontidão com barra de progresso
  Widget _buildReadinessScore() {
    final isReady = preparation.isReady;
    final score = preparation.readinessScore;

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
                'Prontidão',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Icon(
                    isReady ? Icons.check_circle : Icons.pending,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$score%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isReady ? Colors.green.shade300 : Colors.yellow.shade300,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isReady ? ' Pronto para começar' : 'Ainda há itens pendentes',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Alertas importantes
  Widget _buildAlerts() {
    if (preparation.alerts.isEmpty) {
      return const SizedBox.shrink();
    }

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
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Atenção',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...preparation.alerts.map((alert) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  alert,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  /// Checklist de preparação
  Widget _buildChecklist() {
    // Agrupa por categoria
    final byCategory = <PreparationCategory, List<PreparationItemEntity>>{};
    for (final item in preparation.checklist) {
      byCategory.putIfAbsent(item.category, () => []).add(item);
    }

    // Ordena categorias por prioridade
    final sortedCategories = byCategory.keys.toList()
      ..sort(
          (a, b) => _getCategoryPriority(a).compareTo(_getCategoryPriority(b)));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Checklist',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...sortedCategories.map((category) {
            final items = byCategory[category]!;
            return _buildCategorySection(category, items);
          }),
        ],
      ),
    );
  }

  /// Seção de categoria
  Widget _buildCategorySection(
    PreparationCategory category,
    List<PreparationItemEntity> items,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getCategoryIcon(category),
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _getCategoryName(category),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...items.take(3).map((item) => _buildChecklistItem(item)),
          if (items.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+${items.length - 3} ${items.length - 3 == 1 ? 'item' : 'itens'}',
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

  /// Item do checklist
  Widget _buildChecklistItem(PreparationItemEntity item) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            item.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: item.isDone ? Colors.green.shade300 : Colors.white60,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                decoration: item.isDone ? TextDecoration.lineThrough : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (item.priority == PreparationPriority.critical)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'CRÍTICO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Footer com resumo
  Widget _buildFooter() {
    final total = preparation.checklist.length;
    final done = preparation.checklist.where((item) => item.isDone).length;
    final pending = total - done;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$done de $total ${total == 1 ? 'item concluído' : 'itens concluídos'}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
        if (pending > 0)
          Text(
            '$pending ${pending == 1 ? 'pendente' : 'pendentes'}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  /// Retorna prioridade da categoria para ordenação
  int _getCategoryPriority(PreparationCategory category) {
    switch (category) {
      case PreparationCategory.approval:
        return 1;
      case PreparationCategory.decision:
        return 2;
      case PreparationCategory.professional:
        return 3;
      case PreparationCategory.purchase:
        return 4;
      case PreparationCategory.measurement:
        return 5;
      case PreparationCategory.document:
        return 6;
    }
  }

  /// Retorna ícone da categoria
  IconData _getCategoryIcon(PreparationCategory category) {
    switch (category) {
      case PreparationCategory.approval:
        return Icons.verified;
      case PreparationCategory.decision:
        return Icons.psychology;
      case PreparationCategory.professional:
        return Icons.engineering;
      case PreparationCategory.purchase:
        return Icons.shopping_cart;
      case PreparationCategory.measurement:
        return Icons.straighten;
      case PreparationCategory.document:
        return Icons.description;
    }
  }

  /// Retorna nome da categoria
  String _getCategoryName(PreparationCategory category) {
    switch (category) {
      case PreparationCategory.approval:
        return 'Aprovações';
      case PreparationCategory.decision:
        return 'Decisões';
      case PreparationCategory.professional:
        return 'Profissionais';
      case PreparationCategory.purchase:
        return 'Compras';
      case PreparationCategory.measurement:
        return 'Medições';
      case PreparationCategory.document:
        return 'Documentos';
    }
  }
}

// Made with Bob
