import 'package:equatable/equatable.dart';

/// Prioridade do alerta
enum AlertPriority {
  critical, // Vermelho - Deve ser feito AGORA
  high, // Laranja - Importante mas não urgente
  medium, // Amarelo - Recomendado
  low, // Azul - Opcional
}

/// Alerta crítico gerado no onboarding
/// Previne erros caros ao alertar sobre infraestrutura antes da fase correta
class CriticalAlertEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final String phase; // Fase onde o alerta deve aparecer
  final AlertPriority priority;
  final List<String> tasks; // Tarefas específicas a fazer
  final String? estimatedCost; // Custo estimado se não fizer agora
  final String? reworkCost; // Custo de retrabalho se esquecer

  const CriticalAlertEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.phase,
    required this.priority,
    required this.tasks,
    this.estimatedCost,
    this.reworkCost,
  });

  CriticalAlertEntity copyWith({
    String? id,
    String? title,
    String? message,
    String? phase,
    AlertPriority? priority,
    List<String>? tasks,
    String? estimatedCost,
    String? reworkCost,
  }) {
    return CriticalAlertEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      phase: phase ?? this.phase,
      priority: priority ?? this.priority,
      tasks: tasks ?? this.tasks,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      reworkCost: reworkCost ?? this.reworkCost,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        phase,
        priority,
        tasks,
        estimatedCost,
        reworkCost,
      ];
}

extension AlertPriorityExtension on AlertPriority {
  String get displayName {
    switch (this) {
      case AlertPriority.critical:
        return 'CRÍTICO';
      case AlertPriority.high:
        return 'IMPORTANTE';
      case AlertPriority.medium:
        return 'RECOMENDADO';
      case AlertPriority.low:
        return 'OPCIONAL';
    }
  }

  String get emoji {
    switch (this) {
      case AlertPriority.critical:
        return '🚨';
      case AlertPriority.high:
        return '⚠️';
      case AlertPriority.medium:
        return '💡';
      case AlertPriority.low:
        return 'ℹ️';
    }
  }
}

// Made with Bob
