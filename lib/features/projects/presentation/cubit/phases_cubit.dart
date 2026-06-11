import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/phase_entity.dart';
import '../../domain/usecases/get_phases_usecase.dart';
import '../../domain/usecases/update_subtask_usecase.dart';
import '../../domain/usecases/complete_phase_usecase.dart';
import '../../../financial/domain/usecases/update_phase_financials_usecase.dart';
import '../../../reform_map/presentation/cubit/reform_map_cubit.dart';
import '../../../diary/domain/usecases/add_automatic_entry_usecase.dart';
import '../../../diary/domain/entities/diary_entry_entity.dart';
import '../../../../core/services/notification_service.dart';
import 'phases_state.dart';

/// Cubit para gerenciar o estado das fases
@injectable
class PhasesCubit extends Cubit<PhasesState> {
  final GetPhasesUsecase _getPhasesUsecase;
  final UpdateSubtaskUsecase _updateSubtaskUsecase;
  final CompletePhaseUsecase _completePhaseUsecase;
  final UpdatePhaseFinancialsUseCase _updatePhaseFinancialsUseCase;
  final AddAutomaticEntryUseCase _addAutomaticEntryUseCase;
  final NotificationService _notificationService;

  // Referência opcional ao ReformMapCubit para sincronização
  ReformMapCubit? _reformMapCubit;

  PhasesCubit(
    this._getPhasesUsecase,
    this._updateSubtaskUsecase,
    this._completePhaseUsecase,
    this._updatePhaseFinancialsUseCase,
    this._addAutomaticEntryUseCase,
    this._notificationService,
  ) : super(const PhasesInitial());

  /// Define o ReformMapCubit para sincronização
  void setReformMapCubit(ReformMapCubit cubit) {
    _reformMapCubit = cubit;
  }

  /// Carrega as fases de um projeto
  Future<void> loadPhases(String projectId) async {
    if (projectId.isEmpty) {
      emit(const PhasesError('ID do projeto não fornecido'));
      return;
    }

    emit(const PhasesLoading());

    final result = await _getPhasesUsecase(projectId);

    result.fold(
      (failure) => emit(PhasesError(failure.message)),
      (phases) {
        if (phases.isEmpty) {
          emit(const PhasesError('Nenhuma fase encontrada'));
          return;
        }

        // Encontra a fase atual (primeira fase ativa, locked ou a primeira da lista)
        PhaseEntity? currentPhase;

        // Tenta encontrar uma fase ativa
        try {
          currentPhase = phases.firstWhere(
            (phase) => phase.status == PhaseStatus.active,
          );
        } catch (_) {
          // Se não encontrar ativa, tenta locked
          try {
            currentPhase = phases.firstWhere(
              (phase) => phase.status == PhaseStatus.locked,
            );
          } catch (_) {
            // Se não encontrar nenhuma, usa a primeira
            currentPhase = phases.first;
          }
        }

        emit(PhasesLoaded(
          phases: phases,
          currentPhase: currentPhase,
        ));
      },
    );
  }

  /// Atualiza uma subtarefa
  Future<void> toggleSubtask(
    String phaseId,
    SubtaskEntity subtask,
  ) async {
    final currentState = state;
    if (currentState is! PhasesLoaded) return;

    // Encontra a fase para obter o projectId
    final phase = currentState.phases.firstWhere((p) => p.id == phaseId);

    // Atualiza o estado da subtarefa
    final updatedSubtask = subtask.copyWith(
      isDone: !subtask.isDone,
      completedAt: !subtask.isDone ? DateTime.now() : null,
      clearCompletedAt: subtask.isDone,
    );

    // Atualiza a fase localmente ANTES de salvar (UI mais fluida)
    final updatedPhase = phase.copyWith(
      subtasks: phase.subtasks.map((s) {
        return s.id == subtask.id ? updatedSubtask : s;
      }).toList(),
    );

    // Atualiza o estado imediatamente para UI fluida
    final updatedPhases = currentState.phases.map((p) {
      return p.id == phaseId ? updatedPhase : p;
    }).toList();

    emit(PhasesLoaded(
      phases: updatedPhases,
      currentPhase: updatedPhase,
    ));

    // Salva no Firestore em background
    final params = UpdateSubtaskParams(
      projectId: phase.projectId,
      phaseId: phaseId,
      subtask: updatedSubtask,
    );

    final result = await _updateSubtaskUsecase(params);

    result.fold(
      (failure) {
        // Se falhar, reverte o estado
        emit(currentState);
        emit(PhasesError(failure.message));
      },
      (_) async {
        // Adiciona log no diário
        await _addAutomaticEntryUseCase(
          projectId: phase.projectId,
          title: updatedSubtask.isDone ? 'Tarefa concluída' : 'Tarefa reaberta',
          description: '${phase.name}: ${subtask.name}',
          phaseId: phaseId,
          type: DiaryEntryType.daily,
        );

        // Atualiza financeiro da fase
        await _updatePhaseFinancialsUseCase(
          projectId: phase.projectId,
          phaseId: phaseId,
        );

        // Verifica se a fase foi concluída
        await _checkPhaseCompletion(phase.projectId, phaseId);

        // Sincroniza com GPS da Reforma
        _reformMapCubit?.refreshAll(phase.projectId);
      },
    );
  }

  /// Verifica se uma fase foi concluída e envia notificação
  Future<void> _checkPhaseCompletion(String projectId, String phaseId) async {
    final currentState = state;
    if (currentState is! PhasesLoaded) return;

    final phase = currentState.phases.firstWhere((p) => p.id == phaseId);

    // Se a fase foi concluída (100% de progresso)
    if (phase.progressPercentage >= 100 && phase.status == PhaseStatus.done) {
      // Envia notificação
      await _notificationService.showNotification(
        title: '🎉 Fase Concluída!',
        body: '${phase.name} foi concluída com sucesso!',
        payload: '/phases/$phaseId',
      );

      // Adiciona log no diário
      await _addAutomaticEntryUseCase(
        projectId: projectId,
        title: 'Fase concluída',
        description: '${phase.name} foi finalizada!',
        phaseId: phaseId,
        type: DiaryEntryType.daily,
      );
    }

    // Verifica se a fase está atrasada
    if (phase.endDate != null &&
        DateTime.now().isAfter(phase.endDate!) &&
        phase.status != PhaseStatus.done) {
      // Envia notificação de atraso
      await _notificationService.showNotification(
        title: '⚠️ Fase Atrasada',
        body: '${phase.name} está atrasada. Verifique o cronograma.',
        payload: '/phases/$phaseId',
      );
    }
  }

  /// Conclui uma fase manualmente
  Future<PhaseEntity?> completePhase(String projectId, String phaseId) async {
    final result = await _completePhaseUsecase(
      CompletePhaseParams(projectId: projectId, phaseId: phaseId),
    );

    return result.fold(
      (failure) {
        emit(PhasesError(failure.message));
        return null;
      },
      (_) async {
        // Adiciona log no diário
        final currentState = state;
        if (currentState is PhasesLoaded) {
          final phase = currentState.phases.firstWhere((p) => p.id == phaseId);
          await _addAutomaticEntryUseCase(
            projectId: projectId,
            title: 'Fase concluída',
            description: '${phase.name} foi marcada como concluída',
            phaseId: phaseId,
            type: DiaryEntryType.daily,
          );
        }

        // Recarrega as fases
        await loadPhases(projectId);

        // Sincroniza com GPS da Reforma
        _reformMapCubit?.refreshAll(projectId);

        // Retorna a próxima fase ativa (se houver)
        final newState = state;
        if (newState is PhasesLoaded) {
          // Encontra a próxima fase ativa
          final nextPhase = newState.phases.firstWhere(
            (p) => p.status == PhaseStatus.active,
            orElse: () => newState.phases.last,
          );
          return nextPhase;
        }

        return null;
      },
    );
  }

  /// Pula uma fase
  Future<PhaseEntity?> skipPhase(String projectId, String phaseId) async {
    final result = await _completePhaseUsecase(
      CompletePhaseParams(projectId: projectId, phaseId: phaseId),
    );

    return result.fold(
      (failure) {
        emit(PhasesError(failure.message));
        return null;
      },
      (_) async {
        // Adiciona log no diário
        final currentState = state;
        if (currentState is PhasesLoaded) {
          final phase = currentState.phases.firstWhere((p) => p.id == phaseId);
          await _addAutomaticEntryUseCase(
            projectId: projectId,
            title: 'Fase pulada',
            description: '${phase.name} foi pulada',
            phaseId: phaseId,
            type: DiaryEntryType.daily,
          );
        }

        // Recarrega as fases
        await loadPhases(projectId);

        // Sincroniza com GPS da Reforma
        _reformMapCubit?.refreshAll(projectId);

        // Retorna a próxima fase ativa (se houver)
        final newState = state;
        if (newState is PhasesLoaded) {
          // Encontra a próxima fase ativa
          final nextPhase = newState.phases.firstWhere(
            (p) => p.status == PhaseStatus.active,
            orElse: () => newState.phases.last,
          );
          return nextPhase;
        }

        return null;
      },
    );
  }

  /// Marca uma fase como iniciada
  Future<void> startPhase(String projectId, String phaseId) async {
    final currentState = state;
    if (currentState is! PhasesLoaded) return;

    final phase = currentState.phases.firstWhere((p) => p.id == phaseId);

    // Adiciona log no diário
    await _addAutomaticEntryUseCase(
      projectId: projectId,
      title: 'Fase iniciada',
      description: '${phase.name} foi iniciada',
      phaseId: phaseId,
      type: DiaryEntryType.daily,
    );

    // Envia notificação
    await _notificationService.showNotification(
      title: '🚀 Nova Fase Iniciada',
      body: 'Você iniciou: ${phase.name}',
      payload: '/phases/$phaseId',
    );

    // Recarrega as fases
    await loadPhases(projectId);

    // Sincroniza com GPS da Reforma
    _reformMapCubit?.refreshAll(projectId);
  }

  /// Seleciona uma fase específica
  void selectPhase(PhaseEntity phase) {
    final currentState = state;
    if (currentState is PhasesLoaded) {
      emit(currentState.copyWith(currentPhase: phase));
    }
  }

  /// Limpa o estado
  void clear() {
    emit(const PhasesInitial());
  }
}

// Made with Bob
