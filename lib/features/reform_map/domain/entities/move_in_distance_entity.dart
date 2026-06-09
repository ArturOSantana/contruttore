import 'package:equatable/equatable.dart';

/// Entidade que representa a distância até a mudança
///
/// Mostra ao usuário de forma humanizada:
/// - Quantos dias faltam
/// - Quantas etapas faltam
/// - Quanto dinheiro falta gastar
/// - Qual o próximo grande marco
class MoveInDistanceEntity extends Equatable {
  /// Número de dias estimados até a mudança
  final int daysRemaining;

  /// Número de etapas que faltam concluir
  final int phasesRemaining;

  /// Valor em reais que ainda falta gastar
  final double budgetRemaining;

  /// Nome do próximo grande marco (ex: "Pintura finalizada")
  final String nextMilestone;

  /// Percentual de conclusão da reforma (0-100)
  final int percentageComplete;

  /// Data estimada da mudança
  final DateTime estimatedMoveDate;

  /// Número total de etapas
  final int totalPhases;

  /// Orçamento total da reforma
  final double totalBudget;

  const MoveInDistanceEntity({
    required this.daysRemaining,
    required this.phasesRemaining,
    required this.budgetRemaining,
    required this.nextMilestone,
    required this.percentageComplete,
    required this.estimatedMoveDate,
    required this.totalPhases,
    required this.totalBudget,
  });

  /// Retorna true se faltam menos de 30 dias
  bool get isCloseToMoveIn => daysRemaining <= 30;

  /// Retorna true se faltam menos de 7 dias
  bool get isVeryCloseToMoveIn => daysRemaining <= 7;

  /// Retorna true se está na última etapa
  bool get isLastPhase => phasesRemaining <= 1;

  /// Retorna mensagem motivacional baseada no progresso
  String get motivationalMessage {
    if (percentageComplete >= 90) {
      return 'Você está quase lá! ';
    } else if (percentageComplete >= 70) {
      return 'Mais da metade concluída! ';
    } else if (percentageComplete >= 50) {
      return 'Você já passou da metade! ';
    } else if (percentageComplete >= 30) {
      return 'Progresso consistente! ';
    } else if (percentageComplete > 0) {
      return 'Ótimo começo! ';
    } else {
      return ''; // Sem mensagem no início
    }
  }

  /// Retorna o percentual gasto do orçamento
  double get budgetPercentageSpent {
    if (totalBudget == 0) return 0;
    return ((totalBudget - budgetRemaining) / totalBudget) * 100;
  }

  /// Retorna true se o orçamento está equilibrado com o progresso
  bool get isBudgetBalanced {
    final budgetSpent = budgetPercentageSpent;
    final progressDiff = (budgetSpent - percentageComplete).abs();
    return progressDiff <= 15; // Diferença de até 15% é aceitável
  }

  @override
  List<Object?> get props => [
        daysRemaining,
        phasesRemaining,
        budgetRemaining,
        nextMilestone,
        percentageComplete,
        estimatedMoveDate,
        totalPhases,
        totalBudget,
      ];

  /// Cria uma cópia com novos valores
  MoveInDistanceEntity copyWith({
    int? daysRemaining,
    int? phasesRemaining,
    double? budgetRemaining,
    String? nextMilestone,
    int? percentageComplete,
    DateTime? estimatedMoveDate,
    int? totalPhases,
    double? totalBudget,
  }) {
    return MoveInDistanceEntity(
      daysRemaining: daysRemaining ?? this.daysRemaining,
      phasesRemaining: phasesRemaining ?? this.phasesRemaining,
      budgetRemaining: budgetRemaining ?? this.budgetRemaining,
      nextMilestone: nextMilestone ?? this.nextMilestone,
      percentageComplete: percentageComplete ?? this.percentageComplete,
      estimatedMoveDate: estimatedMoveDate ?? this.estimatedMoveDate,
      totalPhases: totalPhases ?? this.totalPhases,
      totalBudget: totalBudget ?? this.totalBudget,
    );
  }
}

// Made with Bob
