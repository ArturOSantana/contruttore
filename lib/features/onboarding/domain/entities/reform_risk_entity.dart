/// Entidade que representa um risco identificado na reforma
class ReformRiskEntity {
  final String id;
  final String title;
  final String description;
  final RiskSeverity severity;
  final String relatedPhaseId;
  final List<String> preventionActions;
  final bool resolved;

  const ReformRiskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.relatedPhaseId,
    required this.preventionActions,
    this.resolved = false,
  });

  ReformRiskEntity copyWith({
    String? id,
    String? title,
    String? description,
    RiskSeverity? severity,
    String? relatedPhaseId,
    List<String>? preventionActions,
    bool? resolved,
  }) {
    return ReformRiskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      relatedPhaseId: relatedPhaseId ?? this.relatedPhaseId,
      preventionActions: preventionActions ?? this.preventionActions,
      resolved: resolved ?? this.resolved,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'severity': severity.toString().split('.').last,
      'relatedPhaseId': relatedPhaseId,
      'preventionActions': preventionActions,
      'resolved': resolved,
    };
  }

  factory ReformRiskEntity.fromMap(Map<String, dynamic> map) {
    return ReformRiskEntity(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      severity: RiskSeverity.values.firstWhere(
        (e) => e.toString().split('.').last == map['severity'],
        orElse: () => RiskSeverity.low,
      ),
      relatedPhaseId: map['relatedPhaseId'] as String,
      preventionActions: List<String>.from(map['preventionActions'] as List),
      resolved: map['resolved'] as bool? ?? false,
    );
  }
}

/// Níveis de severidade do risco
enum RiskSeverity {
  high, // Alto risco - Pode causar retrabalho caro
  medium, // Médio risco - Pode causar problemas
  low, // Baixo risco - Atenção necessária
}

extension RiskSeverityExtension on RiskSeverity {
  String get displayName {
    switch (this) {
      case RiskSeverity.high:
        return 'Alto risco';
      case RiskSeverity.medium:
        return 'Médio risco';
      case RiskSeverity.low:
        return 'Baixo risco';
    }
  }

  String get emoji {
    switch (this) {
      case RiskSeverity.high:
        return '🔴';
      case RiskSeverity.medium:
        return '🟡';
      case RiskSeverity.low:
        return '🟢';
    }
  }
}

// Made with Bob
