import 'package:equatable/equatable.dart';

/// Entidade que representa a saúde geral da reforma
class ReformHealthEntity extends Equatable {
  final double score; // 0-100 (renomeado de healthScore para score)
  final HealthStatus status;
  final List<HealthFactor> factors;
  final DateTime calculatedAt;

  const ReformHealthEntity({
    required this.score,
    required this.status,
    required this.factors,
    required this.calculatedAt,
  });

  @override
  List<Object?> get props => [
        score,
        status,
        factors,
        calculatedAt,
      ];
}

/// Status geral da saúde da reforma
enum HealthStatus {
  excellent, // 90-100
  good, // 70-89
  warning, // 50-69
  critical, // 0-49
}

/// Fator que contribui para a saúde da reforma
class HealthFactor extends Equatable {
  final String name;
  final double score; // 0-100
  final double weight; // Peso do fator no cálculo geral
  final FactorStatus status;
  final String description;

  const HealthFactor({
    required this.name,
    required this.score,
    required this.weight,
    required this.status,
    required this.description,
  });

  @override
  List<Object?> get props => [name, score, weight, status, description];
}

enum FactorStatus {
  ok,
  warning,
  critical,
}

/// Calcula o status baseado no score
extension HealthStatusExtension on double {
  HealthStatus toHealthStatus() {
    if (this >= 90) return HealthStatus.excellent;
    if (this >= 70) return HealthStatus.good;
    if (this >= 50) return HealthStatus.warning;
    return HealthStatus.critical;
  }
}

extension FactorStatusExtension on double {
  FactorStatus toFactorStatus() {
    if (this >= 70) return FactorStatus.ok;
    if (this >= 50) return FactorStatus.warning;
    return FactorStatus.critical;
  }
}

// Made with Bob
