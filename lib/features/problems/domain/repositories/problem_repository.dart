import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../reform_map/domain/entities/problem_entity.dart';

/// Repository para gerenciar problemas da reforma
abstract class ProblemRepository {
  /// Adiciona um novo problema
  Future<Either<Failure, void>> addProblem(ProblemEntity problem);

  /// Busca todos os problemas de um projeto
  Future<Either<Failure, List<ProblemEntity>>> getProblems(String projectId);

  /// Busca problemas por fase
  Future<Either<Failure, List<ProblemEntity>>> getProblemsByPhase(
    String projectId,
    String phaseId,
  );

  /// Busca problemas por status
  Future<Either<Failure, List<ProblemEntity>>> getProblemsByStatus(
    String projectId,
    ProblemStatus status,
  );

  /// Busca problemas críticos (severity = critical)
  Future<Either<Failure, List<ProblemEntity>>> getCriticalProblems(
    String projectId,
  );

  /// Atualiza um problema
  Future<Either<Failure, void>> updateProblem(ProblemEntity problem);

  /// Resolve um problema com solução
  Future<Either<Failure, void>> resolveProblem({
    required String problemId,
    required String solution,
  });

  /// Deleta um problema
  Future<Either<Failure, void>> deleteProblem(
    String projectId,
    String problemId,
  );

  /// Conta problemas abertos
  Future<Either<Failure, int>> countOpenProblems(String projectId);
}

// Made with Bob
