import 'package:injectable/injectable.dart';
import '../entities/move_in_distance_entity.dart';
import '../entities/reform_map_entity.dart';
import '../../../projects/domain/entities/phase_entity.dart';

/// Service responsável por calcular a distância até a mudança
///
/// Analisa o projeto e as fases para determinar:
/// - Quantos dias faltam
/// - Quantas etapas faltam
/// - Quanto dinheiro falta gastar
/// - Qual o próximo marco importante
@injectable
class MoveInDistanceCalculator {
  /// Calcula a distância até a mudança baseado no mapa da reforma
  MoveInDistanceEntity calculate(ReformMapEntity reformMap) {
    final phases = reformMap.phases;
    final project = reformMap.financial;
    final plannedMoveInDate = reformMap.plannedMoveInDate;

    // 1. Calcular percentual de conclusão
    final percentageComplete = _calculatePercentageComplete(phases);

    // 2. Calcular fases restantes
    final phasesRemaining = _calculatePhasesRemaining(phases);

    // 3. Calcular dias restantes (prioriza data planejada se existir)
    final daysRemaining = _calculateDaysRemaining(
      phases: phases,
      percentageComplete: percentageComplete,
      plannedMoveInDate: plannedMoveInDate,
    );

    // 4. Calcular orçamento restante
    final budgetRemaining = project.remainingBudget;

    // 5. Determinar próximo marco
    final nextMilestone = _determineNextMilestone(phases);

    // 6. Calcular data estimada de mudança
    // Se há data planejada e é futura, usar ela. Caso contrário, calcular
    final estimatedMoveDate =
        (plannedMoveInDate != null && plannedMoveInDate.isAfter(DateTime.now()))
            ? plannedMoveInDate
            : DateTime.now().add(Duration(days: daysRemaining));

    return MoveInDistanceEntity(
      daysRemaining: daysRemaining,
      phasesRemaining: phasesRemaining,
      budgetRemaining: budgetRemaining,
      nextMilestone: nextMilestone,
      percentageComplete: percentageComplete,
      estimatedMoveDate: estimatedMoveDate,
      totalPhases: phases.length,
      totalBudget: project.totalBudget,
    );
  }

  /// Calcula o percentual de conclusão baseado nas fases
  int _calculatePercentageComplete(List<PhaseEntity> phases) {
    if (phases.isEmpty) return 0;

    final completedPhases = phases
        .where((phase) =>
            phase.status == PhaseStatus.done ||
            phase.status == PhaseStatus.doneNoRecord)
        .length;

    return ((completedPhases / phases.length) * 100).round();
  }

  /// Calcula quantas fases ainda faltam concluir
  int _calculatePhasesRemaining(List<PhaseEntity> phases) {
    return phases
        .where((phase) =>
            phase.status != PhaseStatus.done &&
            phase.status != PhaseStatus.doneNoRecord)
        .length;
  }

  /// Calcula quantos dias faltam até a mudança
  int _calculateDaysRemaining({
    required List<PhaseEntity> phases,
    required int percentageComplete,
    DateTime? plannedMoveInDate,
  }) {
    // Estratégia 0: Se há data planejada de mudança, usar ela (PRIORIDADE MÁXIMA)
    if (plannedMoveInDate != null) {
      final daysUntilPlannedDate =
          plannedMoveInDate.difference(DateTime.now()).inDays;

      // Se a data planejada é no futuro, usar ela
      if (daysUntilPlannedDate > 0) {
        return daysUntilPlannedDate;
      }

      // Se a data planejada já passou, continuar com outras estratégias
    }

    // Estratégia 1: Se há fases com datas definidas, usar a última
    final phasesWithDates = phases
        .where((phase) => phase.endDate != null)
        .toList()
      ..sort((a, b) => a.endDate!.compareTo(b.endDate!));

    if (phasesWithDates.isNotEmpty) {
      final lastPhaseDate = phasesWithDates.last.endDate!;
      final daysUntilLastPhase =
          lastPhaseDate.difference(DateTime.now()).inDays;

      // Adicionar buffer de 7 dias para mudança
      return daysUntilLastPhase + 7;
    }

    // Estratégia 2: Estimar baseado no progresso
    // Assumindo que uma reforma média leva 120 dias
    const averageReformDays = 120;

    if (percentageComplete > 0) {
      final daysElapsed = (averageReformDays * percentageComplete) / 100;
      final totalEstimatedDays = (daysElapsed / percentageComplete) * 100;
      final daysRemaining = totalEstimatedDays - daysElapsed;

      return daysRemaining.round().clamp(0, 365);
    }

    // Estratégia 3: Estimar baseado no número de fases restantes
    // Assumindo 15 dias por fase em média
    const daysPerPhase = 15;
    final phasesRemaining = _calculatePhasesRemaining(phases);

    return (phasesRemaining * daysPerPhase) + 7; // +7 dias para mudança
  }

  /// Calcula quanto dinheiro ainda falta gastar
  double _calculateBudgetRemaining({
    required double totalBudget,
    required double spentAmount,
  }) {
    final remaining = totalBudget - spentAmount;
    return remaining > 0 ? remaining : 0;
  }

  /// Determina qual é o próximo grande marco
  String _determineNextMilestone(List<PhaseEntity> phases) {
    // Marcos importantes em ordem
    final milestones = {
      'Infraestrutura': 'Infraestrutura concluída',
      'Pisos e Revestimentos': 'Casa pronta para pintura',
      'Pintura': 'Pintura finalizada',
      'Acabamentos': 'Acabamentos instalados',
      'Marcenaria': 'Marcenaria aprovada',
      'Mudança e Decoração': 'Pronto para mudança',
    };

    // Encontrar primeira fase não concluída que seja um marco
    for (final phase in phases) {
      if (phase.status != PhaseStatus.done &&
          phase.status != PhaseStatus.doneNoRecord) {
        // Verificar se o nome da fase contém algum marco
        for (final entry in milestones.entries) {
          if (phase.name.contains(entry.key)) {
            return entry.value;
          }
        }

        // Se não encontrou marco específico, retornar o nome da fase
        return '${phase.name} concluída';
      }
    }

    return 'Mudança finalizada';
  }
}

// Made with Bob
