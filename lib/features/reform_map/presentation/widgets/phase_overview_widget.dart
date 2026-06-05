import 'package:flutter/material.dart';
import '../../../projects/domain/entities/phase_entity.dart';

/// Widget que mostra visão geral de todas as etapas
class PhaseOverviewWidget extends StatelessWidget {
  final List<PhaseEntity> phases;
  final Function(String) onPhaseTap;

  const PhaseOverviewWidget({
    super.key,
    required this.phases,
    required this.onPhaseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visão Geral das Etapas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...phases.map((phase) => _buildPhaseItem(context, phase)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseItem(BuildContext context, PhaseEntity phase) {
    return InkWell(
      onTap: () => onPhaseTap(phase.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _buildStatusIcon(phase.status),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phase.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: phase.status == PhaseStatus.active
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                  ),
                  if (phase.status == PhaseStatus.active)
                    Text(
                      'Em andamento',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue,
                          ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(PhaseStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case PhaseStatus.done:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case PhaseStatus.doneNoRecord:
        icon = Icons.check_circle_outline;
        color = Colors.green.withOpacity(0.6);
        break;
      case PhaseStatus.active:
        icon = Icons.radio_button_checked;
        color = Colors.blue;
        break;
      case PhaseStatus.locked:
        icon = Icons.radio_button_unchecked;
        color = Colors.grey;
        break;
    }

    return Icon(icon, color: color, size: 24);
  }
}

// Made with Bob
