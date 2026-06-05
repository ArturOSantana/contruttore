import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/problem_entity.dart';
import '../../domain/usecases/add_problem_usecase.dart';
import '../../domain/usecases/calculate_health_usecase.dart';
import '../../domain/usecases/calculate_next_action_usecase.dart';
import '../../domain/usecases/get_reform_map_usecase.dart';
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

  ReformMapCubit({
    required this.getReformMapUseCase,
    required this.calculateHealthUseCase,
    required this.calculateNextActionUseCase,
    required this.addProblemUseCase,
  }) : super(const ReformMapInitial());

  /// Carrega o mapa da reforma para um projeto específico
  Future<void> loadReformMap(String projectId) async {
    emit(const ReformMapLoading());

    final result = await getReformMapUseCase(projectId);

    result.fold(
      (failure) => emit(ReformMapError(failure.message)),
      (reformMap) => emit(ReformMapLoaded(reformMap)),
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

  /// Resolve um problema
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
