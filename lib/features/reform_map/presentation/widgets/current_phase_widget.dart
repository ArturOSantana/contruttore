import 'package:flutter/material.dart';
import '../../domain/entities/reform_map_entity.dart';
import '../../../projects/domain/entities/phase_entity.dart';

/// Widget que mostra a etapa atual da reforma
class CurrentPhaseWidget extends StatelessWidget {
  final ReformMapEntity reformMap;
  final Function(String) onPhaseTap;

  const CurrentPhaseWidget({
    super.key,
    required this.reformMap,
    required this.onPhaseTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentPhase = _getCurrentPhase();

    if (currentPhase == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Você está em:',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Text(
              currentPhase.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: reformMap.progress.completedPercentage / 100,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '${reformMap.progress.completedPercentage.toStringAsFixed(0)}% concluído',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  PhaseEntity? _getCurrentPhase() {
    try {
      return reformMap.phases.firstWhere(
        (phase) => phase.status == PhaseStatus.active,
      );
    } catch (e) {
      return null;
    }
  }
}

// Made with Bob
