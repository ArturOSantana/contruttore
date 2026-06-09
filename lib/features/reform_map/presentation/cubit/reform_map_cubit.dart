import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/problem_entity.dart';
import '../../domain/entities/reform_calendar_entity.dart';
import '../../domain/services/move_in_distance_calculator.dart';
import '../../domain/services/move_in_mode_generator.dart';
import '../../domain/services/pending_decisions_detector.dart';
import '../../domain/services/upcoming_purchases_detector.dart';
import '../../domain/services/next_phase_preparation_detector.dart';
import '../../domain/services/milestones_detector.dart';
import '../../domain/services/calendar_events_detector.dart';
import '../../domain/services/reform_week_generator.dart';
import '../../domain/usecases/add_problem_usecase.dart';
import '../../domain/usecases/add_calendar_event_usecase.dart';
import '../../domain/usecases/calculate_health_usecase.dart';
import '../../domain/usecases/calculate_next_action_usecase.dart';
import '../../domain/usecases/calculate_upcoming_expenses_usecase.dart';
import '../../domain/usecases/get_next_step_preparation_usecase.dart';
import '../../domain/usecases/get_reform_map_usecase.dart';
import '../../domain/usecases/resolve_problem_usecase.dart';
import '../../domain/usecases/update_preparation_item_usecase.dart';
import 'reform_map_state.dart';

/// Cubit que gerencia o estado do Mapa da Reforma
///
/// Este é o "cérebro" do aplicativo que:
/// - Mostra onde o usuário está na reforma
/// - Calcula a saúde da reforma
/// - Sugere a próxima ação
/// - Gerencia problemas
@injectable
class ReformMapCubit extends Cubit<ReformMapState> {
  final GetReformMapUseCase getReformMapUseCase;
  final CalculateHealthUseCase calculateHealthUseCase;
  final CalculateNextActionUseCase calculateNextActionUseCase;
  final AddProblemUseCase addProblemUseCase;
  final CalculateUpcomingExpensesUseCase calculateUpcomingExpensesUseCase;
  final GetNextStepPreparationUseCase getNextStepPreparationUseCase;
  final UpdatePreparationItemUseCase updatePreparationItemUseCase;
  final ResolveProblemUseCase resolveProblemUseCase;
  final MoveInDistanceCalculator moveInDistanceCalculator;
  final MoveInModeGenerator moveInModeGenerator;
  final PendingDecisionsDetector pendingDecisionsDetector;
  final UpcomingPurchasesDetector upcomingPurchasesDetector;
  final NextPhasePreparationDetector nextPhasePreparationDetector;
  final MilestonesDetector milestonesDetector;
  final CalendarEventsDetector calendarEventsDetector;
  final ReformWeekGenerator reformWeekGenerator;
  final AddCalendarEventUseCase addCalendarEventUseCase;

  ReformMapCubit({
    required this.getReformMapUseCase,
    required this.calculateHealthUseCase,
    required this.calculateNextActionUseCase,
    required this.addProblemUseCase,
    required this.calculateUpcomingExpensesUseCase,
    required this.getNextStepPreparationUseCase,
    required this.updatePreparationItemUseCase,
    required this.resolveProblemUseCase,
    required this.moveInDistanceCalculator,
    required this.moveInModeGenerator,
    required this.pendingDecisionsDetector,
    required this.upcomingPurchasesDetector,
    required this.nextPhasePreparationDetector,
    required this.milestonesDetector,
    required this.calendarEventsDetector,
    required this.reformWeekGenerator,
    required this.addCalendarEventUseCase,
  }) : super(const ReformMapInitial());

  /// Carrega o mapa da reforma para um projeto específico
  Future<void> loadReformMap(String projectId) async {
    emit(const ReformMapLoading());

    final result = await getReformMapUseCase(projectId);

    result.fold(
      (failure) => emit(ReformMapError(failure.message)),
      (reformMap) {
        // Calcula a distância até a mudança
        final moveInDistance = moveInDistanceCalculator.calculate(reformMap);

        // Detecta decisões pendentes
        final pendingDecisions = pendingDecisionsDetector.detect(reformMap);

        // Detecta próximas compras
        final upcomingPurchases = upcomingPurchasesDetector.detect(reformMap);

        // Detecta preparação da próxima fase
        final nextPhasePreparation =
            nextPhasePreparationDetector.detect(reformMap);

        // Detecta marcos da reforma
        final milestones = milestonesDetector.detect(reformMap);

        // Detecta eventos do calendário
        final calendar = calendarEventsDetector.detect(reformMap);

        // Gera a semana da reforma a partir do calendário
        final week =
            calendar != null ? reformWeekGenerator.generate(calendar) : null;

        // Gera o modo mudança (ativa quando progresso >= 80% ou faltam <= 30 dias)
        final moveInMode = moveInModeGenerator.generate(
          phases: reformMap.phases,
          overallProgress: reformMap.progress.completedPercentage,
          plannedMoveInDate: moveInDistance?.estimatedMoveDate,
          criticalPendingItems: reformMap.openProblems
              .where((p) => p.severity == ProblemSeverity.critical)
              .map((p) => p.title)
              .toList(),
        );

        // Atualiza o mapa com os dados calculados
        final updatedMap = reformMap.copyWith(
          moveInDistance: moveInDistance,
          moveInMode: moveInMode,
          pendingDecisions: pendingDecisions,
          upcomingPurchases: upcomingPurchases,
          nextPhasePreparation: nextPhasePreparation,
          milestones: milestones,
          calendar: calendar,
          week: week,
        );

        emit(ReformMapLoaded(updatedMap));
      },
    );
  }

  /// Atualiza a saúde da reforma
  ///
  /// Recalcula o score baseado em:
  /// - Atrasos no prazo
  /// - Estouro de orçamento
  /// - Problemas abertos
  /// - Tarefas pendentes
  /// - Parcelas vencidas
  Future<void> refreshHealth(String projectId) async {
    final currentState = state;
    if (currentState is! ReformMapLoaded) return;

    emit(ReformMapUpdating(currentState.reformMap));

    final result = await calculateHealthUseCase(projectId);

    result.fold(
      (failure) => emit(ReformMapError(failure.message)),
      (health) {
        final updatedMap = currentState.reformMap.copyWith(health: health);
        emit(ReformMapLoaded(updatedMap));
      },
    );
  }

  /// Recalcula a próxima ação recomendada
  ///
  /// O sistema analisa:
  /// - Etapa atual
  /// - Pendências críticas
  /// - Prazos próximos
  /// - Orçamento disponível
  ///
  /// E sugere UMA ação prioritária
  Future<void> refreshNextAction(String projectId) async {
    final currentState = state;
    if (currentState is! ReformMapLoaded) return;

    emit(ReformMapUpdating(currentState.reformMap));

    final result = await calculateNextActionUseCase(projectId);

    result.fold(
      (failure) => emit(ReformMapError(failure.message)),
      (nextAction) {
        final updatedMap = currentState.reformMap.copyWith(
          nextAction: nextAction,
        );
        emit(ReformMapLoaded(updatedMap));
      },
    );
  }

  /// Adiciona um problema à reforma
  ///
  /// Exemplos:
  /// - Infiltração
  /// - Material errado
  /// - Atraso de fornecedor
  /// - Parede torta
  Future<void> addProblem(ProblemEntity problem) async {
    final currentState = state;
    if (currentState is! ReformMapLoaded) return;

    emit(ReformMapUpdating(currentState.reformMap));

    final result = await addProblemUseCase(problem);

    result.fold(
      (failure) => emit(ReformMapError(failure.message)),
      (_) async {
        // Recarrega o mapa completo após adicionar problema
        await loadReformMap(currentState.reformMap.projectId);
      },
    );
  }

  /// Atualiza tudo de uma vez
  ///
  /// Útil quando:
  /// - Usuário volta para a tela
  /// - Completou uma ação importante
  /// - Quer ver o status atualizado
  Future<void> refreshAll(String projectId) async {
    await loadReformMap(projectId);
  }

  /// Marca uma etapa como iniciada
  Future<void> startPhase(String projectId, String phaseId) async {
    final currentState = state;
    if (currentState is! ReformMapLoaded) return;

    emit(ReformMapUpdating(currentState.reformMap));

    // Aqui você implementaria a lógica para iniciar uma fase
    // Por enquanto, apenas recarrega o mapa
    await loadReformMap(projectId);
  }

  /// Marca uma etapa como concluída
  Future<void> completePhase(String projectId, String phaseId) async {
    final currentState = state;
    if (currentState is! ReformMapLoaded) return;

    emit(ReformMapUpdating(currentState.reformMap));

    // Aqui você implementaria a lógica para concluir uma fase
    // Por enquanto, apenas recarrega o mapa
    await loadReformMap(projectId);
  }

  /// Calcula despesas futuras previstas
  ///
  /// Parâmetros:
  /// - [projectId]: ID do projeto
  /// - [days]: Período de previsão (30, 60 ou 90 dias)
  Future<void> loadUpcomingExpenses(String projectId, int days) async {
    emit(const ReformMapLoading());

    final result = await calculateUpcomingExpensesUseCase(
      CalculateUpcomingExpensesParams(projectId: projectId, days: days),
    );

    result.fold(
      (failure) => emit(ReformMapError(failure.message)),
      (expenses) => emit(UpcomingExpensesLoaded(expenses, days)),
    );
  }

  /// Busca preparação da próxima etapa
  Future<void> loadNextStepPreparation(String projectId) async {
    emit(const ReformMapLoading());

    final result = await getNextStepPreparationUseCase(
      GetNextStepPreparationParams(projectId: projectId),
    );

    result.fold(
      (failure) => emit(ReformMapError(failure.message)),
      (preparation) => emit(NextStepPreparationLoaded(preparation)),
    );
  }

  /// Atualiza item do checklist de preparação
  Future<void> updatePreparationItem({
    required String projectId,
    required String stepId,
    required String itemId,
    required bool isDone,
  }) async {
    final currentState = state;
    if (currentState is! NextStepPreparationLoaded) return;

    final result = await updatePreparationItemUseCase(
      UpdatePreparationItemParams(
        projectId: projectId,
        stepId: stepId,
        itemId: itemId,
        isDone: isDone,
      ),
    );

    result.fold(
      (failure) => emit(ReformMapError(failure.message)),
      (_) async {
        // Recarrega a preparação após atualizar
        await loadNextStepPreparation(projectId);
      },
    );
  }

  /// Carrega mapa com dados extras (despesas e preparação)
  Future<void> loadReformMapWithExtras(String projectId,
      {int days = 30}) async {
    emit(const ReformMapLoading());

    // Carrega mapa principal
    final mapResult = await getReformMapUseCase(projectId);

    await mapResult.fold(
      (failure) async => emit(ReformMapError(failure.message)),
      (reformMap) async {
        // Carrega despesas futuras em paralelo
        final expensesResult = await calculateUpcomingExpensesUseCase(
          CalculateUpcomingExpensesParams(projectId: projectId, days: days),
        );

        // Carrega preparação em paralelo
        final preparationResult = await getNextStepPreparationUseCase(
          GetNextStepPreparationParams(projectId: projectId),
        );

        emit(ReformMapLoadedWithExtras(
          reformMap: reformMap,
          upcomingExpenses: expensesResult.fold((_) => null, (e) => e),
          nextStepPreparation: preparationResult.fold((_) => null, (p) => p),
        ));
      },
    );
  }

  /// Resolve um problema com solução
  Future<void> resolveProblemWithSolution({
    required String projectId,
    required String problemId,
    required String solution,
  }) async {
    final currentState = state;
    if (currentState is! ReformMapLoaded &&
        currentState is! ReformMapLoadedWithExtras) {
      return;
    }

    final result = await resolveProblemUseCase(
      ResolveProblemParams(problemId: problemId, solution: solution),
    );

    result.fold(
      (failure) => emit(ReformMapError(failure.message)),
      (_) async {
        // Recarrega o mapa após resolver problema
        await loadReformMap(projectId);
      },
    );
  }

  /// Adiciona um evento customizado ao calendário
  Future<void> addCalendarEvent({
    required String projectId,
    required CalendarEventEntity event,
  }) async {
    final result = await addCalendarEventUseCase(
      AddCalendarEventParams(
        projectId: projectId,
        event: event,
      ),
    );

    result.fold(
      (failure) => emit(ReformMapError(failure.message)),
      (_) async {
        // Recarrega o mapa após adicionar evento
        await loadReformMap(projectId);
      },
    );
  }

  /// Resolve um problema (método legado - mantido para compatibilidade)
  Future<void> resolveProblem(String projectId, String problemId) async {
    final currentState = state;
    if (currentState is! ReformMapLoaded) return;

    emit(ReformMapUpdating(currentState.reformMap));

    // Aqui você implementaria a lógica para resolver um problema
    // Por enquanto, apenas recarrega o mapa
    await loadReformMap(projectId);
  }
}

// Made with Bob
