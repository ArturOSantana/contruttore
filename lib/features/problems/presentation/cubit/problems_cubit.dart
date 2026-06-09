import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../reform_map/domain/entities/problem_entity.dart';
import '../../../reform_map/domain/usecases/resolve_problem_usecase.dart';
import '../../domain/usecases/add_problem_usecase.dart';
import '../../domain/usecases/get_problems_usecase.dart';
import '../../domain/repositories/problem_repository.dart';
import 'problems_state.dart';

/// Cubit que gerencia o estado dos problemas da reforma
@injectable
class ProblemsCubit extends Cubit<ProblemsState> {
  final GetProblemsUseCase _getProblemsUseCase;
  final AddProblemUseCase _addProblemUseCase;
  final ResolveProblemUseCase _resolveProblemUseCase;
  final ProblemRepository _repository;

  ProblemsCubit(
    this._getProblemsUseCase,
    this._addProblemUseCase,
    this._resolveProblemUseCase,
    this._repository,
  ) : super(const ProblemsInitial());

  /// Carrega todos os problemas de um projeto
  Future<void> loadProblems(String projectId) async {
    emit(const ProblemsLoading());

    // Buscar problemas principais
    final problemsResult = await _getProblemsUseCase(projectId);

    if (problemsResult.isLeft()) {
      emit(ProblemsError(
        problemsResult.fold((l) => l.message, (r) => ''),
      ));
      return;
    }

    // Buscar problemas críticos e contagem em paralelo
    final criticalResult = await _repository.getCriticalProblems(projectId);
    final countResult = await _repository.countOpenProblems(projectId);

    problemsResult.fold(
      (failure) => emit(ProblemsError(failure.message)),
      (problems) {
        final critical =
            criticalResult.fold((l) => <ProblemEntity>[], (r) => r);
        final count = countResult.fold((l) => 0, (r) => r);

        emit(ProblemsLoaded(
          problems: problems,
          criticalProblems: critical,
          openProblemsCount: count,
        ));
      },
    );
  }

  /// Carrega problemas de uma fase específica
  Future<void> loadProblemsByPhase(String projectId, String phaseId) async {
    emit(const ProblemsLoading());

    final result = await _repository.getProblemsByPhase(projectId, phaseId);

    result.fold(
      (failure) => emit(ProblemsError(failure.message)),
      (problems) => emit(ProblemsLoaded(
        problems: problems,
        criticalProblems: problems
            .where((p) =>
                p.severity == ProblemSeverity.critical &&
                p.status == ProblemStatus.open)
            .toList(),
        openProblemsCount:
            problems.where((p) => p.status == ProblemStatus.open).length,
      )),
    );
  }

  /// Adiciona um novo problema
  Future<void> addProblem(ProblemEntity problem) async {
    final result = await _addProblemUseCase(problem);

    result.fold(
      (failure) => emit(ProblemsError(failure.message)),
      (_) {
        emit(const ProblemAdded());
        // Recarrega a lista após adicionar
        loadProblems(problem.projectId);
      },
    );
  }

  /// Resolve um problema com solução
  Future<void> resolveProblem({
    required String projectId,
    required String problemId,
    required String solution,
  }) async {
    final result = await _resolveProblemUseCase(
      ResolveProblemParams(problemId: problemId, solution: solution),
    );

    result.fold(
      (failure) => emit(ProblemsError(failure.message)),
      (_) {
        emit(const ProblemResolved());
        // Recarrega a lista após resolver
        loadProblems(projectId);
      },
    );
  }

  /// Filtra problemas por status
  Future<void> filterByStatus(String projectId, ProblemStatus status) async {
    emit(const ProblemsLoading());

    final result = await _repository.getProblemsByStatus(projectId, status);

    result.fold(
      (failure) => emit(ProblemsError(failure.message)),
      (problems) => emit(ProblemsLoaded(
        problems: problems,
        criticalProblems: problems
            .where((p) => p.severity == ProblemSeverity.critical)
            .toList(),
        openProblemsCount: status == ProblemStatus.open ? problems.length : 0,
      )),
    );
  }

  /// Busca apenas problemas críticos
  Future<void> loadCriticalProblems(String projectId) async {
    emit(const ProblemsLoading());

    final result = await _repository.getCriticalProblems(projectId);

    result.fold(
      (failure) => emit(ProblemsError(failure.message)),
      (problems) => emit(ProblemsLoaded(
        problems: problems,
        criticalProblems: problems,
        openProblemsCount: problems.length,
      )),
    );
  }

  /// Atualiza um problema existente
  Future<void> updateProblem(ProblemEntity problem) async {
    final result = await _repository.updateProblem(problem);

    result.fold(
      (failure) => emit(ProblemsError(failure.message)),
      (_) {
        // Recarrega a lista após atualizar
        loadProblems(problem.projectId);
      },
    );
  }

  /// Deleta um problema
  Future<void> deleteProblem(String projectId, String problemId) async {
    final result = await _repository.deleteProblem(projectId, problemId);

    result.fold(
      (failure) => emit(ProblemsError(failure.message)),
      (_) {
        // Recarrega a lista após deletar
        loadProblems(projectId);
      },
    );
  }
}

// Made with Bob
