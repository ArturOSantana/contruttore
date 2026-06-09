import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../projects/data/models/phase_model.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../../../../core/error/failures.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../../domain/entities/next_action_entity.dart';
import '../../domain/entities/next_step_preparation_entity.dart';
import '../../domain/entities/problem_entity.dart';
import '../../domain/entities/reform_health_entity.dart';
import '../../domain/entities/reform_map_entity.dart';
import '../../domain/entities/upcoming_expenses_entity.dart';
import '../../domain/entities/reform_calendar_entity.dart';
import '../../domain/repositories/reform_map_repository.dart';
import '../models/next_action_model.dart';
import '../models/next_step_preparation_model.dart';
import '../models/problem_model.dart';
import '../models/reform_health_model.dart';
import '../models/reform_map_model.dart';
import '../models/upcoming_expenses_model.dart';

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

      // Buscar data planejada de mudança
      final plannedMoveInDate = projectData['plannedMoveInDate'] != null
          ? (projectData['plannedMoveInDate'] as Timestamp).toDate()
          : null;

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
        plannedMoveInDate: plannedMoveInDate,
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
    // Buscar dados necessários em paralelo
    final results = await Future.wait([
      _firestore
          .collection('projects')
          .doc(projectId)
          .collection('phases')
          .get(),
      _firestore
          .collection('projects')
          .doc(projectId)
          .collection('expenses')
          .get(),
      _firestore
          .collection('projects')
          .doc(projectId)
          .collection('installments')
          .where('status', isEqualTo: 'pending')
          .get(),
    ]);

    final phasesSnapshot = results[0] as QuerySnapshot;
    final expensesSnapshot = results[1] as QuerySnapshot;
    final installmentsSnapshot = results[2] as QuerySnapshot;

    // FATOR 1: PRAZO (25%)
    double deadlineScore = 100.0;
    final estimatedEndDate = projectData['estimatedEndDate'] != null
        ? DateTime.parse(projectData['estimatedEndDate'] as String)
        : null;

    if (estimatedEndDate != null) {
      final now = DateTime.now();
      final daysRemaining = estimatedEndDate.difference(now).inDays;

      if (daysRemaining < 0) {
        // Atrasado
        final daysDelayed = daysRemaining.abs();
        if (daysDelayed > 30) {
          deadlineScore = 0.0; // Muito atrasado
        } else if (daysDelayed > 15) {
          deadlineScore = 30.0; // Atrasado
        } else {
          deadlineScore = 60.0; // Levemente atrasado
        }
      } else if (daysRemaining < 7) {
        deadlineScore = 70.0; // Prazo apertado
      } else if (daysRemaining < 15) {
        deadlineScore = 85.0; // Prazo próximo
      }
    }

    // FATOR 2: ORÇAMENTO (30%)
    double budgetScore = 100.0;
    final totalBudget = (projectData['totalBudget'] as num?)?.toDouble() ?? 0.0;
    final totalSpent = (projectData['totalSpent'] as num?)?.toDouble() ?? 0.0;
    final totalPending =
        (projectData['totalPending'] as num?)?.toDouble() ?? 0.0;

    if (totalBudget > 0) {
      final totalCommitted = totalSpent + totalPending;
      final percentageUsed = (totalCommitted / totalBudget) * 100;

      if (percentageUsed > 110) {
        budgetScore = 0.0; // Muito acima do orçamento
      } else if (percentageUsed > 100) {
        budgetScore = 30.0; // Acima do orçamento
      } else if (percentageUsed > 90) {
        budgetScore = 60.0; // Próximo do limite
      } else if (percentageUsed > 80) {
        budgetScore = 80.0; // Atenção
      } else if (percentageUsed > 70) {
        budgetScore = 90.0; // Bom
      }
    }

    // FATOR 3: PROBLEMAS (20%)
    double problemsScore = 100.0;
    if (problems.isNotEmpty) {
      final criticalCount =
          problems.where((p) => p.severity == ProblemSeverity.critical).length;
      final highCount =
          problems.where((p) => p.severity == ProblemSeverity.high).length;
      final mediumCount =
          problems.where((p) => p.severity == ProblemSeverity.medium).length;

      // Penalizar por severidade
      final problemImpact =
          (criticalCount * 30) + (highCount * 15) + (mediumCount * 5);
      problemsScore = (100.0 - problemImpact).clamp(0.0, 100.0).toDouble();
    }

    // FATOR 4: TAREFAS PENDENTES (15%)
    double tasksScore = 100.0;
    int totalSubtasks = 0;
    int completedSubtasks = 0;

    for (final phaseDoc in phasesSnapshot.docs) {
      final phaseData = phaseDoc.data() as Map<String, dynamic>;
      final subtasks = phaseData['subtasks'] as List<dynamic>? ?? [];

      for (final subtask in subtasks) {
        totalSubtasks++;
        if (subtask['isDone'] == true) {
          completedSubtasks++;
        }
      }
    }

    if (totalSubtasks > 0) {
      final completionRate = (completedSubtasks / totalSubtasks) * 100;
      tasksScore = completionRate;
    }

    // FATOR 5: PAGAMENTOS (10%)
    double paymentsScore = 100.0;
    int overdueCount = 0;

    for (final installmentDoc in installmentsSnapshot.docs) {
      final installmentData = installmentDoc.data() as Map<String, dynamic>;
      final dueDate = installmentData['dueDate'] != null
          ? DateTime.parse(installmentData['dueDate'] as String)
          : null;

      if (dueDate != null && dueDate.isBefore(DateTime.now())) {
        overdueCount++;
      }
    }

    if (overdueCount > 0) {
      if (overdueCount > 5) {
        paymentsScore = 0.0; // Muitos pagamentos atrasados
      } else if (overdueCount > 3) {
        paymentsScore = 40.0; // Vários pagamentos atrasados
      } else if (overdueCount > 1) {
        paymentsScore = 70.0; // Alguns pagamentos atrasados
      } else {
        paymentsScore = 85.0; // Um pagamento atrasado
      }
    }

    // CÁLCULO FINAL
    final score = (deadlineScore * 0.25) +
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

    // Calcular nível visual (v2.0)
    final level = score >= 80
        ? HealthLevel.healthy
        : score >= 50
            ? HealthLevel.attention
            : HealthLevel.critical;

    // Gerar mensagem amigável
    final message = _getHealthMessage(score, problems.isEmpty);

    // Gerar lista de issues
    final issues = <String>[];
    if (problems.isNotEmpty) {
      issues.add('${problems.length} problema(s) ativo(s)');
    }
    if (score < 80) {
      issues.add('Alguns pontos precisam de atenção');
    }

    // Gerar lista de positives
    final positives = <String>[];
    if (problems.isEmpty) {
      positives.add('Nenhum problema ativo');
    }
    if (score >= 80) {
      positives.add('Reforma está no caminho certo');
    }

    return ReformHealthModel(
      score: score,
      level: level,
      message: message,
      issues: issues,
      positives: positives,
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

  String _getHealthMessage(double score, bool noIssues) {
    if (score >= 80 && noIssues) {
      return 'Sua reforma está sob controle';
    } else if (score >= 80) {
      return 'Sua reforma está indo bem';
    } else if (score >= 50) {
      return 'Existem alguns pontos para acompanhar';
    } else {
      return 'Existem pendências que podem impactar prazo e custo';
    }
  }

  Future<NextActionModel?> _calculateNextAction(
    String projectId,
    Map<String, dynamic> projectData,
    List<ProblemEntity> problems,
  ) async {
    // Buscar dados necessários em paralelo
    final results = await Future.wait([
      _firestore
          .collection('projects')
          .doc(projectId)
          .collection('phases')
          .where('status', isEqualTo: 'inProgress')
          .get(),
      _firestore
          .collection('projects')
          .doc(projectId)
          .collection('installments')
          .where('status', isEqualTo: 'pending')
          .orderBy('dueDate')
          .limit(1)
          .get(),
      _firestore
          .collection('projects')
          .doc(projectId)
          .collection('shopping')
          .where('isPurchased', isEqualTo: false)
          .where('isRequired', isEqualTo: true)
          .limit(1)
          .get(),
    ]);

    final phasesSnapshot = results[0] as QuerySnapshot;
    final installmentsSnapshot = results[1] as QuerySnapshot;
    final shoppingSnapshot = results[2] as QuerySnapshot;

    // PRIORIDADE 1: Problemas Críticos
    if (problems.isNotEmpty) {
      final criticalProblem = problems.firstWhere(
        (p) => p.severity == ProblemSeverity.critical,
        orElse: () => problems.first,
      );

      return NextActionModel(
        id: 'action_problem_${DateTime.now().millisecondsSinceEpoch}',
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

    // PRIORIDADE 2: Pagamentos Vencidos ou Próximos (Financeiro)
    if (installmentsSnapshot.docs.isNotEmpty) {
      final installmentData =
          installmentsSnapshot.docs.first.data() as Map<String, dynamic>;
      final dueDate = installmentData['dueDate'] != null
          ? DateTime.parse(installmentData['dueDate'] as String)
          : null;

      if (dueDate != null) {
        final daysUntilDue = dueDate.difference(DateTime.now()).inDays;

        if (daysUntilDue <= 0) {
          // Vencido
          return NextActionModel(
            id: 'action_payment_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Pagar parcela vencida',
            description:
                'Parcela de ${installmentData['description']} está vencida',
            priority: ActionPriority.critical,
            type: ActionType.payment,
            category: ActionCategory.financial,
            reason: 'Pagamento vencido há ${daysUntilDue.abs()} dia(s)',
            phaseId: installmentData['phaseId'],
            phaseName: installmentData['phaseName'] ?? 'Fase',
            blockedBy: [],
            deadline: dueDate,
            metadata: {
              'installmentId': installmentsSnapshot.docs.first.id,
              'amount': installmentData['amount'],
            },
          );
        } else if (daysUntilDue <= 3) {
          // Próximo do vencimento
          return NextActionModel(
            id: 'action_payment_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Pagar parcela',
            description:
                'Parcela de ${installmentData['description']} vence em $daysUntilDue dia(s)',
            priority: ActionPriority.high,
            type: ActionType.payment,
            category: ActionCategory.financial,
            reason: 'Pagamento próximo do vencimento',
            phaseId: installmentData['phaseId'],
            phaseName: installmentData['phaseName'] ?? 'Fase',
            blockedBy: [],
            deadline: dueDate,
            metadata: {
              'installmentId': installmentsSnapshot.docs.first.id,
              'amount': installmentData['amount'],
            },
          );
        }
      }
    }

    // PRIORIDADE 3: Compras Obrigatórias Pendentes
    if (shoppingSnapshot.docs.isNotEmpty) {
      final shoppingData =
          shoppingSnapshot.docs.first.data() as Map<String, dynamic>;

      return NextActionModel(
        id: 'action_shopping_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Comprar: ${shoppingData['name']}',
        description: 'Item obrigatório para continuar a reforma',
        priority: ActionPriority.high,
        type: ActionType.purchase,
        category: ActionCategory.shopping,
        reason: 'Compra necessária para próxima etapa',
        phaseId: shoppingData['phaseId'],
        phaseName: shoppingData['phaseName'] ?? 'Fase',
        blockedBy: [],
        deadline: null,
        metadata: {
          'shoppingId': shoppingSnapshot.docs.first.id,
          'estimatedPrice': shoppingData['estimatedPrice'],
        },
      );
    }

    // PRIORIDADE 4: Tarefas da Fase Atual
    if (phasesSnapshot.docs.isNotEmpty) {
      final phaseData =
          phasesSnapshot.docs.first.data() as Map<String, dynamic>;
      final subtasks = phaseData['subtasks'] as List<dynamic>? ?? [];

      // Buscar primeira subtarefa não concluída
      for (final subtask in subtasks) {
        if (subtask['isDone'] != true) {
          return NextActionModel(
            id: 'action_task_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Concluir: ${subtask['name']}',
            description: 'Tarefa da fase ${phaseData['name']}',
            priority: subtask['isRequired'] == true
                ? ActionPriority.high
                : ActionPriority.medium,
            type: ActionType.other,
            category: ActionCategory.phase,
            reason: 'Próxima tarefa da fase atual',
            phaseId: phasesSnapshot.docs.first.id,
            phaseName: phaseData['name'] ?? 'Fase',
            blockedBy: [],
            deadline: null,
            metadata: {
              'subtaskId': subtask['id'],
            },
          );
        }
      }
    }

    // PRIORIDADE 5: Orçamento Excedido
    final totalBudget = (projectData['totalBudget'] as num?)?.toDouble() ?? 0.0;
    final totalSpent = (projectData['totalSpent'] as num?)?.toDouble() ?? 0.0;

    if (totalBudget > 0 && totalSpent > totalBudget) {
      return NextActionModel(
        id: 'action_budget_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Revisar orçamento',
        description: 'Gastos ultrapassaram o orçamento planejado',
        priority: ActionPriority.high,
        type: ActionType.other,
        category: ActionCategory.financial,
        reason:
            'Orçamento excedido em R\$ ${(totalSpent - totalBudget).toStringAsFixed(2)}',
        phaseId: null,
        phaseName: null,
        blockedBy: [],
        deadline: null,
        metadata: {
          'totalBudget': totalBudget,
          'totalSpent': totalSpent,
          'exceeded': totalSpent - totalBudget,
        },
      );
    }

    // Nenhuma ação prioritária encontrada
    return null;
  }

  Future<List<PhaseEntity>> _getProjectPhases(String projectId) async {
    try {
      final phasesSnapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('phases')
          .orderBy('number')
          .get();

      if (phasesSnapshot.docs.isEmpty) {
        return [];
      }

      return phasesSnapshot.docs.map((doc) {
        final data = doc.data();
        return PhaseModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print('Erro ao buscar fases: $e');
      return [];
    }
  }

  List<String> _generatePositiveMessages(
    ReformProgressModel progress,
    FinancialSnapshotModel financial,
    List<ProblemEntity> problems,
  ) {
    final messages = <String>[];

    if (progress.completedPercentage >= 50) {
      messages.add('Você já concluiu mais da metade da reforma! ');
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

  @override
  Future<Either<Failure, UpcomingExpensesEntity>> calculateUpcomingExpenses(
    String projectId,
    int days,
  ) async {
    try {
      final now = DateTime.now();
      final targetDate = now.add(Duration(days: days));

      // Buscar parcelas futuras
      final installmentsSnapshot = await _firestore
          .collection('installments')
          .where('projectId', isEqualTo: projectId)
          .where('status', isEqualTo: 'pending')
          .where('dueDate', isGreaterThanOrEqualTo: now.toIso8601String())
          .where('dueDate', isLessThanOrEqualTo: targetDate.toIso8601String())
          .orderBy('dueDate')
          .get();

      final expenses = <ExpensePreviewEntity>[];

      for (final doc in installmentsSnapshot.docs) {
        final data = doc.data();
        final estimatedDate = DateTime.parse(data['dueDate'] as String);
        final amount = (data['amount'] as num).toDouble();
        final description = data['description'] as String? ?? 'Parcela';
        final category = data['category'] as String? ?? 'Geral';
        final stepName = data['phaseName'] as String? ?? 'Fase';
        final isCommitted = data['isCommitted'] as bool? ?? true;

        expenses.add(ExpensePreviewEntity(
          id: doc.id,
          stepName: stepName,
          category: category,
          amount: amount,
          estimatedDate: estimatedDate,
          isCommitted: isCommitted,
          description: description,
          supplierId: data['supplierId'] as String?,
        ));
      }

      // Calcular total
      final totalAmount = expenses.fold<double>(0, (sum, e) => sum + e.amount);

      // Buscar orçamento disponível
      final projectDoc =
          await _firestore.collection('projects').doc(projectId).get();
      final projectData = projectDoc.data() ?? {};
      final availableBudget =
          (projectData['remainingBudget'] as num?)?.toDouble() ?? 0.0;

      final result = UpcomingExpensesModel(
        days: days,
        expenses: expenses,
        totalAmount: totalAmount,
        availableBudget: availableBudget,
        calculatedAt: DateTime.now(),
      );

      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Erro ao calcular despesas futuras: $e'));
    }
  }

  @override
  Future<Either<Failure, NextStepPreparationEntity>> getNextStepPreparation(
    String projectId,
  ) async {
    try {
      // Buscar fases do projeto
      final phasesSnapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('phases')
          .orderBy('order')
          .get();

      if (phasesSnapshot.docs.isEmpty) {
        return Left(ServerFailure('Nenhuma fase encontrada'));
      }

      // Encontrar próxima fase (primeira que não está concluída)
      final phases = phasesSnapshot.docs;
      final nextPhaseDoc = phases.firstWhere(
        (doc) => doc.data()['status'] != 'done',
        orElse: () => phases.last,
      );

      final nextPhaseData = nextPhaseDoc.data();
      final nextPhaseId = nextPhaseDoc.id;
      final nextPhaseName = nextPhaseData['name'] as String? ?? 'Próxima Fase';

      // Criar checklist de preparação
      final preparationItems = <PreparationItemEntity>[
        const PreparationItemEntity(
          id: 'prep_1',
          name: 'Definir materiais necessários',
          description: 'Liste todos os materiais que serão usados nesta fase',
          isDone: false,
          isRequired: true,
        ),
        const PreparationItemEntity(
          id: 'prep_2',
          name: 'Contratar profissionais',
          description: 'Busque e contrate os profissionais necessários',
          isDone: false,
          isRequired: true,
        ),
        const PreparationItemEntity(
          id: 'prep_3',
          name: 'Organizar documentação',
          description: 'Prepare contratos e documentos necessários',
          isDone: false,
          isRequired: false,
        ),
        const PreparationItemEntity(
          id: 'prep_4',
          name: 'Verificar orçamento',
          description: 'Confirme que há orçamento disponível para esta fase',
          isDone: false,
          isRequired: true,
        ),
      ];

      final completedCount = preparationItems.where((i) => i.isDone).length;
      final progressPercent =
          (completedCount / preparationItems.length * 100).toDouble();

      final result = NextStepPreparationModel(
        stepId: nextPhaseId,
        stepName: nextPhaseName,
        progressPercent: progressPercent,
        items: preparationItems,
        estimatedStartDate: nextPhaseData['estimatedStartDate'] != null
            ? DateTime.parse(nextPhaseData['estimatedStartDate'] as String)
            : null,
      );

      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar preparação: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePreparationItem(
    String projectId,
    String stepId,
    String itemId,
    bool isDone,
  ) async {
    try {
      // Buscar preparação atual
      final prepDoc = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('preparation')
          .doc(stepId)
          .get();

      if (!prepDoc.exists) {
        return Left(ServerFailure('Preparação não encontrada'));
      }

      final prepData = prepDoc.data()!;
      final items = List<Map<String, dynamic>>.from(
        prepData['items'] ?? [],
      );

      // Atualizar item
      final itemIndex = items.indexWhere((item) => item['id'] == itemId);
      if (itemIndex == -1) {
        return Left(ServerFailure('Item não encontrado'));
      }

      items[itemIndex]['isDone'] = isDone;
      if (isDone) {
        items[itemIndex]['completedAt'] = DateTime.now().toIso8601String();
      } else {
        items[itemIndex]['completedAt'] = null;
      }

      // Recalcular progresso
      final completedCount =
          items.where((item) => item['isDone'] == true).length;
      final progressPercent = (completedCount / items.length * 100).toDouble();

      // Atualizar no Firestore
      await prepDoc.reference.update({
        'items': items,
        'progressPercent': progressPercent,
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar item de preparação: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addCalendarEvent({
    required String projectId,
    required CalendarEventEntity event,
  }) async {
    try {
      // Converter entity para map
      final eventData = {
        'id': event.id,
        'title': event.title,
        'description': event.description,
        'date': Timestamp.fromDate(event.date),
        'type': event.type.toString().split('.').last,
        'priority': event.priority.toString().split('.').last,
        'isCompleted': event.isCompleted,
        'icon': event.icon,
        'color': event.color,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Salvar no Firestore
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('calendar_events')
          .doc(event.id)
          .set(eventData);

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao adicionar evento'));
    } catch (e) {
      return Left(ServerFailure('Erro ao adicionar evento: $e'));
    }
  }
}

// Made with Bob
