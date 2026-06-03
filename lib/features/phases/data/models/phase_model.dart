import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../projects/domain/entities/phase_entity.dart';

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
    super.glossaryTerms,
    super.commonMistake,
    super.isRetroactive,
    super.retroactiveMarkedAt,
  });

  factory PhaseModel.fromMap(Map<String, dynamic> map, String id) {
    return PhaseModel(
      id: id,
      projectId: map['projectId'] ?? '',
      number: map['number'] ?? 0,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      status: PhaseStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PhaseStatus.locked,
      ),
      startDate: map['startDate'] != null
          ? (map['startDate'] as Timestamp).toDate()
          : null,
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      estimatedDurationDays: map['estimatedDurationDays'] ?? 0,
      subtasks:
          (map['subtasks'] as List<dynamic>?)
              ?.map((s) => SubtaskModel.fromMap(s))
              .toList() ??
          [],
      notes: map['notes'],
      glossaryTerms: List<String>.from(map['glossaryTerms'] ?? []),
      commonMistake: map['commonMistake'],
      isRetroactive: map['isRetroactive'] ?? false,
      retroactiveMarkedAt: map['retroactiveMarkedAt'] != null
          ? (map['retroactiveMarkedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'number': number,
      'name': name,
      'description': description,
      'status': status.name,
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
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      isRequired: map['isRequired'] ?? false,
      isDone: map['isDone'] ?? false,
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isRequired': isRequired,
      'isDone': isDone,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
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
