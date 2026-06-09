import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/phase_entity.dart';
import '../cubit/phases_cubit.dart';
import '../cubit/phases_state.dart';
import 'phase_detail_page.dart';

class PhasesPage extends StatefulWidget {
  final String projectId;

  const PhasesPage({super.key, required this.projectId});

  @override
  State<PhasesPage> createState() => _PhasesPageState();
}

class _PhasesPageState extends State<PhasesPage> {
  @override
  void initState() {
    super.initState();
    // Carrega as fases ao iniciar
    context.read<PhasesCubit>().loadPhases(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fases da Reforma'),
        elevation: 0,
      ),
      body: BlocBuilder<PhasesCubit, PhasesState>(
        builder: (context, state) {
          if (state is PhasesLoading) {
            return const LoadingWidget(type: LoadingType.list);
          }

          if (state is PhasesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PhasesCubit>().loadPhases(widget.projectId);
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (state is PhasesLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PhasesCubit>().loadPhases(widget.projectId);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.phases.length,
                itemBuilder: (context, index) {
                  final phase = state.phases[index];
                  final isCurrentPhase = phase.id == state.currentPhase?.id;

                  return _PhaseCard(
                    phase: phase,
                    isCurrentPhase: isCurrentPhase,
                    onTap: () {
                      // Navegar para detalhes da fase
                      final cubit = context.read<PhasesCubit>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhaseDetailPage(
                            phase: phase,
                            onToggleSubtask: (phaseId, subtask) {
                              cubit.toggleSubtask(phaseId, subtask);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          return const Center(
            child: Text('Carregue as fases do projeto'),
          );
        },
      ),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  final PhaseEntity phase;
  final bool isCurrentPhase;
  final VoidCallback onTap;

  const _PhaseCard({
    required this.phase,
    required this.isCurrentPhase,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isCurrentPhase ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentPhase
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com número e status
              Row(
                children: [
                  // Número da fase
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getPhaseColor(phase.status),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${phase.number}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nome e descrição
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phase.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          phase.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Badge de status
                  _StatusBadge(status: phase.status),
                ],
              ),

              const SizedBox(height: 16),

              // Barra de progresso
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progresso',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${phase.completedSubtasksCount}/${phase.subtasks.length} tarefas',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: phase.progressPercentage / 100,
                      minHeight: 8,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getPhaseColor(phase.status),
                      ),
                    ),
                  ),
                ],
              ),

              // Informações adicionais
              if (phase.startDate != null || phase.estimatedDurationDays > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      if (phase.startDate != null) ...[
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(phase.startDate!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (phase.estimatedDurationDays > 0) ...[
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${phase.estimatedDurationDays} dias',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              // Badge "Fase Atual"
              if (isCurrentPhase)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_circle_filled,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Fase Atual',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPhaseColor(PhaseStatus status) {
    switch (status) {
      case PhaseStatus.locked:
        return AppColors.phaseNotStarted;
      case PhaseStatus.active:
        return AppColors.phaseInProgress;
      case PhaseStatus.done:
      case PhaseStatus.doneNoRecord:
        return AppColors.phaseCompleted;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final PhaseStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String label;
    Color color;
    IconData icon;

    switch (status) {
      case PhaseStatus.locked:
        label = 'Bloqueada';
        color = AppColors.phaseNotStarted;
        icon = Icons.lock;
        break;
      case PhaseStatus.active:
        label = 'Em Andamento';
        color = AppColors.phaseInProgress;
        icon = Icons.play_circle_filled;
        break;
      case PhaseStatus.done:
        label = 'Concluída';
        color = AppColors.phaseCompleted;
        icon = Icons.check_circle;
        break;
      case PhaseStatus.doneNoRecord:
        label = 'Concluída';
        color = AppColors.phaseCompleted;
        icon = Icons.check_circle_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Made with Bob
