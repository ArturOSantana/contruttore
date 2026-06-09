import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../domain/entities/next_action_entity.dart';
import '../cubit/reform_map_cubit.dart';
import '../cubit/reform_map_state.dart';
import '../widgets/current_phase_widget.dart';
import '../widgets/health_score_widget.dart';
import '../widgets/milestones_card.dart';
import '../widgets/move_in_distance_card.dart';
import '../widgets/move_in_mode_card.dart';
import '../widgets/next_action_widget.dart';
import '../widgets/next_phase_preparation_card.dart';
import '../widgets/pending_decisions_card.dart';
import '../widgets/phase_overview_widget.dart';
import '../widgets/problems_list_widget.dart';
import '../widgets/reform_calendar_card.dart';
import '../widgets/reform_week_card.dart';
import '../widgets/upcoming_purchases_card.dart';

/// Tela principal do Mapa da Reforma
///
/// Esta é a tela central do aplicativo que mostra:
/// - Onde o usuário está na reforma
/// - Saúde geral da reforma
/// - Próxima ação recomendada
/// - Visão geral de todas as etapas
/// - Problemas ativos
class ReformMapPage extends StatefulWidget {
  final String projectId;

  const ReformMapPage({
    super.key,
    required this.projectId,
  });

  @override
  State<ReformMapPage> createState() => _ReformMapPageState();
}

class _ReformMapPageState extends State<ReformMapPage> {
  @override
  void initState() {
    super.initState();
    // Carrega o mapa quando a tela abre
    context.read<ReformMapCubit>().loadReformMap(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa da Reforma'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push(
                RouteNames.projectSettings,
                extra: widget.projectId,
              );
            },
            tooltip: 'Configurações do Projeto',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ReformMapCubit>().refreshAll(widget.projectId);
            },
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: BlocBuilder<ReformMapCubit, ReformMapState>(
        builder: (context, state) {
          if (state is ReformMapLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ReformMapError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar o mapa',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<ReformMapCubit>().loadReformMap(
                            widget.projectId,
                          );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (state is ReformMapLoaded || state is ReformMapUpdating) {
            final reformMap = state is ReformMapLoaded
                ? state.reformMap
                : (state as ReformMapUpdating).currentMap;

            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    await context
                        .read<ReformMapCubit>()
                        .refreshAll(widget.projectId);
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Distância até a Mudança (NOVO - Sprint 1.1)
                      if (reformMap.moveInDistance != null)
                        MoveInDistanceCard(
                          distance: reformMap.moveInDistance!,
                        ),
                      if (reformMap.moveInDistance != null)
                        const SizedBox(height: 16),

                      // Decisões Pendentes (NOVO - Sprint 1.2)
                      if (reformMap.pendingDecisions.isNotEmpty)
                        PendingDecisionsCard(
                          decisions: reformMap.pendingDecisions,
                        ),
                      if (reformMap.pendingDecisions.isNotEmpty)
                        const SizedBox(height: 16),

                      // Próximas Compras (NOVO - Sprint 2.1)
                      if (reformMap.upcomingPurchases.isNotEmpty)
                        UpcomingPurchasesCard(
                          purchases: reformMap.upcomingPurchases,
                        ),
                      if (reformMap.upcomingPurchases.isNotEmpty)
                        const SizedBox(height: 16),

                      // Preparação da Próxima Etapa (NOVO - Sprint 2.2)
                      if (reformMap.nextPhasePreparation != null)
                        NextPhasePreparationCard(
                          preparation: reformMap.nextPhasePreparation!,
                        ),
                      if (reformMap.nextPhasePreparation != null)
                        const SizedBox(height: 16),

                      // Marcos da Reforma (NOVO - Sprint 2.3)
                      if (reformMap.milestones.isNotEmpty)
                        MilestonesCard(
                          milestones: reformMap.milestones,
                        ),
                      if (reformMap.milestones.isNotEmpty)
                        const SizedBox(height: 16),

                      // Calendário Inteligente (NOVO - Sprint 3.1)
                      if (reformMap.calendar != null)
                        ReformCalendarCard(
                          calendar: reformMap.calendar!,
                          projectId: widget.projectId,
                        ),
                      if (reformMap.calendar != null)
                        const SizedBox(height: 16),

                      // Semana da Reforma (NOVO - Sprint 3.2)
                      if (reformMap.week != null)
                        ReformWeekCard(
                          week: reformMap.week!,
                        ),
                      if (reformMap.week != null) const SizedBox(height: 16),

                      // Modo Mudança (NOVO - Sprint 4.1)
                      if (reformMap.moveInMode != null &&
                          reformMap.moveInMode!.isActive)
                        MoveInModeCard(
                          moveInMode: reformMap.moveInMode!,
                          onTaskTap: () {
                            // TODO: Navegar para checklist completo
                          },
                        ),
                      if (reformMap.moveInMode != null &&
                          reformMap.moveInMode!.isActive)
                        const SizedBox(height: 16),

                      // Saúde da Reforma
                      HealthScoreWidget(
                        health: reformMap.health,
                        onTap: () {
                          // Navegar para detalhes da saúde
                          _showHealthDetails(context, reformMap.health);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Próxima Ação Recomendada
                      if (reformMap.nextAction != null)
                        NextActionWidget(
                          nextAction: reformMap.nextAction!,
                          onActionTap: () {
                            // Executar a ação recomendada
                            _executeAction(context, reformMap.nextAction!);
                          },
                        ),
                      const SizedBox(height: 16),

                      // Etapa Atual
                      CurrentPhaseWidget(
                        reformMap: reformMap,
                        onPhaseTap: (phaseId) {
                          // Navegar para detalhes da fase
                          _navigateToPhaseDetails(context, phaseId);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Visão Geral das Etapas
                      PhaseOverviewWidget(
                        phases: reformMap.phases,
                        onPhaseTap: (phaseId) {
                          _navigateToPhaseDetails(context, phaseId);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Problemas Ativos
                      if (reformMap.problems.isNotEmpty)
                        ProblemsListWidget(
                          problems: reformMap.problems,
                          onProblemTap: (problemId) {
                            _navigateToProblemDetails(context, problemId);
                          },
                          onAddProblem: () {
                            _showAddProblemDialog(context);
                          },
                        ),

                      const SizedBox(height: 80), // Espaço para o FAB
                    ],
                  ),
                ),

                // Loading overlay quando está atualizando
                if (state is ReformMapUpdating)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          }

          // Estado inicial
          return const Center(
            child: Text('Carregando...'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProblemDialog(context),
        icon: const Icon(Icons.warning_amber),
        label: const Text('Reportar Problema'),
      ),
    );
  }

  void _showHealthDetails(BuildContext context, dynamic health) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalhes da Saúde',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aqui você verá os detalhes de cada fator que afeta a saúde da sua reforma.',
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    );
  }

  void _executeAction(BuildContext context, NextActionEntity nextAction) {
    // Navegação inteligente baseada na categoria da ação
    switch (nextAction.category) {
      case ActionCategory.financial:
        // Navegar para adicionar despesa ou ver financeiro
        if (nextAction.type == ActionType.payment) {
          context
              .push('${RouteNames.payments}?phase=${nextAction.phaseId ?? ''}');
        } else {
          context.push(
              '${RouteNames.expenseCreate}?phase=${nextAction.phaseId ?? ''}');
        }
        break;

      case ActionCategory.shopping:
        // Navegar para adicionar item de compra
        if (nextAction.metadata?['itemId'] != null) {
          // Editar item existente
          context.push(
              '${RouteNames.shoppingEdit.replaceAll(':id', nextAction.metadata!['itemId'])}');
        } else {
          // Adicionar novo item
          context.push(
              '${RouteNames.shoppingCreate}?phase=${nextAction.phaseId ?? ''}');
        }
        break;

      case ActionCategory.supplier:
        // Navegar para adicionar fornecedor ou orçamento
        if (nextAction.type == ActionType.hire) {
          context.push(
              '${RouteNames.supplierCreate}?phase=${nextAction.phaseId ?? ''}');
        } else {
          context.push(
              '${RouteNames.suppliers}?phase=${nextAction.phaseId ?? ''}');
        }
        break;

      case ActionCategory.document:
        // Navegar para adicionar documento
        context.push(
            '${RouteNames.documentUpload}?phase=${nextAction.phaseId ?? ''}');
        break;

      case ActionCategory.phase:
        // Navegar para detalhes da fase
        if (nextAction.phaseId != null) {
          _navigateToPhaseDetails(context, nextAction.phaseId!);
        }
        break;

      case ActionCategory.wishlist:
        // Navegar para lista de desejos
        context.push(
            '${RouteNames.wishlistCreate}?phase=${nextAction.phaseId ?? ''}');
        break;

      case ActionCategory.general:
      default:
        // Para ações gerais, mostrar diálogo com detalhes
        _showActionDetailsDialog(context, nextAction);
        break;
    }
  }

  void _showActionDetailsDialog(BuildContext context, NextActionEntity action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(action.description),
            const SizedBox(height: 16),
            if (action.reason.isNotEmpty) ...[
              Text(
                'Por quê?',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(action.reason),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          if (action.phaseId != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToPhaseDetails(context, action.phaseId!);
              },
              child: const Text('Ver Etapa'),
            ),
        ],
      ),
    );
  }

  void _navigateToPhaseDetails(BuildContext context, String phaseId) {
    // Navega para a lista de fases onde o usuário pode selecionar a fase desejada
    context.push(RouteNames.phases);
  }

  void _navigateToProblemDetails(BuildContext context, String problemId) {
    // Aqui você implementaria a navegação para os detalhes do problema
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrindo problema: $problemId'),
      ),
    );
  }

  void _showAddProblemDialog(BuildContext context) {
    // Navegar para a página de reportar problema
    context.push(
      '${RouteNames.reportProblem}?projectId=${widget.projectId}',
    );
  }
}

// Made with Bob
