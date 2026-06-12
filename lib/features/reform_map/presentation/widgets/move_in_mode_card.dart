import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../injection_container.dart';
import '../../../move_in/presentation/cubit/move_in_cubit.dart';
import '../../../move_in/presentation/cubit/move_in_state.dart';
import '../../../move_in/domain/entities/move_in_task_entity.dart';

/// Card do Modo Mudança - Versão Interativa com dados reais do Firestore
///
/// Aparece quando a reforma está próxima da conclusão
/// Mostra checklist de preparação e status da mudança
/// Usa dados reais do Firestore através do MoveInCubit
class MoveInModeCard extends StatelessWidget {
  final int daysUntilMoveIn;
  final String projectId;

  const MoveInModeCard({
    super.key,
    required this.daysUntilMoveIn,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MoveInCubit>()..loadTasks(projectId),
      child: BlocBuilder<MoveInCubit, MoveInState>(
        builder: (context, state) {
          if (state is MoveInLoading) {
            return _buildLoadingCard();
          }

          if (state is MoveInError) {
            return _buildErrorCard(context, state.message);
          }

          if (state is MoveInLoaded) {
            return _buildLoadedCard(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
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
              Colors.blue,
              Colors.blue.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Card(
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
              Colors.orange,
              Colors.orange.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 12),
              Text(
                'Erro ao carregar tarefas',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedCard(BuildContext context, MoveInLoaded state) {
    final status = _determineStatus(state);
    final statusColor = _getStatusColor(status);

    return Card(
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
              statusColor,
              statusColor.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/move-in'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.moving,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Modo Mudança',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getDaysMessage(),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getStatusEmoji(status),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getStatusLabel(status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Descrição do status
                  Text(
                    _getStatusDescription(status, state),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Progresso das tarefas
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Checklist de Mudança',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${state.completedTasks.length}/${state.tasks.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: state.progress,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${state.completionPercentage.toStringAsFixed(0)}% concluído',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Próxima tarefa (baseada em prioridade dinâmica)
                  if (state.nextTask != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                state.nextTask!.category.emoji,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Próxima tarefa',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              if (state.nextTask!.isCritical)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'CRÍTICO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.nextTask!.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.nextTask!.description,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Botão de ação
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/move-in/$projectId'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: statusColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ver Checklist Completo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getDaysMessage() {
    if (daysUntilMoveIn <= 0) {
      return 'Mudança prevista para hoje!';
    } else if (daysUntilMoveIn == 1) {
      return 'Falta 1 dia para a mudança';
    } else if (daysUntilMoveIn <= 7) {
      return 'Faltam $daysUntilMoveIn dias para a mudança';
    } else if (daysUntilMoveIn <= 30) {
      final weeks = (daysUntilMoveIn / 7).ceil();
      return 'Faltam $weeks semanas para a mudança';
    } else {
      final months = (daysUntilMoveIn / 30).ceil();
      return 'Faltam $months meses para a mudança';
    }
  }

  MoveInStatus _determineStatus(MoveInLoaded state) {
    final progress = state.completionPercentage;
    final criticalPending =
        state.pendingTasks.where((t) => t.isCritical && !t.isCompleted).length;

    // Atrasado: tem pendências críticas e pouco tempo
    if (criticalPending > 0 && daysUntilMoveIn <= 7) {
      return MoveInStatus.delayed;
    }

    // Pronto: progresso >= 95% e sem críticos pendentes
    if (progress >= 95 && criticalPending == 0) {
      return MoveInStatus.ready;
    }

    // Quase pronto: progresso >= 80% e poucos críticos
    if (progress >= 80 && criticalPending <= 2) {
      return MoveInStatus.almostReady;
    }

    // Não está pronto
    return MoveInStatus.notReady;
  }

  Color _getStatusColor(MoveInStatus status) {
    switch (status) {
      case MoveInStatus.ready:
        return Colors.teal;
      case MoveInStatus.almostReady:
        return Colors.cyan;
      case MoveInStatus.notReady:
        return Colors.blue;
      case MoveInStatus.delayed:
        return Colors.orange;
    }
  }

  String _getStatusLabel(MoveInStatus status) {
    switch (status) {
      case MoveInStatus.ready:
        return 'Pronto para mudar';
      case MoveInStatus.almostReady:
        return 'Quase pronto';
      case MoveInStatus.notReady:
        return 'Ainda não está pronto';
      case MoveInStatus.delayed:
        return 'Mudança pode atrasar';
    }
  }

  String _getStatusEmoji(MoveInStatus status) {
    switch (status) {
      case MoveInStatus.ready:
        return '✅';
      case MoveInStatus.almostReady:
        return '🔄';
      case MoveInStatus.notReady:
        return '⏳';
      case MoveInStatus.delayed:
        return '⚠️';
    }
  }

  String _getStatusDescription(MoveInStatus status, MoveInLoaded state) {
    switch (status) {
      case MoveInStatus.ready:
        return 'Tudo pronto para a mudança! Parabéns!';
      case MoveInStatus.almostReady:
        return 'Faltam apenas alguns detalhes para concluir';
      case MoveInStatus.notReady:
        final pending = state.pendingTasks.length;
        return 'Ainda há $pending ${pending == 1 ? 'item' : 'itens'} pendente${pending == 1 ? '' : 's'}';
      case MoveInStatus.delayed:
        final critical = state.pendingTasks
            .where((t) => t.isCritical && !t.isCompleted)
            .length;
        return 'Atenção! $critical ${critical == 1 ? 'item crítico' : 'itens críticos'} pendente${critical == 1 ? '' : 's'}';
    }
  }
}

/// Status do modo mudança
enum MoveInStatus {
  notReady,
  almostReady,
  ready,
  delayed,
}

// Made with Bob
