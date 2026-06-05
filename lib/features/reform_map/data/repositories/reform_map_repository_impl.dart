import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../../domain/entities/next_action_entity.dart';
import '../../domain/entities/problem_entity.dart';
import '../../domain/entities/reform_health_entity.dart';
import '../../domain/entities/reform_map_entity.dart';
import '../../domain/repositories/reform_map_repository.dart';
import '../models/next_action_model.dart';
import '../models/problem_model.dart';
import '../models/reform_health_model.dart';
import '../models/reform_map_model.dart';

/// Implementação do repositório do Mapa da Reforma
///
/// Responsável por:
/// - Buscar dados do Firebase
/// - Calcular métricas em tempo real
/// - Integrar com outros módulos
/// - Persistir alterações
@LazySingleton(as: ReformMapRepository)
class ReformMapRepositoryImpl implements ReformMapRepository {
  final FirebaseFirestore _firestore;

  ReformMapRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, ReformMapEntity>> getReformMap(
    String projectId,
  ) async {
    try {
      // Buscar projeto
      final projectDoc =
          await _firestore.collection('projects').doc(projectId).get();

      if (!projectDoc.exists) {
        return Left(ServerFailure('Projeto não encontrado'));
      }

      final projectData = projectDoc.data()!;

      // Buscar problemas
      final problemsSnapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('problems')
          .where('status', whereIn: ['open', 'inProgress']).get();

      final problems = problemsSnapshot.docs
          .map((doc) => ProblemModel.fromMap(doc.data()))
          .toList();

      // Calcular saúde
      final health = await _calculateHealth(projectId, projectData, problems);

      // Calcular próxima ação
      final nextAction = await _calculateNextAction(
        projectId,
        projectData,
        problems,
      );

      // Montar progresso
      final completedCount = projectData['completedPhases'] ?? 0;
      final inProgressCount = projectData['inProgressPhases'] ?? 0;
      final totalPhases = projectData['totalPhases'] ?? 9;

      final progress = ReformProgressModel(
        completedPhases: completedCount,
        totalPhases: totalPhases,
        inProgressPhases: inProgressCount,
        completedPercentage:
            (projectData['completedPercentage'] as num?)?.toDouble() ?? 0.0,
        estimatedEndDate: projectData['estimatedEndDate'] != null
            ? DateTime.parse(projectData['estimatedEndDate'] as String)
            : null,
        daysRemaining: projectData['daysRemaining'] ?? 0,
        daysDelayed: projectData['daysDelayed'] ?? 0,
      );

      // Montar snapshot financeiro
      final financial = FinancialSnapshotModel(
        totalBudget: (projectData['totalBudget'] as num?)?.toDouble() ?? 0.0,
        totalSpent: (projectData['totalSpent'] as num?)?.toDouble() ?? 0.0,
        remainingBudget:
            (projectData['remainingBudget'] as num?)?.toDouble() ?? 0.0,
        percentageSpent:
            (projectData['percentageSpent'] as num?)?.toDouble() ?? 0.0,
        pendingPayments: projectData['pendingPayments'] ?? 0,
        nextPaymentAmount:
            (projectData['nextPaymentAmount'] as num?)?.toDouble() ?? 0.0,
        nextPaymentDate: projectData['nextPaymentDate'] != null
            ? DateTime.parse(projectData['nextPaymentDate'] as String)
            : null,
      );

      // Buscar fases do projeto
      final phases = await _getProjectPhases(projectId);

      // Determinar fase atual
      final currentPhase = phases.isNotEmpty ? phases.first : null;

      final reformMap = ReformMapModel(
        projectId: projectId,
        phases: phases.cast<PhaseEntity>(),
        currentPhase: currentPhase,
        health: health,
        nextAction: nextAction,
        openProblems: problems,
        progress: progress,
        financial: financial,
        positiveMessages:
            _generatePositiveMessages(progress, financial, problems),
        lastUpdated: DateTime.now(),
      );

      return Right(reformMap);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar mapa da reforma: $e'));
    }
  }

  @override
  Future<Either<Failure, ReformHealthEntity>> calculateHealth(
    String projectId,
  ) async {
    try {
      final projectDoc =
          await _firestore.collection('projects').doc(projectId).get();

      if (!projectDoc.exists) {
        return Left(ServerFailure('Projeto não encontrado'));
      }

      final problemsSnapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('problems')
          .where('status', whereIn: ['open', 'inProgress']).get();

      final problems = problemsSnapshot.docs
          .map((doc) => ProblemModel.fromMap(doc.data()))
          .toList();

      final health = await _calculateHealth(
        projectId,
        projectDoc.data()!,
        problems,
      );

      return Right(health);
    } catch (e) {
      return Left(ServerFailure('Erro ao calcular saúde: $e'));
    }
  }

  @override
  Future<Either<Failure, NextActionEntity?>> calculateNextAction(
    String projectId,
  ) async {
    try {
      final projectDoc =
          await _firestore.collection('projects').doc(projectId).get();

      if (!projectDoc.exists) {
        return Left(ServerFailure('Projeto não encontrado'));
      }

      final problemsSnapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('problems')
          .where('status', whereIn: ['open', 'inProgress']).get();

      final problems = problemsSnapshot.docs
          .map((doc) => ProblemModel.fromMap(doc.data()))
          .toList();

      final nextAction = await _calculateNextAction(
        projectId,
        projectDoc.data()!,
        problems,
      );

      return Right(nextAction);
    } catch (e) {
      return Left(ServerFailure('Erro ao calcular próxima ação: $e'));
    }
  }

  @override
  Future<Either<Failure, ProblemEntity>> addProblem(
      ProblemEntity problem) async {
    try {
      final problemModel = ProblemModel.fromEntity(problem);
      final projectId = problem.phaseId?.split('_').first ?? '';

      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('problems')
          .doc(problem.id)
          .set(problemModel.toMap());

      return Right(problem);
    } catch (e) {
      return Left(ServerFailure('Erro ao adicionar problema: $e'));
    }
  }

  @override
  Future<Either<Failure, ProblemEntity>> updateProblem(
      ProblemEntity problem) async {
    try {
      final problemModel = ProblemModel.fromEntity(problem);
      final projectId = problem.phaseId?.split('_').first ?? '';

      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('problems')
          .doc(problem.id)
          .update(problemModel.toMap());

      return Right(problem);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar problema: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resolveProblem(
    String problemId,
    String solution,
  ) async {
    try {
      // Buscar o problema para obter o projectId
      final problemsQuery = await _firestore
          .collectionGroup('problems')
          .where('id', isEqualTo: problemId)
          .limit(1)
          .get();

      if (problemsQuery.docs.isEmpty) {
        return Left(ServerFailure('Problema não encontrado'));
      }

      final problemDoc = problemsQuery.docs.first;
      await problemDoc.reference.update({
        'status': 'resolved',
        'resolvedAt': DateTime.now().toIso8601String(),
        'solution': solution,
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao resolver problema: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProblemEntity>>> getProblems(
    String projectId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('problems')
          .orderBy('reportedAt', descending: true)
          .get();

      final problems =
          snapshot.docs.map((doc) => ProblemModel.fromMap(doc.data())).toList();

      return Right(problems);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar problemas: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> startPhase(
    String projectId,
    String phaseId,
  ) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('phases')
          .doc(phaseId)
          .update({
        'status': 'active',
        'startedAt': DateTime.now().toIso8601String(),
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao iniciar fase: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> completePhase(
    String projectId,
    String phaseId,
  ) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('phases')
          .doc(phaseId)
          .update({
        'status': 'done',
        'completedAt': DateTime.now().toIso8601String(),
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao completar fase: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePhaseProgress(
    String projectId,
    String phaseId,
    double progress,
  ) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('phases')
          .doc(phaseId)
          .update({'progress': progress});

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar progresso: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveReformMap(ReformMapEntity reformMap) async {
    try {
      final reformMapModel = ReformMapModel.fromEntity(reformMap);

      await _firestore
          .collection('projects')
          .doc(reformMap.projectId)
          .collection('reformMap')
          .doc('current')
          .set(reformMapModel.toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao salvar mapa: $e'));
    }
  }

  // Métodos auxiliares privados

  Future<ReformHealthModel> _calculateHealth(
    String projectId,
    Map<String, dynamic> projectData,
    List<ProblemEntity> problems,
  ) async {
    // Implementação simplificada do cálculo de saúde
    double score = 100.0;

    // Fator 1: Prazo (25%)
    final deadlineScore = 100.0; // Simplificado

    // Fator 2: Orçamento (30%)
    final budgetScore = 100.0; // Simplificado

    // Fator 3: Problemas (20%)
    final problemsScore = problems.isEmpty ? 100.0 : 70.0;

    // Fator 4: Tarefas pendentes (15%)
    final tasksScore = 100.0; // Simplificado

    // Fator 5: Pagamentos (10%)
    final paymentsScore = 100.0; // Simplificado

    score = (deadlineScore * 0.25) +
        (budgetScore * 0.30) +
        (problemsScore * 0.20) +
        (tasksScore * 0.15) +
        (paymentsScore * 0.10);

    final status = score >= 80
        ? HealthStatus.excellent
        : score >= 60
            ? HealthStatus.good
            : score >= 40
                ? HealthStatus.warning
                : HealthStatus.critical;

    return ReformHealthModel(
      score: score,
      status: status,
      factors: [
        HealthFactorModel(
          name: 'Prazo',
          score: deadlineScore,
          weight: 0.25,
          description: 'Cumprimento de prazos',
          status: deadlineScore.toFactorStatus(),
        ),
        HealthFactorModel(
          name: 'Orçamento',
          score: budgetScore,
          weight: 0.30,
          description: 'Controle financeiro',
          status: budgetScore.toFactorStatus(),
        ),
        HealthFactorModel(
          name: 'Problemas',
          score: problemsScore,
          weight: 0.20,
          description: 'Problemas ativos',
          status: problemsScore.toFactorStatus(),
        ),
      ],
      calculatedAt: DateTime.now(),
    );
  }

  Future<NextActionModel?> _calculateNextAction(
    String projectId,
    Map<String, dynamic> projectData,
    List<ProblemEntity> problems,
  ) async {
    // Implementação simplificada
    if (problems.isNotEmpty) {
      final criticalProblem = problems.firstWhere(
        (p) => p.severity == ProblemSeverity.critical,
        orElse: () => problems.first,
      );

      return NextActionModel(
        id: 'action_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Resolver: ${criticalProblem.title}',
        description: 'Este problema precisa de atenção imediata',
        priority: ActionPriority.critical,
        type: ActionType.other,
        category: ActionCategory.general,
        reason: 'Problema crítico identificado',
        phaseId: criticalProblem.phaseId,
        phaseName: 'Fase Atual',
        blockedBy: [],
        deadline: null,
        metadata: {'problemId': criticalProblem.id},
      );
    }

    return null;
  }

  Future<List<dynamic>> _getProjectPhases(String projectId) async {
    // Implementação simplificada - retorna lista vazia
    // Na implementação real, buscar as fases do projeto
    return [];
  }

  List<String> _generatePositiveMessages(
    ReformProgressModel progress,
    FinancialSnapshotModel financial,
    List<ProblemEntity> problems,
  ) {
    final messages = <String>[];

    if (progress.completedPercentage >= 50) {
      messages.add('Você já concluiu mais da metade da reforma! 🎉');
    }

    if (problems.isEmpty) {
      messages.add('Nenhum problema crítico encontrado.');
    }

    if (financial.percentageSpent <= 80) {
      messages.add('Sua reforma está dentro do orçamento.');
    }

    if (messages.isEmpty) {
      messages.add('Continue assim! Você está no caminho certo.');
    }

    return messages;
  }

  // Métodos faltantes da interface

  @override
  Future<Either<Failure, void>> completeAction(
    String projectId,
    String actionId,
  ) async {
    try {
      await _firestore.collection('reform_actions').doc(actionId).update({
        'completed': true,
        'completedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao completar ação: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> skipAction(
    String projectId,
    String actionId,
    String reason,
  ) async {
    try {
      await _firestore.collection('reform_actions').doc(actionId).update({
        'skipped': true,
        'skipReason': reason,
        'skippedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao pular ação: $e'));
    }
  }

  @override
  Future<Either<Failure, PhaseContext>> getPhaseContext(
    String projectId,
    String phaseId,
  ) async {
    try {
      // Buscar dados relacionados à fase
      final suppliers = await _firestore
          .collection('suppliers')
          .where('projectId', isEqualTo: projectId)
          .where('phaseId', isEqualTo: phaseId)
          .get();

      final purchases = await _firestore
          .collection('shopping_items')
          .where('projectId', isEqualTo: projectId)
          .where('phaseId', isEqualTo: phaseId)
          .get();

      final documents = await _firestore
          .collection('documents')
          .where('projectId', isEqualTo: projectId)
          .where('phaseId', isEqualTo: phaseId)
          .get();

      final payments = await _firestore
          .collection('installments')
          .where('projectId', isEqualTo: projectId)
          .where('phaseId', isEqualTo: phaseId)
          .get();

      final phase = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('phases')
          .doc(phaseId)
          .get();

      final phaseData = phase.data() ?? {};

      return Right(PhaseContext(
        phaseId: phaseId,
        phaseName: phaseData['name'] ?? '',
        relatedSuppliers: suppliers.docs.length,
        relatedPurchases: purchases.docs.length,
        relatedDocuments: documents.docs.length,
        relatedPayments: payments.docs.length,
        expectedDocuments:
            List<String>.from(phaseData['expectedDocuments'] ?? []),
        commonMistakes: List<String>.from(phaseData['commonMistakes'] ?? []),
      ));
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar contexto da fase: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProblemEntity>>> getOpenProblems(
    String projectId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('problems')
          .where('projectId', isEqualTo: projectId)
          .where('status', whereIn: ['open', 'inProgress'])
          .orderBy('severity', descending: true)
          .get();

      final problems = snapshot.docs
          .map((doc) => ProblemModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      return Right(problems);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar problemas abertos: $e'));
    }
  }

  @override
  Future<Either<Failure, List<HealthSnapshot>>> getHealthHistory(
    String projectId, {
    int days = 30,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      final snapshot = await _firestore
          .collection('health_history')
          .where('projectId', isEqualTo: projectId)
          .where('calculatedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(cutoffDate))
          .orderBy('calculatedAt', descending: true)
          .get();

      final history = snapshot.docs.map((doc) {
        final data = doc.data();
        final score = (data['score'] as num).toDouble();
        return HealthSnapshot(
          date: (data['calculatedAt'] as Timestamp).toDate(),
          healthScore: score,
          status: score.toHealthStatus(),
        );
      }).toList();

      return Right(history);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar histórico de saúde: $e'));
    }
  }
}

// Made with Bob
