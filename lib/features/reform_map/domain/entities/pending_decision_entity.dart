import 'package:equatable/equatable.dart';

/// Representa uma decisão que o usuário precisa tomar
///
/// Exemplos:
/// - "Escolher cor da parede da sala"
/// - "Definir modelo da torneira"
/// - "Aprovar orçamento do eletricista"
class PendingDecisionEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DecisionCategory category;
  final DecisionUrgency urgency;
  final String? phaseId;
  final String? phaseName;
  final DateTime? deadline;
  final List<String> options;
  final String? recommendedOption;
  final String? reasonForRecommendation;
  final bool blocksProgress;
  final DateTime createdAt;

  const PendingDecisionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.urgency,
    this.phaseId,
    this.phaseName,
    this.deadline,
    required this.options,
    this.recommendedOption,
    this.reasonForRecommendation,
    required this.blocksProgress,
    required this.createdAt,
  });

  /// Verifica se a decisão está atrasada
  bool get isOverdue {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!);
  }

  /// Verifica se a decisão está próxima do prazo (menos de 3 dias)
  bool get isNearDeadline {
    if (deadline == null) return false;
    final daysUntilDeadline = deadline!.difference(DateTime.now()).inDays;
    return daysUntilDeadline <= 3 && daysUntilDeadline >= 0;
  }

  /// Retorna o número de dias até o prazo
  int? get daysUntilDeadline {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now()).inDays;
  }

  /// Retorna a cor baseada na urgência
  String get urgencyColor {
    switch (urgency) {
      case DecisionUrgency.critical:
        return '#EF4444'; // Vermelho
      case DecisionUrgency.high:
        return '#F59E0B'; // Laranja
      case DecisionUrgency.medium:
        return '#3B82F6'; // Azul
      case DecisionUrgency.low:
        return '#10B981'; // Verde
    }
  }

  /// Retorna o ícone baseado na categoria
  String get categoryIcon {
    switch (category) {
      case DecisionCategory.design:
        return '';
      case DecisionCategory.budget:
        return '';
      case DecisionCategory.supplier:
        return '';
      case DecisionCategory.material:
        return '';
      case DecisionCategory.timeline:
        return '';
      case DecisionCategory.technical:
        return '';
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        urgency,
        phaseId,
        phaseName,
        deadline,
        options,
        recommendedOption,
        reasonForRecommendation,
        blocksProgress,
        createdAt,
      ];
}

/// Categoria da decisão
enum DecisionCategory {
  design, // Escolhas estéticas
  budget, // Decisões financeiras
  supplier, // Escolha de fornecedores
  material, // Escolha de materiais
  timeline, // Decisões de prazo
  technical, // Decisões técnicas
}

/// Urgência da decisão
enum DecisionUrgency {
  critical, // Bloqueia a obra
  high, // Precisa ser decidido em breve
  medium, // Importante mas não urgente
  low, // Pode esperar
}

/// Extensão para converter string em enum
extension DecisionCategoryExtension on String {
  DecisionCategory toDecisionCategory() {
    switch (toLowerCase()) {
      case 'design':
        return DecisionCategory.design;
      case 'budget':
        return DecisionCategory.budget;
      case 'supplier':
        return DecisionCategory.supplier;
      case 'material':
        return DecisionCategory.material;
      case 'timeline':
        return DecisionCategory.timeline;
      case 'technical':
        return DecisionCategory.technical;
      default:
        return DecisionCategory.design;
    }
  }
}

extension DecisionUrgencyExtension on String {
  DecisionUrgency toDecisionUrgency() {
    switch (toLowerCase()) {
      case 'critical':
        return DecisionUrgency.critical;
      case 'high':
        return DecisionUrgency.high;
      case 'medium':
        return DecisionUrgency.medium;
      case 'low':
        return DecisionUrgency.low;
      default:
        return DecisionUrgency.medium;
    }
  }
}

// Made with Bob
