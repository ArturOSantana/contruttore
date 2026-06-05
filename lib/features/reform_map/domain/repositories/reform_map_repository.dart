import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/reform_map_entity.dart';
import '../entities/reform_health_entity.dart';
import '../entities/next_action_entity.dart';
import '../entities/problem_entity.dart';

/// Repositório para o Mapa da Reforma
abstract class ReformMapRepository {
  /// Busca o mapa completo da reforma
  Future<Either<Failure, ReformMapEntity>> getReformMap(String projectId);

  /// Calcula a saúde da reforma
  Future<Either<Failure, ReformHealthEntity>> calculateHealth(String projectId);

  /// Calcula a próxima ação recomendada
  Future<Either<Failure, NextActionEntity?>> calculateNextAction(
    String projectId,
  );

  /// Busca contexto detalhado de uma fase
  Future<Either<Failure, PhaseContext>> getPhaseContext(
    String projectId,
    String phaseId,
  );

  /// Busca todos os problemas abertos
  Future<Either<Failure, List<ProblemEntity>>> getOpenProblems(
    String projectId,
  );

  /// Adiciona um novo problema
  Future<Either<Failure, ProblemEntity>> addProblem(
    ProblemEntity problem,
  );

  /// Atualiza um problema existente
  Future<Either<Failure, ProblemEntity>> updateProblem(
    ProblemEntity problem,
  );

  /// Resolve um problema
  Future<Either<Failure, void>> resolveProblem(
    String problemId,
    String solution,
  );

  /// Marca uma ação como concluída
  Future<Either<Failure, void>> completeAction(
    String projectId,
    String actionId,
  );

  /// Marca uma ação como não aplicável
  Future<Either<Failure, void>> skipAction(
    String projectId,
    String actionId,
    String reason,
  );

  /// Busca histórico de saúde da reforma
  Future<Either<Failure, List<HealthSnapshot>>> getHealthHistory(
    String projectId, {
    int days = 30,
  });
}

/// Snapshot de saúde em um momento específico
class HealthSnapshot {
  final DateTime date;
  final double healthScore;
  final HealthStatus status;

  const HealthSnapshot({
    required this.date,
    required this.healthScore,
    required this.status,
  });
}

// Made with Bob
