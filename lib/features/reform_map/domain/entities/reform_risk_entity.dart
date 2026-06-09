import 'package:equatable/equatable.dart';

/// Severidade do risco
enum RiskSeverity {
  /// Risco alto - pode comprometer a reforma
  high,

  /// Risco médio - pode causar problemas
  medium,

  /// Risco baixo - atenção necessária
  low,
}

/// Risco identificado na reforma
class ReformRiskEntity extends Equatable {
  /// ID único do risco
  final String id;

  /// Título do risco
  final String title;

  /// Descrição detalhada do risco
  final String description;

  /// Severidade do risco
  final RiskSeverity severity;

  /// ID da fase relacionada
  final String phaseId;

  /// Nome da fase (denormalizado para performance)
  final String phaseName;

  /// Ações de prevenção recomendadas
  final List<String> preventionActions;

  /// Consequências se não for tratado
  final String? consequences;

  /// Custo estimado se o risco se concretizar
  final double? estimatedCost;

  /// Dias de atraso estimados se o risco se concretizar
  final int? estimatedDelay;

  /// Se o risco foi mitigado
  final bool isMitigated;

  /// Data de mitigação
  final DateTime? mitigatedAt;

  /// Notas sobre a mitigação
  final String? mitigationNotes;

  /// Data de criação do risco
  final DateTime createdAt;

  const ReformRiskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.phaseId,
    required this.phaseName,
    required this.preventionActions,
    this.consequences,
    this.estimatedCost,
    this.estimatedDelay,
    this.isMitigated = false,
    this.mitigatedAt,
    this.mitigationNotes,
    required this.createdAt,
  });

  /// Cria uma cópia com campos atualizados
  ReformRiskEntity copyWith({
    String? id,
    String? title,
    String? description,
    RiskSeverity? severity,
    String? phaseId,
    String? phaseName,
    List<String>? preventionActions,
    String? consequences,
    double? estimatedCost,
    int? estimatedDelay,
    bool? isMitigated,
    DateTime? mitigatedAt,
    String? mitigationNotes,
    DateTime? createdAt,
  }) {
    return ReformRiskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      phaseId: phaseId ?? this.phaseId,
      phaseName: phaseName ?? this.phaseName,
      preventionActions: preventionActions ?? this.preventionActions,
      consequences: consequences ?? this.consequences,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      estimatedDelay: estimatedDelay ?? this.estimatedDelay,
      isMitigated: isMitigated ?? this.isMitigated,
      mitigatedAt: mitigatedAt ?? this.mitigatedAt,
      mitigationNotes: mitigationNotes ?? this.mitigationNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Retorna a cor associada à severidade
  String get severityColor {
    switch (severity) {
      case RiskSeverity.high:
        return '#EF4444'; // red-500
      case RiskSeverity.medium:
        return '#F59E0B'; // amber-500
      case RiskSeverity.low:
        return '#3B82F6'; // blue-500
    }
  }

  /// Retorna o label da severidade
  String get severityLabel {
    switch (severity) {
      case RiskSeverity.high:
        return 'Alto';
      case RiskSeverity.medium:
        return 'Médio';
      case RiskSeverity.low:
        return 'Baixo';
    }
  }

  /// Retorna o ícone da severidade
  String get severityIcon {
    switch (severity) {
      case RiskSeverity.high:
        return '';
      case RiskSeverity.medium:
        return '';
      case RiskSeverity.low:
        return '';
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        severity,
        phaseId,
        phaseName,
        preventionActions,
        consequences,
        estimatedCost,
        estimatedDelay,
        isMitigated,
        mitigatedAt,
        mitigationNotes,
        createdAt,
      ];
}

// Made with Bob
