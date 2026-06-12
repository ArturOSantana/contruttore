import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../domain/entities/next_action_entity.dart';
import '../../domain/entities/next_phase_preparation_entity.dart';
import '../cubit/reform_map_cubit.dart';
import '../cubit/reform_map_state.dart';
import '../widgets/current_phase_widget.dart';
import '../widgets/health_score_widget.dart';
import '../widgets/move_in_distance_card.dart';
import '../widgets/move_in_mode_card.dart';
import '../widgets/next_action_widget.dart';
import '../widgets/next_phase_preparation_card.dart';
import '../widgets/pending_decisions_card.dart';
import '../widgets/phase_overview_widget.dart';
import '../widgets/phase_progress_card.dart';
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
                      // ═══════════════════════════════════════════════════
                      // 🎯 NÍVEL 1: HERO - O QUE FAZER AGORA (Laranja)
                      // ═══════════════════════════════════════════════════

                      // Próxima Ação Recomendada (MAIS IMPORTANTE)
                      if (reformMap.nextAction != null)
                        NextActionWidget(
                          nextAction: reformMap.nextAction!,
                          onActionTap: () {
                            _executeAction(context, reformMap.nextAction!);
                          },
                        ),
                      if (reformMap.nextAction != null)
                        const SizedBox(height: 16),

                      // Distância até a Mudança (MOTIVADOR)
                      if (reformMap.moveInDistance != null)
                        MoveInDistanceCard(
                          distance: reformMap.moveInDistance!,
                        ),
                      if (reformMap.moveInDistance != null)
                        const SizedBox(height: 24),

                      // ═══════════════════════════════════════════════════
                      // 📍 NÍVEL 2: ATUAL - ONDE VOCÊ ESTÁ (Azul)
                      // ═══════════════════════════════════════════════════

                      // Etapa Atual
                      CurrentPhaseWidget(
                        reformMap: reformMap,
                        onPhaseTap: (phaseId) {
                          _navigateToPhaseDetails(context, phaseId);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Saúde da Reforma
                      HealthScoreWidget(
                        health: reformMap.health,
                        onTap: () {
                          _showHealthDetails(context, reformMap.health);
                        },
                      ),
                      const SizedBox(height: 24),

                      // ═══════════════════════════════════════════════════
                      // ⚠️ NÍVEL 3: URGENTE - REQUER ATENÇÃO (Vermelho/Laranja)
                      // ═══════════════════════════════════════════════════

                      // Decisões Pendentes
                      if (reformMap.pendingDecisions.isNotEmpty)
                        PendingDecisionsCard(
                          decisions: reformMap.pendingDecisions,
                        ),
                      if (reformMap.pendingDecisions.isNotEmpty)
                        const SizedBox(height: 16),

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
                      if (reformMap.problems.isNotEmpty)
                        const SizedBox(height: 24),

                      // ═══════════════════════════════════════════════════
                      // 📦 NÍVEL 4: PREPARAÇÃO - PRÓXIMOS PASSOS (Roxo)
                      // ═══════════════════════════════════════════════════

                      // Próximas Compras
                      if (reformMap.upcomingPurchases.isNotEmpty)
                        UpcomingPurchasesCard(
                          purchases: reformMap.upcomingPurchases,
                        ),
                      if (reformMap.upcomingPurchases.isNotEmpty)
                        const SizedBox(height: 16),

                      // Progresso da Fase Atual (NOVO - Usa dados reais!)
                      if (reformMap.currentPhase != null &&
                          reformMap.phasesAnalysis
                              .containsKey(reformMap.currentPhase!.id))
                        PhaseProgressCard(
                          phase: reformMap.currentPhase!,
                          analysis: reformMap
                              .phasesAnalysis[reformMap.currentPhase!.id]!,
                          onTap: () {
                            _navigateToPhaseDetails(
                              context,
                              reformMap.currentPhase!.id,
                            );
                          },
                        ),
                      if (reformMap.currentPhase != null &&
                          reformMap.phasesAnalysis
                              .containsKey(reformMap.currentPhase!.id))
                        const SizedBox(height: 24),

                      // ═══════════════════════════════════════════════════
                      // 🎯 NÍVEL 5: PROGRESSO - CONQUISTAS (Verde)
                      // ═══════════════════════════════════════════════════

                      // Modo Mudança (quando ativo) - Agora com dados reais do Firestore
                      if (reformMap.moveInDistance != null &&
                          reformMap.moveInDistance!.daysRemaining <= 90)
                        MoveInModeCard(
                          daysUntilMoveIn:
                              reformMap.moveInDistance!.daysRemaining,
                          projectId: widget.projectId,
                        ),
                      if (reformMap.moveInMode != null &&
                          reformMap.moveInMode!.isActive)
                        const SizedBox(height: 24),

                      // ═══════════════════════════════════════════════════
                      // 📅 NÍVEL 6: PLANEJAMENTO - CALENDÁRIO (Azul claro)
                      // ═══════════════════════════════════════════════════

                      // Semana da Reforma
                      if (reformMap.week != null)
                        ReformWeekCard(
                          week: reformMap.week!,
                        ),
                      if (reformMap.week != null) const SizedBox(height: 16),

                      // Calendário Inteligente
                      if (reformMap.calendar != null)
                        ReformCalendarCard(
                          calendar: reformMap.calendar!,
                          projectId: widget.projectId,
                        ),
                      if (reformMap.calendar != null)
                        const SizedBox(height: 24),

                      // ═══════════════════════════════════════════════════
                      // 📊 NÍVEL 7: VISÃO GERAL - TODAS AS FASES (Cinza)
                      // ═══════════════════════════════════════════════════

                      // Visão Geral das Etapas (sempre mostra, mesmo vazio)
                      PhaseOverviewWidget(
                        phases: reformMap.phases,
                        onPhaseTap: (phaseId) {
                          _navigateToPhaseDetails(context, phaseId);
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

  void _showPreparationChecklist(
    BuildContext context,
    NextPhasePreparationEntity preparation,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade400,
                            Colors.deepOrange.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.rocket_launch,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Checklist de Preparação',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            preparation.nextPhaseName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Checklist
              Expanded(
                child: preparation.checklist.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: Colors.green[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tudo pronto!',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Você está preparado para começar',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: preparation.checklist.length,
                        itemBuilder: (context, index) {
                          final item = preparation.checklist[index];
                          return _buildChecklistItem(item);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem(PreparationItemEntity item) {
    IconData categoryIcon;
    Color categoryColor;

    switch (item.category) {
      case PreparationCategory.professional:
        categoryIcon = Icons.person;
        categoryColor = Colors.blue;
        break;
      case PreparationCategory.purchase:
        categoryIcon = Icons.shopping_cart;
        categoryColor = Colors.green;
        break;
      case PreparationCategory.decision:
        categoryIcon = Icons.lightbulb;
        categoryColor = Colors.orange;
        break;
      case PreparationCategory.document:
        categoryIcon = Icons.description;
        categoryColor = Colors.purple;
        break;
      case PreparationCategory.approval:
        categoryIcon = Icons.check_circle;
        categoryColor = Colors.teal;
        break;
      case PreparationCategory.measurement:
        categoryIcon = Icons.straighten;
        categoryColor = Colors.indigo;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            categoryIcon,
            color: categoryColor,
            size: 24,
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: item.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(item.description),
            if (item.tip != null && item.tip!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.amber.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates,
                      size: 16,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.tip!,
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
        trailing: item.priority == PreparationPriority.critical
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.red.shade200,
                  ),
                ),
                child: Text(
                  'CRÍTICO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              )
            : null,
        isThreeLine: true,
      ),
    );
  }
}

// Made with Bob
