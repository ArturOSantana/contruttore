import '../../domain/entities/problem_entity.dart';

/// Model para serialização de problemas
class ProblemModel extends ProblemEntity {
  const ProblemModel({
    required super.id,
    required super.projectId,
    required super.title,
    required super.description,
    required super.type,
    required super.severity,
    super.phaseId,
    super.phaseName,
    super.financialImpact,
    super.delayDays,
    required super.status,
    required super.reportedAt,
    super.resolvedAt,
    super.solution,
    super.resolution,
    super.affectedAreas = const [],
    super.supplierId,
    super.photoUrls = const [],
    super.attachments = const [],
  });

  factory ProblemModel.fromMap(Map<String, dynamic> map) {
    // Suporta tanto supplierId quanto responsibleId (retrocompatibilidade)
    final supplierId =
        map['supplierId'] as String? ?? map['responsibleId'] as String?;

    // Suporta tanto photoUrls quanto attachments (retrocompatibilidade)
    final photoUrls = (map['photoUrls'] as List<dynamic>?)
            ?.map((a) => a as String)
            .toList() ??
        (map['attachments'] as List<dynamic>?)
            ?.map((a) => a as String)
            .toList() ??
        [];

    return ProblemModel(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      type: ProblemType.values.firstWhere(
        (e) => e.toString() == 'ProblemType.${map['type']}',
        orElse: () => ProblemType.other,
      ),
      severity: ProblemSeverity.values.firstWhere(
        (e) => e.toString() == 'ProblemSeverity.${map['severity']}',
      ),
      phaseId: map['phaseId'] as String?,
      phaseName: map['phaseName'] as String?,
      financialImpact: map['financialImpact'] != null
          ? (map['financialImpact'] as num).toDouble()
          : null,
      delayDays: map['delayDays'] as int?,
      status: ProblemStatus.values.firstWhere(
        (e) => e.toString() == 'ProblemStatus.${map['status']}',
      ),
      reportedAt: DateTime.parse(map['reportedAt'] as String),
      resolvedAt: map['resolvedAt'] != null
          ? DateTime.parse(map['resolvedAt'] as String)
          : null,
      solution: map['solution'] as String?,
      resolution: map['resolution'] as String? ?? map['solution'] as String?,
      affectedAreas: (map['affectedAreas'] as List<dynamic>?)
              ?.map((a) => a as String)
              .toList() ??
          [],
      supplierId: supplierId,
      photoUrls: photoUrls,
      attachments: photoUrls, // Mantém compatibilidade
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'severity': severity.toString().split('.').last,
      'phaseId': phaseId,
      'phaseName': phaseName,
      'financialImpact': financialImpact,
      'delayDays': delayDays,
      'status': status.toString().split('.').last,
      'reportedAt': reportedAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'solution': solution,
      'resolution': resolution ?? solution,
      'affectedAreas': affectedAreas,
      'supplierId': supplierId,
      'photoUrls': photoUrls,
      // Mantém campos antigos para compatibilidade
      'responsibleId': supplierId,
      'attachments': photoUrls,
    };
  }

  factory ProblemModel.fromEntity(ProblemEntity entity) {
    return ProblemModel(
      id: entity.id,
      projectId: entity.projectId,
      title: entity.title,
      description: entity.description,
      type: entity.type,
      severity: entity.severity,
      phaseId: entity.phaseId,
      phaseName: entity.phaseName,
      financialImpact: entity.financialImpact,
      delayDays: entity.delayDays,
      status: entity.status,
      reportedAt: entity.reportedAt,
      resolvedAt: entity.resolvedAt,
      solution: entity.solution,
      resolution: entity.resolution,
      affectedAreas: entity.affectedAreas,
      supplierId: entity.supplierId,
      photoUrls: entity.photoUrls,
      attachments: entity.attachments,
    );
  }
}

// Made with Bob
