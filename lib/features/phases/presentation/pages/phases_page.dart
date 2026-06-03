import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/progress_bar.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../cubit/phases_cubit.dart';
import '../cubit/phases_state.dart';

/// Página de Fases - Lista das 12 fases do projeto
class PhasesPage extends StatelessWidget {
  final String projectId;

  const PhasesPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fases do Projeto'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: BlocBuilder<PhasesCubit, PhasesState>(
        builder: (context, state) {
          if (state is PhasesLoading) {
            return const LoadingWidget();
          }

          if (state is PhasesError) {
            return ErrorWidgetCustom(
              message: state.message,
              onRetry: () => context.read<PhasesCubit>().loadPhases(projectId),
            );
          }

          if (state is PhasesLoaded) {
            if (state.phases.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.construction,
                title: 'Nenhuma fase encontrada',
                message: 'As fases do projeto serão criadas automaticamente.',
                actionLabel: 'Atualizar',
                onAction: () =>
                    context.read<PhasesCubit>().loadPhases(projectId),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PhasesCubit>().loadPhases(projectId);
              },
              child: ListView.builder(
                padding: EdgeInsets.all(AppSpacing.md),
                itemCount: state.phases.length,
                itemBuilder: (context, index) {
                  final phase = state.phases[index];
                  return _PhaseCard(phase: phase, projectId: projectId);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Card de fase individual
class _PhaseCard extends StatelessWidget {
  final PhaseEntity phase;
  final String projectId;

  const _PhaseCard({required this.phase, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      elevation: AppSpacing.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: InkWell(
        onTap: () => context.push(
          RouteNames.phaseDetail.replaceAll(':id', phase.id),
          extra: {'projectId': projectId, 'phase': phase},
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho: número, nome e status
              Row(
                children: [
                  // Número da fase
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getPhaseColor(phase.number).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Center(
                      child: Text(
                        '${phase.number}',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: _getPhaseColor(phase.number),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  // Nome da fase
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phase.name,
                          style: AppTextStyles.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          '${phase.estimatedDurationDays} dias estimados',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  // Status badge
                  StatusBadge.phaseStatus(phase.status.name),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              // Descrição
              Text(
                phase.description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppSpacing.sm),
              // Progresso de subtarefas
              if (phase.subtasks.isNotEmpty) ...[
                SubtaskProgress(
                  completed: phase.completedSubtasksCount,
                  total: phase.subtasks.length,
                  showLabel: true,
                ),
                SizedBox(height: AppSpacing.xs),
              ],
              // Datas (se houver)
              if (phase.startDate != null || phase.endDate != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: AppSpacing.xxs),
                    Text(
                      _formatDateRange(phase.startDate, phase.endDate),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              // Aviso se não pode completar
              if (phase.status == PhaseStatus.active && !phase.canComplete) ...[
                SizedBox(height: AppSpacing.xs),
                Container(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      SizedBox(width: AppSpacing.xxs),
                      Expanded(
                        child: Text(
                          'Complete todas as tarefas obrigatórias para finalizar',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getPhaseColor(int number) {
    // Cores diferentes para cada grupo de fases
    if (number <= 5) {
      return AppColors.phaseBlue; // Jornada do comprador
    } else if (number <= 8) {
      return AppColors.phaseGreen; // Preparação e planejamento
    } else if (number <= 11) {
      return AppColors.phaseOrange; // Execução da reforma
    } else {
      return AppColors.phasePurple; // Finalização
    }
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return '';

    final dateFormat = 'dd/MM/yyyy';

    if (start != null && end != null) {
      return '${_formatDate(start)} - ${_formatDate(end)}';
    } else if (start != null) {
      return 'Início: ${_formatDate(start)}';
    } else {
      return 'Fim: ${_formatDate(end!)}';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// Made with Bob
