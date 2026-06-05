import '../../../projects/data/models/phase_model.dart';
import '../../domain/entities/reform_map_entity.dart';
import 'next_action_model.dart';
import 'problem_model.dart';
import 'reform_health_model.dart';

/// Model para serialização do mapa completo da reforma
class ReformMapModel extends ReformMapEntity {
  const ReformMapModel({
    required super.projectId,
    required super.phases,
    super.currentPhase,
    required super.health,
    super.nextAction,
    required super.openProblems,
    required super.progress,
    required super.financial,
    required super.positiveMessages,
    required super.lastUpdated,
  });

  factory ReformMapModel.fromMap(Map<String, dynamic> map) {
    return ReformMapModel(
      projectId: map['projectId'] as String,
      phases: (map['phases'] as List<dynamic>)
          .map((p) => PhaseModel.fromMap(p as Map<String, dynamic>))
          .toList(),
      currentPhase: map['currentPhase'] != null
          ? PhaseModel.fromMap(map['currentPhase'] as Map<String, dynamic>)
          : null,
      health: ReformHealthModel.fromMap(map['health'] as Map<String, dynamic>),
      nextAction: map['nextAction'] != null
          ? NextActionModel.fromMap(map['nextAction'] as Map<String, dynamic>)
          : null,
      openProblems: (map['openProblems'] as List<dynamic>)
          .map((p) => ProblemModel.fromMap(p as Map<String, dynamic>))
          .toList(),
      progress: ReformProgressModel.fromMap(
        map['progress'] as Map<String, dynamic>,
      ),
      financial: FinancialSnapshotModel.fromMap(
        map['financial'] as Map<String, dynamic>,
      ),
      positiveMessages: (map['positiveMessages'] as List<dynamic>)
          .map((m) => m as String)
          .toList(),
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'phases': phases.map((p) => (p as PhaseModel).toMap()).toList(),
      'currentPhase':
          currentPhase != null ? (currentPhase as PhaseModel).toMap() : null,
      'health': (health as ReformHealthModel).toMap(),
      'nextAction':
          nextAction != null ? (nextAction as NextActionModel).toMap() : null,
      'openProblems':
          openProblems.map((p) => (p as ProblemModel).toMap()).toList(),
      'progress': (progress as ReformProgressModel).toMap(),
      'financial': (financial as FinancialSnapshotModel).toMap(),
      'positiveMessages': positiveMessages,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory ReformMapModel.fromEntity(ReformMapEntity entity) {
    return ReformMapModel(
      projectId: entity.projectId,
      phases: entity.phases.map((p) => PhaseModel.fromEntity(p)).toList(),
      currentPhase: entity.currentPhase != null
          ? PhaseModel.fromEntity(entity.currentPhase!)
          : null,
      health: ReformHealthModel.fromEntity(entity.health),
      nextAction: entity.nextAction != null
          ? NextActionModel.fromEntity(entity.nextAction!)
          : null,
      openProblems:
          entity.openProblems.map((p) => ProblemModel.fromEntity(p)).toList(),
      progress: ReformProgressModel.fromEntity(entity.progress),
      financial: FinancialSnapshotModel.fromEntity(entity.financial),
      positiveMessages: entity.positiveMessages,
      lastUpdated: entity.lastUpdated,
    );
  }
}

/// Model para progresso da reforma
class ReformProgressModel extends ReformProgress {
  const ReformProgressModel({
    required super.totalPhases,
    required super.completedPhases,
    required super.inProgressPhases,
    required super.completedPercentage,
    super.estimatedEndDate,
    required super.daysRemaining,
    required super.daysDelayed,
  });

  factory ReformProgressModel.fromMap(Map<String, dynamic> map) {
    return ReformProgressModel(
      totalPhases: map['totalPhases'] as int,
      completedPhases: map['completedPhases'] as int,
      inProgressPhases: map['inProgressPhases'] as int,
      completedPercentage: (map['completedPercentage'] as num).toDouble(),
      estimatedEndDate: map['estimatedEndDate'] != null
          ? DateTime.parse(map['estimatedEndDate'] as String)
          : null,
      daysRemaining: map['daysRemaining'] as int,
      daysDelayed: map['daysDelayed'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalPhases': totalPhases,
      'completedPhases': completedPhases,
      'inProgressPhases': inProgressPhases,
      'completedPercentage': completedPercentage,
      'estimatedEndDate': estimatedEndDate?.toIso8601String(),
      'daysRemaining': daysRemaining,
      'daysDelayed': daysDelayed,
    };
  }

  factory ReformProgressModel.fromEntity(ReformProgress entity) {
    return ReformProgressModel(
      totalPhases: entity.totalPhases,
      completedPhases: entity.completedPhases,
      inProgressPhases: entity.inProgressPhases,
      completedPercentage: entity.completedPercentage,
      estimatedEndDate: entity.estimatedEndDate,
      daysRemaining: entity.daysRemaining,
      daysDelayed: entity.daysDelayed,
    );
  }
}

/// Model para snapshot financeiro
class FinancialSnapshotModel extends FinancialSnapshot {
  const FinancialSnapshotModel({
    required super.totalBudget,
    required super.totalSpent,
    required super.remainingBudget,
    required super.percentageSpent,
    required super.pendingPayments,
    required super.nextPaymentAmount,
    super.nextPaymentDate,
  });

  factory FinancialSnapshotModel.fromMap(Map<String, dynamic> map) {
    return FinancialSnapshotModel(
      totalBudget: (map['totalBudget'] as num).toDouble(),
      totalSpent: (map['totalSpent'] as num).toDouble(),
      remainingBudget: (map['remainingBudget'] as num).toDouble(),
      percentageSpent: (map['percentageSpent'] as num).toDouble(),
      pendingPayments: map['pendingPayments'] as int,
      nextPaymentAmount: (map['nextPaymentAmount'] as num).toDouble(),
      nextPaymentDate: map['nextPaymentDate'] != null
          ? DateTime.parse(map['nextPaymentDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalBudget': totalBudget,
      'totalSpent': totalSpent,
      'remainingBudget': remainingBudget,
      'percentageSpent': percentageSpent,
      'pendingPayments': pendingPayments,
      'nextPaymentAmount': nextPaymentAmount,
      'nextPaymentDate': nextPaymentDate?.toIso8601String(),
    };
  }

  factory FinancialSnapshotModel.fromEntity(FinancialSnapshot entity) {
    return FinancialSnapshotModel(
      totalBudget: entity.totalBudget,
      totalSpent: entity.totalSpent,
      remainingBudget: entity.remainingBudget,
      percentageSpent: entity.percentageSpent,
      pendingPayments: entity.pendingPayments,
      nextPaymentAmount: entity.nextPaymentAmount,
      nextPaymentDate: entity.nextPaymentDate,
    );
  }
}

// Made with Bob
