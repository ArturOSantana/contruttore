import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/diary_entry_entity.dart';

class DiaryEntryModel extends DiaryEntryEntity {
  const DiaryEntryModel({
    required super.id,
    required super.projectId,
    required super.type,
    super.phaseId,
    required super.title,
    required super.description,
    required super.photoUrls,
    required super.date,
    super.supplierId,
    super.visitType,
    super.problemSeverity,
    super.isResolved,
    required super.createdAt,
  });

  factory DiaryEntryModel.fromMap(Map<String, dynamic> map, String id) {
    return DiaryEntryModel(
      id: id,
      projectId: map['projectId'] ?? '',
      type: DiaryEntryType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DiaryEntryType.daily,
      ),
      phaseId: map['phaseId'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      date: (map['date'] as Timestamp).toDate(),
      supplierId: map['supplierId'],
      visitType: map['visitType'],
      problemSeverity: map['problemSeverity'] != null
          ? ProblemSeverity.values.firstWhere(
              (e) => e.name == map['problemSeverity'],
              orElse: () => ProblemSeverity.low,
            )
          : null,
      isResolved: map['isResolved'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'type': type.name,
      'phaseId': phaseId,
      'title': title,
      'description': description,
      'photoUrls': photoUrls,
      'date': Timestamp.fromDate(date),
      'supplierId': supplierId,
      'visitType': visitType,
      'problemSeverity': problemSeverity?.name,
      'isResolved': isResolved,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

// Made with Bob
