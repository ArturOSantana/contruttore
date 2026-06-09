import 'package:equatable/equatable.dart';
import '../../../reform_map/domain/entities/problem_entity.dart';

/// Estados do módulo de Problemas
abstract class ProblemsState extends Equatable {
  const ProblemsState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ProblemsInitial extends ProblemsState {
  const ProblemsInitial();
}

/// Carregando problemas
class ProblemsLoading extends ProblemsState {
  const ProblemsLoading();
}

/// Problemas carregados com sucesso
class ProblemsLoaded extends ProblemsState {
  final List<ProblemEntity> problems;
  final List<ProblemEntity> criticalProblems;
  final int openProblemsCount;

  const ProblemsLoaded({
    required this.problems,
    required this.criticalProblems,
    required this.openProblemsCount,
  });

  @override
  List<Object?> get props => [problems, criticalProblems, openProblemsCount];
}

/// Erro ao carregar problemas
class ProblemsError extends ProblemsState {
  final String message;

  const ProblemsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Problema adicionado com sucesso
class ProblemAdded extends ProblemsState {
  const ProblemAdded();
}

/// Problema resolvido com sucesso
class ProblemResolved extends ProblemsState {
  const ProblemResolved();
}

// Made with Bob
