import '../../domain/entities/reform_health_entity.dart';

/// Model para serialização da saúde da reforma
class ReformHealthModel extends ReformHealthEntity {
  const ReformHealthModel({
    required super.score,
    required super.level,
    required super.message,
    super.issues = const [],
    super.positives = const [],
    required super.status,
    required super.factors,
    required super.calculatedAt,
  });

  /// Cria um model a partir de um Map (Firebase)
  factory ReformHealthModel.fromMap(Map<String, dynamic> map) {
    return ReformHealthModel(
      score: (map['score'] as num).toDouble(),
      level: HealthLevel.values.firstWhere(
        (e) => e.toString() == 'HealthLevel.${map['level']}',
        orElse: () => HealthLevel.attention,
      ),
      message: map['message'] as String? ?? 'Calculando saúde da reforma...',
      issues:
          (map['issues'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      positives: (map['positives'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      status: HealthStatus.values.firstWhere(
        (e) => e.toString() == 'HealthStatus.${map['status']}',
        orElse: () => HealthStatus.good,
      ),
      factors: (map['factors'] as List<dynamic>?)
              ?.map((f) => HealthFactorModel.fromMap(f as Map<String, dynamic>))
              .toList() ??
          [],
      calculatedAt: DateTime.parse(map['calculatedAt'] as String),
    );
  }

  /// Converte para Map (Firebase)
  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'level': level.toString().split('.').last,
      'message': message,
      'issues': issues,
      'positives': positives,
      'status': status.toString().split('.').last,
      'factors': factors.map((f) => (f as HealthFactorModel).toMap()).toList(),
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  /// Cria um model a partir de uma entidade
  factory ReformHealthModel.fromEntity(ReformHealthEntity entity) {
    return ReformHealthModel(
      score: entity.score,
      level: entity.level,
      message: entity.message,
      issues: entity.issues,
      positives: entity.positives,
      status: entity.status,
      factors:
          entity.factors.map((f) => HealthFactorModel.fromEntity(f)).toList(),
      calculatedAt: entity.calculatedAt,
    );
  }
}

/// Model para fator de saúde
class HealthFactorModel extends HealthFactor {
  const HealthFactorModel({
    required super.name,
    required super.score,
    required super.weight,
    required super.status,
    required super.description,
  });

  factory HealthFactorModel.fromMap(Map<String, dynamic> map) {
    return HealthFactorModel(
      name: map['name'] as String,
      score: (map['score'] as num).toDouble(),
      weight: (map['weight'] as num).toDouble(),
      status: FactorStatus.values.firstWhere(
        (e) => e.toString() == 'FactorStatus.${map['status']}',
      ),
      description: map['description'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'score': score,
      'weight': weight,
      'description': description,
    };
  }

  factory HealthFactorModel.fromEntity(HealthFactor entity) {
    return HealthFactorModel(
      name: entity.name,
      score: entity.score,
      weight: entity.weight,
      status: entity.status,
      description: entity.description,
    );
  }
}

// Made with Bob
