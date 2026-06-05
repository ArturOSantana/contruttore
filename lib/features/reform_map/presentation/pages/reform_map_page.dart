import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/reform_map_cubit.dart';
import '../cubit/reform_map_state.dart';
import '../widgets/current_phase_widget.dart';
import '../widgets/health_score_widget.dart';
import '../widgets/next_action_widget.dart';
import '../widgets/phase_overview_widget.dart';
import '../widgets/problems_list_widget.dart';

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

  void _executeAction(BuildContext context, dynamic nextAction) {
    // Aqui você implementaria a navegação para a ação específica
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Executando ação...'),
      ),
    );
  }

  void _navigateToPhaseDetails(BuildContext context, String phaseId) {
    // Aqui você implementaria a navegação para os detalhes da fase
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrindo detalhes da fase: $phaseId'),
      ),
    );
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar Problema'),
        content: const Text(
          'Aqui você poderá reportar problemas como:\n\n'
          '• Infiltração\n'
          '• Material errado\n'
          '• Atraso de fornecedor\n'
          '• Defeitos na execução',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Aqui você implementaria o formulário de adicionar problema
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}

// Made with Bob
