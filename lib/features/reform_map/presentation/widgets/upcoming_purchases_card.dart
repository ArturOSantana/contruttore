import 'package:flutter/material.dart';
import '../../domain/entities/upcoming_purchase_entity.dart';

/// Card que exibe as próximas compras necessárias
///
/// Mostra até 3 compras mais urgentes com:
/// - Nome do item
/// - Categoria e fase
/// - Urgência com badge colorido
/// - Prazo estimado
/// - Custo estimado
/// - Dicas importantes
///
/// Design:
/// - Gradiente verde (compras = investimento positivo)
/// - Cards internos brancos com sombra
/// - Badges coloridos por urgência
/// - Ícones por categoria
class UpcomingPurchasesCard extends StatelessWidget {
  final List<UpcomingPurchaseEntity> purchases;
  final VoidCallback? onSeeAll;

  const UpcomingPurchasesCard({
    super.key,
    required this.purchases,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    // Mostra apenas as 3 mais urgentes
    final displayPurchases = purchases.take(3).toList();
    final remainingCount = purchases.length - displayPurchases.length;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF10B981), // Verde
            Color(0xFF059669), // Verde escuro
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Próximas Compras',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Materiais e serviços necessários',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Lista de compras
            ...displayPurchases.map((purchase) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PurchaseItem(purchase: purchase),
                )),

            // Contador de compras restantes
            if (remainingCount > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_shopping_cart,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+ $remainingCount ${remainingCount == 1 ? 'compra pendente' : 'compras pendentes'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Item individual de compra
class _PurchaseItem extends StatelessWidget {
  final UpcomingPurchaseEntity purchase;

  const _PurchaseItem({required this.purchase});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com nome e urgência
          Row(
            children: [
              // Ícone da categoria
              Text(
                purchase.categoryIcon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),

              // Nome e fase
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      purchase.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      purchase.phaseName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Badge de urgência
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getUrgencyColor(purchase.urgency),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  purchase.urgencyText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Informações
          Row(
            children: [
              // Prazo
              Expanded(
                child: _InfoChip(
                  icon: Icons.schedule,
                  label: purchase.deadlineText,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),

              // Custo
              if (purchase.estimatedCost != null)
                Expanded(
                  child: _InfoChip(
                    icon: Icons.attach_money,
                    label: _formatCurrency(purchase.estimatedCost!),
                    color: Colors.green,
                  ),
                ),
            ],
          ),

          // Quantidade
          if (purchase.quantity != null) ...[
            const SizedBox(height: 8),
            _InfoChip(
              icon: Icons.inventory_2,
              label: purchase.quantity!,
              color: Colors.orange,
            ),
          ],

          // Motivo
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    purchase.reason,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dicas (primeira dica apenas)
          if (purchase.tips.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      purchase.tips.first,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade900,
                      ),
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

  Color _getUrgencyColor(PurchaseUrgency urgency) {
    switch (urgency) {
      case PurchaseUrgency.critical:
        return const Color(0xFFEF4444); // Vermelho
      case PurchaseUrgency.high:
        return const Color(0xFFF97316); // Laranja
      case PurchaseUrgency.medium:
        return const Color(0xFFEAB308); // Amarelo
      case PurchaseUrgency.low:
        return const Color(0xFF22C55E); // Verde
    }
  }

  String _formatCurrency(double value) {
    if (value >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(1)}k';
    }
    return 'R\$ ${value.toStringAsFixed(0)}';
  }
}

/// Chip de informação
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// Made with Bob
