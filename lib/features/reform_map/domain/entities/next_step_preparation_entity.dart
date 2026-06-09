import 'package:equatable/equatable.dart';

/// Entidade que representa a preparação da próxima etapa
class NextStepPreparationEntity extends Equatable {
  final String stepId;
  final String stepName;
  final double progressPercent; // 0-100
  final List<PreparationItemEntity> items;
  final DateTime? estimatedStartDate;

  const NextStepPreparationEntity({
    required this.stepId,
    required this.stepName,
    required this.progressPercent,
    required this.items,
    this.estimatedStartDate,
  });

  /// Verifica se a preparação está completa
  bool get isReady => progressPercent >= 100;

  /// Verifica se está atrasada
  bool get isLate {
    if (estimatedStartDate == null) return false;
    return DateTime.now().isAfter(estimatedStartDate!) && !isReady;
  }

  /// Dias até o início estimado
  int? get daysUntilStart {
    if (estimatedStartDate == null) return null;
    final diff = estimatedStartDate!.difference(DateTime.now());
    return diff.inDays;
  }

  /// Itens pendentes
  List<PreparationItemEntity> get pendingItems =>
      items.where((item) => !item.isDone).toList();

  /// Itens concluídos
  List<PreparationItemEntity> get completedItems =>
      items.where((item) => item.isDone).toList();

  @override
  List<Object?> get props => [
        stepId,
        stepName,
        progressPercent,
        items,
        estimatedStartDate,
      ];
}

/// Item de preparação da próxima etapa
class PreparationItemEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final bool isDone;
  final bool isRequired; // Se é obrigatório para iniciar a etapa
  final DateTime? completedAt;

  const PreparationItemEntity({
    required this.id,
    required this.name,
    this.description,
    required this.isDone,
    this.isRequired = false,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        isDone,
        isRequired,
        completedAt,
      ];
}

// Made with Bob
