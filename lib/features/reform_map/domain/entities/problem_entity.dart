import 'package:equatable/equatable.dart';

/// Entidade que representa um problema na reforma
class ProblemEntity extends Equatable {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final ProblemType type;
  final ProblemSeverity severity;
  final String? phaseId;
  final String? phaseName;
  final double? financialImpact;
  final int? delayDays; // Mantido como delayDays (não timeImpactDays)
  final ProblemStatus status;
  final DateTime reportedAt;
  final DateTime? resolvedAt;
  final String? solution;
  final List<String> affectedAreas; // Áreas afetadas
  final String? responsibleId; // ID do fornecedor responsável
  final List<String> attachments; // URLs de fotos/documentos

  const ProblemEntity({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    this.phaseId,
    this.phaseName,
    this.financialImpact,
    this.delayDays,
    required this.status,
    required this.reportedAt,
    this.resolvedAt,
    this.solution,
    this.affectedAreas = const [],
    this.responsibleId,
    this.attachments = const [],
  });

  bool get isResolved => status == ProblemStatus.resolved;
  bool get isOpen => status == ProblemStatus.open;
  bool get hasFinancialImpact =>
      financialImpact != null && financialImpact! > 0;
  bool get hasDelayImpact => delayDays != null && delayDays! > 0;

  @override
  List<Object?> get props => [
        id,
        projectId,
        title,
        description,
        type,
        severity,
        phaseId,
        phaseName,
        financialImpact,
        delayDays,
        status,
        reportedAt,
        resolvedAt,
        solution,
        affectedAreas,
        responsibleId,
        attachments,
      ];
}

/// Tipo de problema
enum ProblemType {
  leak, // Vazamento
  crack, // Rachadura
  defect, // Defeito
  delay, // Atraso
  wrongMaterial, // Material errado
  wrongMeasure, // Medida errada
  damage, // Dano
  missing, // Faltando
  quality, // Qualidade
  other,
}

/// Severidade do problema
enum ProblemSeverity {
  critical, // Bloqueia obra
  high, // Impacto significativo
  medium, // Impacto moderado
  low, // Impacto mínimo
}

/// Status do problema
enum ProblemStatus {
  open, // Aberto
  inProgress, // Em resolução
  resolved, // Resolvido
  wontFix, // Não será resolvido
}

/// Extensões para facilitar uso
extension ProblemTypeExtension on ProblemType {
  String get displayName {
    switch (this) {
      case ProblemType.leak:
        return 'Vazamento';
      case ProblemType.crack:
        return 'Rachadura';
      case ProblemType.defect:
        return 'Defeito';
      case ProblemType.delay:
        return 'Atraso';
      case ProblemType.wrongMaterial:
        return 'Material Errado';
      case ProblemType.wrongMeasure:
        return 'Medida Errada';
      case ProblemType.damage:
        return 'Dano';
      case ProblemType.missing:
        return 'Faltando';
      case ProblemType.quality:
        return 'Qualidade';
      case ProblemType.other:
        return 'Outro';
    }
  }

  String get icon {
    switch (this) {
      case ProblemType.leak:
        return '💧';
      case ProblemType.crack:
        return '🔨';
      case ProblemType.defect:
        return '⚠️';
      case ProblemType.delay:
        return '⏰';
      case ProblemType.wrongMaterial:
        return '📦';
      case ProblemType.wrongMeasure:
        return '📏';
      case ProblemType.damage:
        return '💥';
      case ProblemType.missing:
        return '❓';
      case ProblemType.quality:
        return '🔍';
      case ProblemType.other:
        return '🚧';
    }
  }
}

extension ProblemSeverityExtension on ProblemSeverity {
  String get displayName {
    switch (this) {
      case ProblemSeverity.critical:
        return 'Crítico';
      case ProblemSeverity.high:
        return 'Alto';
      case ProblemSeverity.medium:
        return 'Médio';
      case ProblemSeverity.low:
        return 'Baixo';
    }
  }
}

extension ProblemStatusExtension on ProblemStatus {
  String get displayName {
    switch (this) {
      case ProblemStatus.open:
        return 'Aberto';
      case ProblemStatus.inProgress:
        return 'Em Resolução';
      case ProblemStatus.resolved:
        return 'Resolvido';
      case ProblemStatus.wontFix:
        return 'Não Será Resolvido';
    }
  }
}

// Made with Bob
