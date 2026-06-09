import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

/// Widget de timeline horizontal interativa
///
/// Mostra as 9 etapas da reforma em formato visual:
/// - Etapas concluídas ()
/// - Etapa atual ()
/// - Etapas futuras ()
/// - Etapas pausadas (⏸)
///
/// Usuário pode tocar em qualquer etapa para ver detalhes
class HorizontalTimelineWidget extends StatelessWidget {
  final List<TimelinePhase> phases;
  final Function(String phaseId) onPhaseTap;

  const HorizontalTimelineWidget({
    super.key,
    required this.phases,
    required this.onPhaseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Linha do Tempo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _buildTimelineItems(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTimelineItems(BuildContext context) {
    final items = <Widget>[];

    for (int i = 0; i < phases.length; i++) {
      final phase = phases[i];

      // Adiciona o item da fase
      items.add(
        _TimelineItem(
          phase: phase,
          onTap: () => onPhaseTap(phase.id),
        ),
      );

      // Adiciona conector entre fases (exceto na última)
      if (i < phases.length - 1) {
        items.add(_TimelineConnector(
          isCompleted: phase.status == PhaseStatus.completed,
        ));
      }
    }

    return items;
  }
}

/// Item individual da timeline
class _TimelineItem extends StatelessWidget {
  final TimelinePhase phase;
  final VoidCallback onTap;

  const _TimelineItem({
    required this.phase,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final icon = _getIcon();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: [
            // Ícone da fase
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Nome da fase
            Text(
              phase.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: phase.status == PhaseStatus.active
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
            ),
            // Progresso (se ativa)
            if (phase.status == PhaseStatus.active) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${phase.progress}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getColor() {
    switch (phase.status) {
      case PhaseStatus.completed:
        return AppColors.success;
      case PhaseStatus.active:
        return AppColors.primary;
      case PhaseStatus.paused:
        return AppColors.warning;
      case PhaseStatus.pending:
        return Colors.grey;
      case PhaseStatus.completedWithoutRecord:
        return AppColors.success.withOpacity(0.5);
    }
  }

  IconData _getIcon() {
    switch (phase.status) {
      case PhaseStatus.completed:
        return Icons.check_circle;
      case PhaseStatus.active:
        return Icons.play_circle_filled;
      case PhaseStatus.paused:
        return Icons.pause_circle_filled;
      case PhaseStatus.pending:
        return Icons.circle_outlined;
      case PhaseStatus.completedWithoutRecord:
        return Icons.check_circle_outline;
    }
  }
}

/// Conector entre fases
class _TimelineConnector extends StatelessWidget {
  final bool isCompleted;

  const _TimelineConnector({
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 60),
      color: isCompleted ? AppColors.success : Colors.grey[300],
    );
  }
}

/// Timeline vertical compacta (alternativa)
class VerticalTimelineWidget extends StatelessWidget {
  final List<TimelinePhase> phases;
  final Function(String phaseId) onPhaseTap;

  const VerticalTimelineWidget({
    super.key,
    required this.phases,
    required this.onPhaseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etapas da Reforma',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...phases.map((phase) => _VerticalTimelineItem(
              phase: phase,
              onTap: () => onPhaseTap(phase.id),
            )),
      ],
    );
  }
}

/// Item vertical da timeline
class _VerticalTimelineItem extends StatelessWidget {
  final TimelinePhase phase;
  final VoidCallback onTap;

  const _VerticalTimelineItem({
    required this.phase,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final icon = _getIcon();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            // Ícone
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 16,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Nome e progresso
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
                  if (phase.status == PhaseStatus.active) ...[
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: phase.progress / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ],
                ],
              ),
            ),
            // Status
            if (phase.status == PhaseStatus.active)
              Text(
                '${phase.progress}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getColor() {
    switch (phase.status) {
      case PhaseStatus.completed:
        return AppColors.success;
      case PhaseStatus.active:
        return AppColors.primary;
      case PhaseStatus.paused:
        return AppColors.warning;
      case PhaseStatus.pending:
        return Colors.grey;
      case PhaseStatus.completedWithoutRecord:
        return AppColors.success.withOpacity(0.5);
    }
  }

  IconData _getIcon() {
    switch (phase.status) {
      case PhaseStatus.completed:
        return Icons.check_circle;
      case PhaseStatus.active:
        return Icons.play_circle_filled;
      case PhaseStatus.paused:
        return Icons.pause_circle_filled;
      case PhaseStatus.pending:
        return Icons.circle_outlined;
      case PhaseStatus.completedWithoutRecord:
        return Icons.check_circle_outline;
    }
  }
}

/// Timeline circular (alternativa visual)
class CircularTimelineWidget extends StatelessWidget {
  final List<TimelinePhase> phases;
  final Function(String phaseId) onPhaseTap;

  const CircularTimelineWidget({
    super.key,
    required this.phases,
    required this.onPhaseTap,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount =
        phases.where((p) => p.status == PhaseStatus.completed).length;
    final totalCount = phases.length;
    final percentage = (completedCount / totalCount * 100).round();

    return Column(
      children: [
        // Círculo de progresso
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Círculo de fundo
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: completedCount / totalCount,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              // Texto central
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$percentage%',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  Text(
                    'Concluído',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$completedCount de $totalCount etapas',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Lista de fases
        ...phases.map((phase) => _CircularTimelineItem(
              phase: phase,
              onTap: () => onPhaseTap(phase.id),
            )),
      ],
    );
  }
}

/// Item da timeline circular
class _CircularTimelineItem extends StatelessWidget {
  final TimelinePhase phase;
  final VoidCallback onTap;

  const _CircularTimelineItem({
    required this.phase,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final icon = _getIcon();

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(phase.name),
      trailing: phase.status == PhaseStatus.active
          ? Text(
              '${phase.progress}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      onTap: onTap,
    );
  }

  Color _getColor() {
    switch (phase.status) {
      case PhaseStatus.completed:
        return AppColors.success;
      case PhaseStatus.active:
        return AppColors.primary;
      case PhaseStatus.paused:
        return AppColors.warning;
      case PhaseStatus.pending:
        return Colors.grey;
      case PhaseStatus.completedWithoutRecord:
        return AppColors.success.withOpacity(0.5);
    }
  }

  IconData _getIcon() {
    switch (phase.status) {
      case PhaseStatus.completed:
        return Icons.check_circle;
      case PhaseStatus.active:
        return Icons.play_circle_filled;
      case PhaseStatus.paused:
        return Icons.pause_circle_filled;
      case PhaseStatus.pending:
        return Icons.circle_outlined;
      case PhaseStatus.completedWithoutRecord:
        return Icons.check_circle_outline;
    }
  }
}

/// Modelo de fase para a timeline
class TimelinePhase {
  final String id;
  final String name;
  final PhaseStatus status;
  final int progress; // 0-100

  const TimelinePhase({
    required this.id,
    required this.name,
    required this.status,
    required this.progress,
  });
}

/// Status da fase
enum PhaseStatus {
  completed, // Concluída
  active, // Ativa (em andamento)
  paused, // Pausada
  pending, // Pendente (futura)
  completedWithoutRecord, // Concluída sem registro
}

// Made with Bob
