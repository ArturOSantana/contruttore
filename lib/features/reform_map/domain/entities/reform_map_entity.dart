import 'package:equatable/equatable.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../../../projects/domain/entities/project_entity.dart';
import 'reform_health_entity.dart';
import 'next_action_entity.dart';
import 'problem_entity.dart';
import 'move_in_distance_entity.dart';
import 'move_in_mode_entity.dart';
import 'pending_decision_entity.dart';
import 'upcoming_purchase_entity.dart';
import 'next_phase_preparation_entity.dart';
import 'milestone_entity.dart';
import 'reform_calendar_entity.dart';
import 'reform_week_entity.dart';
import 'phase_analysis_entity.dart';

/// Entidade principal do Mapa da Reforma
/// Agrega todas as informações necessárias para exibir o estado completo da reforma
class ReformMapEntity extends Equatable {
  final String projectId;
  final List<PhaseEntity> phases;
  final PhaseEntity? currentPhase;
  final ReformHealthEntity health;
  final NextActionEntity? nextAction;
  final MoveInDistanceEntity? moveInDistance;
  final MoveInModeEntity? moveInMode;
  final List<PendingDecisionEntity> pendingDecisions;
  final List<UpcomingPurchaseEntity> upcomingPurchases;
  final NextPhasePreparationEntity? nextPhasePreparation;
  final List<MilestoneEntity> milestones;
  final ReformCalendarEntity? calendar;
  final ReformWeekEntity? week;
  final List<ProblemEntity> openProblems;
  final List<ProblemEntity> problems; // Alias para openProblems
  final ReformProgress progress;
  final FinancialSnapshot financial;
  final List<String> positiveMessages;
  final DateTime lastUpdated;
  final DateTime? plannedMoveInDate;
  final PropertyType propertyType; // Tipo de imóvel para checklist dinâmico
  final Map<String, PhaseAnalysisEntity>
      phasesAnalysis; // Análise detalhada de cada fase

  const ReformMapEntity({
    required this.projectId,
    required this.phases,
    this.currentPhase,
    required this.health,
    this.nextAction,
    this.moveInDistance,
    this.moveInMode,
    this.pendingDecisions = const [],
    this.upcomingPurchases = const [],
    this.nextPhasePreparation,
    this.milestones = const [],
    this.calendar,
    this.week,
    required this.openProblems,
    required this.progress,
    required this.financial,
    required this.positiveMessages,
    required this.lastUpdated,
    this.plannedMoveInDate,
    this.propertyType = PropertyType.house, // Padrão: casa
    this.phasesAnalysis = const {}, // Análises de fases
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
    MoveInDistanceEntity? moveInDistance,
    MoveInModeEntity? moveInMode,
    List<PendingDecisionEntity>? pendingDecisions,
    List<UpcomingPurchaseEntity>? upcomingPurchases,
    NextPhasePreparationEntity? nextPhasePreparation,
    List<MilestoneEntity>? milestones,
    ReformCalendarEntity? calendar,
    ReformWeekEntity? week,
    List<ProblemEntity>? openProblems,
    ReformProgress? progress,
    FinancialSnapshot? financial,
    List<String>? positiveMessages,
    DateTime? lastUpdated,
    DateTime? plannedMoveInDate,
    Map<String, PhaseAnalysisEntity>? phasesAnalysis,
  }) {
    return ReformMapEntity(
      projectId: projectId ?? this.projectId,
      phases: phases ?? this.phases,
      currentPhase: currentPhase ?? this.currentPhase,
      health: health ?? this.health,
      nextAction: nextAction ?? this.nextAction,
      moveInDistance: moveInDistance ?? this.moveInDistance,
      moveInMode: moveInMode ?? this.moveInMode,
      pendingDecisions: pendingDecisions ?? this.pendingDecisions,
      upcomingPurchases: upcomingPurchases ?? this.upcomingPurchases,
      nextPhasePreparation: nextPhasePreparation ?? this.nextPhasePreparation,
      milestones: milestones ?? this.milestones,
      calendar: calendar ?? this.calendar,
      week: week ?? this.week,
      openProblems: openProblems ?? this.openProblems,
      progress: progress ?? this.progress,
      financial: financial ?? this.financial,
      positiveMessages: positiveMessages ?? this.positiveMessages,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      plannedMoveInDate: plannedMoveInDate ?? this.plannedMoveInDate,
      phasesAnalysis: phasesAnalysis ?? this.phasesAnalysis,
    );
  }

  @override
  List<Object?> get props => [
        projectId,
        phases,
        currentPhase,
        health,
        nextAction,
        moveInDistance,
        moveInMode,
        pendingDecisions,
        upcomingPurchases,
        nextPhasePreparation,
        milestones,
        calendar,
        week,
        openProblems,
        progress,
        financial,
        positiveMessages,
        lastUpdated,
        plannedMoveInDate,
        phasesAnalysis,
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
  final double
      totalPending; // Total de parcelas pendentes (comprometido mas não pago)
  final double remainingBudget; // Orçamento restante (sem considerar pendentes)
  final double percentageSpent; // Percentual gasto (apenas o que já foi pago)
  final int pendingPayments; // Quantidade de parcelas pendentes
  final double nextPaymentAmount;
  final DateTime? nextPaymentDate;

  const FinancialSnapshot({
    required this.totalBudget,
    required this.totalSpent,
    this.totalPending = 0.0,
    required this.remainingBudget,
    required this.percentageSpent,
    required this.pendingPayments,
    required this.nextPaymentAmount,
    this.nextPaymentDate,
  });

  /// Total comprometido (gasto + pendente)
  double get totalCommitted => totalSpent + totalPending;

  /// Percentual comprometido (gasto + pendente)
  double get percentageCommitted {
    if (totalBudget == 0) return 0;
    return (totalCommitted / totalBudget) * 100;
  }

  /// Orçamento realmente disponível (considerando pendentes)
  double get availableBudget => totalBudget - totalCommitted;

  /// Verifica se o orçamento comprometido está saudável
  bool get isHealthy => percentageCommitted <= 80;

  /// Verifica se o orçamento comprometido está em alerta
  bool get isWarning => percentageCommitted > 80 && percentageCommitted <= 100;

  /// Verifica se o orçamento comprometido está crítico
  bool get isCritical => percentageCommitted > 100;

  /// Verifica se há risco de estourar o orçamento
  bool get hasRisk => percentageCommitted > 90;

  @override
  List<Object?> get props => [
        totalBudget,
        totalSpent,
        totalPending,
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
