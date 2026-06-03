import 'package:equatable/equatable.dart';

class DiaryEntryEntity extends Equatable {
  final String id;
  final String projectId;
  final DiaryEntryType type;
  final String? phaseId;
  final String title;
  final String description;
  final List<String> photoUrls;
  final DateTime date;
  final String? supplierId;
  final String? visitType;
  final ProblemSeverity? problemSeverity;
  final bool? isResolved;
  final DateTime createdAt;

  const DiaryEntryEntity({
    required this.id,
    required this.projectId,
    required this.type,
    this.phaseId,
    required this.title,
    required this.description,
    required this.photoUrls,
    required this.date,
    this.supplierId,
    this.visitType,
    this.problemSeverity,
    this.isResolved,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    projectId,
    type,
    phaseId,
    title,
    description,
    photoUrls,
    date,
    supplierId,
    visitType,
    problemSeverity,
    isResolved,
    createdAt,
  ];
}

enum DiaryEntryType { daily, visit, problem, delivery }

extension DiaryEntryTypeExtension on DiaryEntryType {
  String get displayName {
    switch (this) {
      case DiaryEntryType.daily:
        return 'Registro Diário';
      case DiaryEntryType.visit:
        return 'Visita Técnica';
      case DiaryEntryType.problem:
        return 'Problema';
      case DiaryEntryType.delivery:
        return 'Entrega de Material';
    }
  }

  String get icon {
    switch (this) {
      case DiaryEntryType.daily:
        return '📝';
      case DiaryEntryType.visit:
        return '👷';
      case DiaryEntryType.problem:
        return '⚠️';
      case DiaryEntryType.delivery:
        return '📦';
    }
  }
}

enum ProblemSeverity { low, medium, high }

extension ProblemSeverityExtension on ProblemSeverity {
  String get displayName {
    switch (this) {
      case ProblemSeverity.low:
        return 'Baixa';
      case ProblemSeverity.medium:
        return 'Média';
      case ProblemSeverity.high:
        return 'Alta';
    }
  }
}

// Made with Bob
