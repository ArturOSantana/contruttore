import '../../domain/entities/next_step_preparation_entity.dart';

/// Model para serialização da preparação da próxima etapa
class NextStepPreparationModel extends NextStepPreparationEntity {
  const NextStepPreparationModel({
    required super.stepId,
    required super.stepName,
    required super.progressPercent,
    required super.items,
    super.estimatedStartDate,
  });

  factory NextStepPreparationModel.fromMap(Map<String, dynamic> map) {
    return NextStepPreparationModel(
      stepId: map['stepId'] as String,
      stepName: map['stepName'] as String,
      progressPercent: (map['progressPercent'] as num).toDouble(),
      items: (map['items'] as List<dynamic>)
          .map((item) =>
              PreparationItemModel.fromMap(item as Map<String, dynamic>))
          .toList(),
      estimatedStartDate: map['estimatedStartDate'] != null
          ? DateTime.parse(map['estimatedStartDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stepId': stepId,
      'stepName': stepName,
      'progressPercent': progressPercent,
      'items':
          items.map((item) => (item as PreparationItemModel).toMap()).toList(),
      'estimatedStartDate': estimatedStartDate?.toIso8601String(),
    };
  }

  factory NextStepPreparationModel.fromEntity(
      NextStepPreparationEntity entity) {
    return NextStepPreparationModel(
      stepId: entity.stepId,
      stepName: entity.stepName,
      progressPercent: entity.progressPercent,
      items: entity.items
          .map((item) => PreparationItemModel.fromEntity(item))
          .toList(),
      estimatedStartDate: entity.estimatedStartDate,
    );
  }
}

/// Model para item de preparação
class PreparationItemModel extends PreparationItemEntity {
  const PreparationItemModel({
    required super.id,
    required super.name,
    super.description,
    required super.isDone,
    super.isRequired = false,
    super.completedAt,
  });

  factory PreparationItemModel.fromMap(Map<String, dynamic> map) {
    return PreparationItemModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      isDone: map['isDone'] as bool,
      isRequired: map['isRequired'] as bool? ?? false,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isDone': isDone,
      'isRequired': isRequired,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory PreparationItemModel.fromEntity(PreparationItemEntity entity) {
    return PreparationItemModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      isDone: entity.isDone,
      isRequired: entity.isRequired,
      completedAt: entity.completedAt,
    );
  }
}

// Made with Bob
