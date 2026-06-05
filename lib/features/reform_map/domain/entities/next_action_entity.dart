import 'package:equatable/equatable.dart';

/// Entidade que representa a próxima ação recomendada
class NextActionEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final ActionType type;
  final ActionPriority priority;
  final String? phaseId;
  final String? phaseName;
  final String reason;
  final List<String> blockedBy; // IDs de outras ações que bloqueiam esta
  final DateTime? deadline;
  final ActionCategory category;
  final Map<String, dynamic>? metadata; // Dados extras para navegação

  const NextActionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    this.phaseId,
    this.phaseName,
    required this.reason,
    this.blockedBy = const [],
    this.deadline,
    required this.category,
    this.metadata,
  });

  bool get isBlocked => blockedBy.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        priority,
        phaseId,
        phaseName,
        reason,
        blockedBy,
        deadline,
        category,
        metadata,
      ];
}

/// Tipo de ação
enum ActionType {
  decision, // Tomar uma decisão
  purchase, // Realizar uma compra
  hire, // Contratar profissional
  document, // Guardar documento
  payment, // Realizar pagamento
  inspection, // Fazer vistoria
  approval, // Aprovar algo
  schedule, // Agendar algo
  other,
}

/// Prioridade da ação
enum ActionPriority {
  critical, // Bloqueia tudo
  high, // Importante
  medium, // Normal
  low, // Pode esperar
}

/// Categoria da ação (para navegação)
enum ActionCategory {
  financial,
  shopping,
  supplier,
  document,
  phase,
  wishlist,
  general,
}

/// Extensões para facilitar uso
extension ActionTypeExtension on ActionType {
  String get displayName {
    switch (this) {
      case ActionType.decision:
        return 'Decisão';
      case ActionType.purchase:
        return 'Compra';
      case ActionType.hire:
        return 'Contratação';
      case ActionType.document:
        return 'Documento';
      case ActionType.payment:
        return 'Pagamento';
      case ActionType.inspection:
        return 'Vistoria';
      case ActionType.approval:
        return 'Aprovação';
      case ActionType.schedule:
        return 'Agendamento';
      case ActionType.other:
        return 'Outro';
    }
  }

  String get icon {
    switch (this) {
      case ActionType.decision:
        return '🤔';
      case ActionType.purchase:
        return '🛒';
      case ActionType.hire:
        return '👷';
      case ActionType.document:
        return '📄';
      case ActionType.payment:
        return '💰';
      case ActionType.inspection:
        return '🔍';
      case ActionType.approval:
        return '✅';
      case ActionType.schedule:
        return '📅';
      case ActionType.other:
        return '📌';
    }
  }
}

extension ActionPriorityExtension on ActionPriority {
  String get displayName {
    switch (this) {
      case ActionPriority.critical:
        return 'Crítico';
      case ActionPriority.high:
        return 'Alto';
      case ActionPriority.medium:
        return 'Médio';
      case ActionPriority.low:
        return 'Baixo';
    }
  }
}

// Made with Bob
