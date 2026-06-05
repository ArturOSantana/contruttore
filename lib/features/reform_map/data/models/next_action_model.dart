import '../../domain/entities/next_action_entity.dart';

/// Model para serialização da próxima ação
class NextActionModel extends NextActionEntity {
  const NextActionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.priority,
    super.phaseId,
    super.phaseName,
    required super.reason,
    super.blockedBy = const [],
    super.deadline,
    required super.category,
    super.metadata,
  });

  factory NextActionModel.fromMap(Map<String, dynamic> map) {
    return NextActionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      type: ActionType.values.firstWhere(
        (e) => e.toString() == 'ActionType.${map['type']}',
      ),
      priority: ActionPriority.values.firstWhere(
        (e) => e.toString() == 'ActionPriority.${map['priority']}',
      ),
      phaseId: map['phaseId'] as String?,
      phaseName: map['phaseName'] as String?,
      reason: map['reason'] as String,
      blockedBy: (map['blockedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'] as String)
          : null,
      category: ActionCategory.values.firstWhere(
        (e) => e.toString() == 'ActionCategory.${map['category']}',
      ),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'phaseId': phaseId,
      'phaseName': phaseName,
      'reason': reason,
      'blockedBy': blockedBy,
      'deadline': deadline?.toIso8601String(),
      'category': category.toString().split('.').last,
      'metadata': metadata,
    };
  }

  factory NextActionModel.fromEntity(NextActionEntity entity) {
    return NextActionModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      type: entity.type,
      priority: entity.priority,
      phaseId: entity.phaseId,
      phaseName: entity.phaseName,
      reason: entity.reason,
      blockedBy: entity.blockedBy,
      deadline: entity.deadline,
      category: entity.category,
      metadata: entity.metadata,
    );
  }
}

// Made with Bob
