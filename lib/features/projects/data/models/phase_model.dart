import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/phase_entity.dart';

class PhaseModel extends PhaseEntity {
  const PhaseModel({
    required super.id,
    required super.projectId,
    required super.number,
    required super.name,
    required super.description,
    required super.status,
    super.startDate,
    super.endDate,
    required super.estimatedDurationDays,
    required super.subtasks,
    super.notes,
    super.glossaryTerms = const [],
    super.commonMistake,
    super.isRetroactive = false,
    super.retroactiveMarkedAt,
  });

  factory PhaseModel.fromMap(Map<String, dynamic> map) {
    return PhaseModel(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      number: map['number'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      status: PhaseStatus.values.firstWhere(
        (e) => e.toString() == 'PhaseStatus.${map['status']}',
        orElse: () => PhaseStatus.locked,
      ),
      startDate: map['startDate'] != null
          ? (map['startDate'] as Timestamp).toDate()
          : null,
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      estimatedDurationDays: map['estimatedDurationDays'] as int,
      subtasks: (map['subtasks'] as List<dynamic>?)
              ?.map((s) => SubtaskModel.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      notes: map['notes'] as String?,
      glossaryTerms: (map['glossaryTerms'] as List<dynamic>?)
              ?.map((t) => t as String)
              .toList() ??
          [],
      commonMistake: map['commonMistake'] as String?,
      isRetroactive: map['isRetroactive'] as bool? ?? false,
      retroactiveMarkedAt: map['retroactiveMarkedAt'] != null
          ? (map['retroactiveMarkedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'number': number,
      'name': name,
      'description': description,
      'status': status.toString().split('.').last,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'estimatedDurationDays': estimatedDurationDays,
      'subtasks': subtasks.map((s) => (s as SubtaskModel).toMap()).toList(),
      'notes': notes,
      'glossaryTerms': glossaryTerms,
      'commonMistake': commonMistake,
      'isRetroactive': isRetroactive,
      'retroactiveMarkedAt': retroactiveMarkedAt != null
          ? Timestamp.fromDate(retroactiveMarkedAt!)
          : null,
    };
  }

  factory PhaseModel.fromEntity(PhaseEntity entity) {
    return PhaseModel(
      id: entity.id,
      projectId: entity.projectId,
      number: entity.number,
      name: entity.name,
      description: entity.description,
      status: entity.status,
      startDate: entity.startDate,
      endDate: entity.endDate,
      estimatedDurationDays: entity.estimatedDurationDays,
      subtasks: entity.subtasks.map((s) => SubtaskModel.fromEntity(s)).toList(),
      notes: entity.notes,
      glossaryTerms: entity.glossaryTerms,
      commonMistake: entity.commonMistake,
      isRetroactive: entity.isRetroactive,
      retroactiveMarkedAt: entity.retroactiveMarkedAt,
    );
  }
}

class SubtaskModel extends SubtaskEntity {
  const SubtaskModel({
    required super.id,
    required super.name,
    required super.isRequired,
    required super.isDone,
    super.completedAt,
    super.notes,
  });

  factory SubtaskModel.fromMap(Map<String, dynamic> map) {
    return SubtaskModel(
      id: map['id'] as String,
      name: map['name'] as String,
      isRequired: map['isRequired'] as bool,
      isDone: map['isDone'] as bool,
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isRequired': isRequired,
      'isDone': isDone,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'notes': notes,
    };
  }

  factory SubtaskModel.fromEntity(SubtaskEntity entity) {
    return SubtaskModel(
      id: entity.id,
      name: entity.name,
      isRequired: entity.isRequired,
      isDone: entity.isDone,
      completedAt: entity.completedAt,
      notes: entity.notes,
    );
  }
}

// Made with Bob
