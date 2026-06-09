import 'package:flutter/material.dart';
import '../../domain/entities/milestone_entity.dart';
import '../../../../app/theme/app_spacing.dart';

/// Card que mostra os marcos da reforma
///
/// Exibe:
/// - Marcos alcançados recentemente
/// - Próximos marcos
/// - Progresso geral
/// - Mensagens de celebração
///
/// Design:
/// - Gradiente dourado/amarelo (celebração)
/// - Ícones de troféu
/// - Animações de conquista
/// - Lista de marcos por tipo
class MilestonesCard extends StatelessWidget {
  final List<MilestoneEntity> milestones;
  final VoidCallback? onTap;

  const MilestonesCard({
    super.key,
    required this.milestones,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Separa marcos alcançados e próximos
    final achieved = milestones.where((m) => m.isAchieved).toList();
    final upcoming = milestones.where((m) => !m.isAchieved).toList();
    final recent = milestones.where((m) => m.isRecent).toList();

    // Se não há marcos, não exibe o card
    if (milestones.isEmpty) {
      return const SizedBox.shrink();
    }

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
                Colors.amber.shade400,
                Colors.orange.shade600,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(achieved.length, milestones.length),
                const SizedBox(height: AppSpacing.md),
                if (recent.isNotEmpty) ...[
                  _buildRecentMilestones(recent),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (upcoming.isNotEmpty) ...[
                  _buildUpcomingMilestones(upcoming),
                  const SizedBox(height: AppSpacing.sm),
                ],
                _buildFooter(achieved.length, milestones.length),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Header com ícone e título
  Widget _buildHeader(int achieved, int total) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.emoji_events,
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
                'Marcos da Reforma',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$achieved de $total ${total == 1 ? 'marco alcançado' : 'marcos alcançados'}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
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
            '${((achieved / total) * 100).round()}%',
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

  /// Marcos alcançados recentemente
  Widget _buildRecentMilestones(List<MilestoneEntity> recent) {
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
                Icons.celebration,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Conquistas Recentes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...recent.take(3).map((milestone) => _buildMilestoneItem(
                milestone,
                isAchieved: true,
              )),
        ],
      ),
    );
  }

  /// Próximos marcos
  Widget _buildUpcomingMilestones(List<MilestoneEntity> upcoming) {
    // Ordena por progresso (mais próximos primeiro)
    final sorted = List<MilestoneEntity>.from(upcoming)
      ..sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));

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
                Icons.flag,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Próximos Marcos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...sorted.take(3).map((milestone) => _buildMilestoneItem(
                milestone,
                isAchieved: false,
              )),
          if (sorted.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+${sorted.length - 3} ${sorted.length - 3 == 1 ? 'marco' : 'marcos'}',
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

  /// Item individual de marco
  Widget _buildMilestoneItem(
    MilestoneEntity milestone, {
    required bool isAchieved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            milestone.icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isAchieved && milestone.progressPercentage > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: milestone.progressPercentage / 100,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                milestone.isNear
                                    ? Colors.green.shade300
                                    : Colors.white.withOpacity(0.6),
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${milestone.progressPercentage}%',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (isAchieved)
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            )
          else if (milestone.isNear)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'PERTO',
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
  Widget _buildFooter(int achieved, int total) {
    final remaining = total - achieved;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (achieved > 0)
          Text(
            '${achieved == 1 ? 'Parabéns pela conquista!' : 'Parabéns pelas conquistas!'}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          )
        else
          Text(
            'Continue avançando!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
        if (remaining > 0)
          Text(
            '$remaining ${remaining == 1 ? 'restante' : 'restantes'}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
      ],
    );
  }
}

/// Card compacto para exibir um único marco alcançado
class MilestoneAchievedCard extends StatelessWidget {
  final MilestoneEntity milestone;
  final VoidCallback? onDismiss;

  const MilestoneAchievedCard({
    super.key,
    required this.milestone,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.shade300,
              Colors.orange.shade500,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    milestone.icon,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Marco Alcançado!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          milestone.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDismiss != null)
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: onDismiss,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  milestone.celebrationMessage,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Made with Bob
