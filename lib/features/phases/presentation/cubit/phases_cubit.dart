import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/complete_phase_usecase.dart';
import '../../domain/usecases/get_phases_usecase.dart';
import '../../domain/usecases/toggle_subtask_usecase.dart';
import 'phases_state.dart';

@injectable
class PhasesCubit extends Cubit<PhasesState> {
  final GetPhasesUseCase _getPhasesUseCase;
  final ToggleSubtaskUseCase _toggleSubtaskUseCase;
  final CompletePhaseUseCase _completePhaseUseCase;

  PhasesCubit(
    this._getPhasesUseCase,
    this._toggleSubtaskUseCase,
    this._completePhaseUseCase,
  ) : super(PhasesInitial());

  Future<void> loadPhases(String projectId) async {
    emit(PhasesLoading());

    final result = await _getPhasesUseCase(projectId);

    result.fold(
      (failure) => emit(PhasesError(failure.message)),
      (phases) => emit(PhasesLoaded(phases)),
    );
  }

  Future<void> toggleSubtask({
    required String projectId,
    required String phaseId,
    required String subtaskId,
  }) async {
    final result = await _toggleSubtaskUseCase(
      projectId: projectId,
      phaseId: phaseId,
      subtaskId: subtaskId,
    );

    result.fold(
      (failure) => emit(PhasesError(failure.message)),
      (_) => loadPhases(projectId),
    );
  }

  Future<void> completePhase({
    required String projectId,
    required String phaseId,
  }) async {
    final result = await _completePhaseUseCase(
      projectId: projectId,
      phaseId: phaseId,
    );

    result.fold(
      (failure) => emit(PhasesError(failure.message)),
      (_) => loadPhases(projectId),
    );
  }
}

// Made with Bob
