import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../injection_container.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../../domain/services/phase_ordering_service.dart';
import '../../../projects/presentation/cubit/phases_cubit.dart';
import '../../../projects/presentation/cubit/phases_state.dart';
import '../widgets/next_action_hero_card.dart';
import '../widgets/current_phase_card_improved.dart';
import '../widgets/phases_sections.dart';

/// Página de Fases MELHORADA
///
/// Nova estrutura que resolve o problema:
/// "Não sei por onde começar quando abro o mapa"
///
/// Hierarquia visual:
/// 1. Próxima Ação (HERO) - O que fazer AGORA
/// 2. Fase Atual (Destaque) - Onde você está
/// 3. Fases Concluídas (Sucesso) - O que já foi feito
/// 4. Próximas Fases (Futuro) - O que vem pela frente
class PhasesPageImproved extends StatefulWidget {
  final String projectId;

  const PhasesPageImproved({super.key, required this.projectId});

  @override
  State<PhasesPageImproved> createState() => _PhasesPageImprovedState();
}

class _PhasesPageImprovedState extends State<PhasesPageImproved> {
  late final PhaseOrderingService _orderingService;

  @override
  void initState() {
    super.initState();
    _orderingService = getIt<PhaseOrderingService>();

    // Carregar fases
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PhasesCubit>().loadPhases(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mapa da Reforma'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showMapInfo(context),
            tooltip: 'Como funciona',
          ),
        ],
      ),
      body: BlocBuilder<PhasesCubit, PhasesState>(
        builder: (context, state) {
          if (state is PhasesLoading) {
            return const LoadingWidget();
          }

          if (state is PhasesError) {
            return ErrorWidgetCustom(
              message: state.message,
              onRetry: () =>
                  context.read<PhasesCubit>().loadPhases(widget.projectId),
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
                    context.read<PhasesCubit>().loadPhases(widget.projectId),
              );
            }

            // Organizar fases usando o serviço inteligente
            final groups =
                _orderingService.organizePhasesIntoGroups(state.phases);
            final currentPhase = groups['current'] as PhaseEntity?;
            final completedPhases = groups['completed'] as List<PhaseEntity>;
            final upcomingPhases = groups['upcoming'] as List<PhaseEntity>;

            // Calcular próxima ação
            final nextAction =
                _orderingService.calculateNextAction(state.phases);

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PhasesCubit>().loadPhases(widget.projectId);
              },
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.md),
                children: [
                  // 1. PRÓXIMA AÇÃO (HERO)
                  if (nextAction != null && currentPhase != null)
                    NextActionHeroCard(
                      actionTitle: nextAction['title'] as String,
                      phaseName: nextAction['phaseName'] as String,
                      phaseNumber: nextAction['phaseNumber'] as int,
                      actionDescription: nextAction['description'] as String?,
                      actionIcon: _getIconData(
                        _orderingService
                            .getActionIcon(nextAction['title'] as String),
                      ),
                      onActionTap: () => _handleActionTap(
                        context,
                        currentPhase,
                        nextAction['subtaskId'] as String,
                      ),
                      onDetailsTap: () => _navigateToPhaseDetail(
                        context,
                        currentPhase,
                      ),
                    ),

                  // 2. FASE ATUAL (DESTAQUE)
                  if (currentPhase != null)
                    CurrentPhaseCardImproved(
                      phase: currentPhase,
                      completedTasks:
                          _orderingService.countCompletedTasks(currentPhase),
                      totalTasks:
                          _orderingService.countTotalTasks(currentPhase),
                      onTap: () =>
                          _navigateToPhaseDetail(context, currentPhase),
                    ),

                  // 3. FASES CONCLUÍDAS (SUCESSO)
                  if (completedPhases.isNotEmpty)
                    CompletedPhasesSection(
                      phases: completedPhases,
                      onPhaseTap: (phase) =>
                          _navigateToPhaseDetail(context, phase),
                    ),

                  // 4. PRÓXIMAS FASES (FUTURO)
                  if (upcomingPhases.isNotEmpty)
                    UpcomingPhasesSection(
                      phases: upcomingPhases,
                      onPhaseTap: (phase) =>
                          _navigateToPhaseDetail(context, phase),
                    ),

                  // Espaço extra no final
                  SizedBox(height: AppSpacing.xxl),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Navega para detalhes da fase
  void _navigateToPhaseDetail(BuildContext context, PhaseEntity phase) {
    context.push(
      RouteNames.phaseDetail.replaceAll(':id', phase.id),
      extra: {'projectId': widget.projectId, 'phase': phase},
    );
  }

  /// Lida com o tap na ação (marca subtarefa como concluída ou abre detalhes)
  void _handleActionTap(
    BuildContext context,
    PhaseEntity phase,
    String subtaskId,
  ) {
    // Por enquanto, navega para detalhes da fase
    // No futuro, pode abrir um dialog para marcar a tarefa como concluída
    _navigateToPhaseDetail(context, phase);
  }

  /// Converte string de ícone para IconData
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'attach_money':
        return Icons.attach_money;
      case 'architecture':
        return Icons.architecture;
      case 'person':
        return Icons.person;
      case 'apartment':
        return Icons.apartment;
      case 'elevator':
        return Icons.elevator;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'delete_sweep':
        return Icons.delete_sweep;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'plumbing':
        return Icons.plumbing;
      case 'layers':
        return Icons.layers;
      case 'format_paint':
        return Icons.format_paint;
      case 'chair':
        return Icons.chair;
      case 'cleaning_services':
        return Icons.cleaning_services;
      default:
        return Icons.task_alt;
    }
  }

  /// Mostra informações sobre como o mapa funciona
  void _showMapInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Como funciona o Mapa'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoItem(
                icon: Icons.bolt,
                color: const Color(0xFFFF6B35),
                title: 'Próxima Ação',
                description:
                    'O que você deve fazer agora para avançar na reforma.',
              ),
              SizedBox(height: AppSpacing.md),
              _buildInfoItem(
                icon: Icons.location_on,
                color: AppColors.primary,
                title: 'Você Está Aqui',
                description:
                    'A fase atual da sua reforma com progresso detalhado.',
              ),
              SizedBox(height: AppSpacing.md),
              _buildInfoItem(
                icon: Icons.check_circle,
                color: AppColors.success,
                title: 'Fases Concluídas',
                description:
                    'Tudo que você já completou. Parabéns pelo progresso!',
              ),
              SizedBox(height: AppSpacing.md),
              _buildInfoItem(
                icon: Icons.lock_outline,
                color: AppColors.textSecondary,
                title: 'Próximas Fases',
                description:
                    'O que vem pela frente. Serão desbloqueadas conforme você avança.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: AppSpacing.xxs),
              Text(
                description,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Made with Bob
