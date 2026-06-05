import 'package:equatable/equatable.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import 'reform_health_entity.dart';
import 'next_action_entity.dart';
import 'problem_entity.dart';

/// Entidade principal do Mapa da Reforma
/// Agrega todas as informações necessárias para exibir o estado completo da reforma
class ReformMapEntity extends Equatable {
  final String projectId;
  final List<PhaseEntity> phases;
  final PhaseEntity? currentPhase;
  final ReformHealthEntity health;
  final NextActionEntity? nextAction;
  final List<ProblemEntity> openProblems;
  final List<ProblemEntity> problems; // Alias para openProblems
  final ReformProgress progress;
  final FinancialSnapshot financial;
  final List<String> positiveMessages;
  final DateTime lastUpdated;

  const ReformMapEntity({
    required this.projectId,
    required this.phases,
    this.currentPhase,
    required this.health,
    this.nextAction,
    required this.openProblems,
    required this.progress,
    required this.financial,
    required this.positiveMessages,
    required this.lastUpdated,
  }) : problems = openProblems;

  /// Retorna a fase atual ou a próxima disponível
  PhaseEntity? get activePhase {
    if (currentPhase != null) return currentPhase;

    // Buscar primeira fase não concluída
    return phases.firstWhere(
      (phase) =>
          phase.status != PhaseStatus.done &&
          phase.status != PhaseStatus.doneNoRecord,
      orElse: () => phases.last,
    );
  }

  /// Verifica se há problemas críticos
  bool get hasCriticalProblems {
    return openProblems.any((p) => p.severity == ProblemSeverity.critical);
  }

  /// Verifica se está atrasado
  bool get isDelayed {
    return progress.daysDelayed > 0;
  }

  /// Verifica se está acima do orçamento
  bool get isOverBudget {
    return financial.percentageSpent > 100;
  }

  ReformMapEntity copyWith({
    String? projectId,
    List<PhaseEntity>? phases,
    PhaseEntity? currentPhase,
    ReformHealthEntity? health,
    NextActionEntity? nextAction,
    List<ProblemEntity>? openProblems,
    ReformProgress? progress,
    FinancialSnapshot? financial,
    List<String>? positiveMessages,
    DateTime? lastUpdated,
  }) {
    return ReformMapEntity(
      projectId: projectId ?? this.projectId,
      phases: phases ?? this.phases,
      currentPhase: currentPhase ?? this.currentPhase,
      health: health ?? this.health,
      nextAction: nextAction ?? this.nextAction,
      openProblems: openProblems ?? this.openProblems,
      progress: progress ?? this.progress,
      financial: financial ?? this.financial,
      positiveMessages: positiveMessages ?? this.positiveMessages,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        projectId,
        phases,
        currentPhase,
        health,
        nextAction,
        openProblems,
        progress,
        financial,
        positiveMessages,
        lastUpdated,
      ];
}

/// Progresso geral da reforma
class ReformProgress extends Equatable {
  final int totalPhases;
  final int completedPhases;
  final int inProgressPhases;
  final double completedPercentage; // Renomeado de overallPercentage
  final DateTime? estimatedEndDate; // Renomeado de estimatedCompletion
  final int daysRemaining;
  final int daysDelayed;

  const ReformProgress({
    required this.totalPhases,
    required this.completedPhases,
    required this.inProgressPhases,
    required this.completedPercentage,
    this.estimatedEndDate,
    required this.daysRemaining,
    required this.daysDelayed,
  });

  bool get isOnTrack => daysDelayed == 0;
  bool get isNearCompletion => completedPercentage >= 80;

  @override
  List<Object?> get props => [
        totalPhases,
        completedPhases,
        inProgressPhases,
        completedPercentage,
        estimatedEndDate,
        daysRemaining,
        daysDelayed,
      ];
}

/// Snapshot financeiro simplificado
class FinancialSnapshot extends Equatable {
  final double totalBudget;
  final double totalSpent;
  final double remainingBudget; // Renomeado de remaining
  final double percentageSpent; // Renomeado de percentageUsed
  final int pendingPayments;
  final double nextPaymentAmount;
  final DateTime? nextPaymentDate;

  const FinancialSnapshot({
    required this.totalBudget,
    required this.totalSpent,
    required this.remainingBudget,
    required this.percentageSpent,
    required this.pendingPayments,
    required this.nextPaymentAmount,
    this.nextPaymentDate,
  });

  bool get isHealthy => percentageSpent <= 80;
  bool get isWarning => percentageSpent > 80 && percentageSpent <= 100;
  bool get isCritical => percentageSpent > 100;

  @override
  List<Object?> get props => [
        totalBudget,
        totalSpent,
        remainingBudget,
        percentageSpent,
        pendingPayments,
        nextPaymentAmount,
        nextPaymentDate,
      ];
}

/// Informações contextuais de uma fase para o mapa
class PhaseContext extends Equatable {
  final String phaseId;
  final String phaseName;
  final int relatedSuppliers;
  final int relatedPurchases;
  final int relatedDocuments;
  final int relatedPayments;
  final List<String> expectedDocuments;
  final List<String> commonMistakes;

  const PhaseContext({
    required this.phaseId,
    required this.phaseName,
    required this.relatedSuppliers,
    required this.relatedPurchases,
    required this.relatedDocuments,
    required this.relatedPayments,
    required this.expectedDocuments,
    required this.commonMistakes,
  });

  @override
  List<Object?> get props => [
        phaseId,
        phaseName,
        relatedSuppliers,
        relatedPurchases,
        relatedDocuments,
        relatedPayments,
        expectedDocuments,
        commonMistakes,
      ];
}

// Made with Bob
