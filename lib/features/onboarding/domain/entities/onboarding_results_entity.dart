import 'package:equatable/equatable.dart';
import 'critical_alert_entity.dart';
import 'checklist_item_entity.dart';

/// Resultados gerados pelo onboarding
/// Contém tudo que será criado automaticamente no projeto
class OnboardingResultsEntity extends Equatable {
  final String nextAction; // Primeira ação sugerida
  final String nextActionDescription; // Descrição detalhada
  final List<CriticalAlertEntity> criticalAlerts; // Alertas do Step 14
  final Map<String, List<ChecklistItemEntity>>
      checklistsByRoom; // Checklists por ambiente
  final List<String> suggestions; // Sugestões de compras
  final double initialHealthScore; // Saúde inicial (0-100)
  final int estimatedDurationDays; // Duração estimada total
  final Map<String, dynamic> phaseConfiguration; // Configuração das fases

  const OnboardingResultsEntity({
    required this.nextAction,
    required this.nextActionDescription,
    required this.criticalAlerts,
    required this.checklistsByRoom,
    required this.suggestions,
    required this.initialHealthScore,
    required this.estimatedDurationDays,
    required this.phaseConfiguration,
  });

  OnboardingResultsEntity copyWith({
    String? nextAction,
    String? nextActionDescription,
    List<CriticalAlertEntity>? criticalAlerts,
    Map<String, List<ChecklistItemEntity>>? checklistsByRoom,
    List<String>? suggestions,
    double? initialHealthScore,
    int? estimatedDurationDays,
    Map<String, dynamic>? phaseConfiguration,
  }) {
    return OnboardingResultsEntity(
      nextAction: nextAction ?? this.nextAction,
      nextActionDescription:
          nextActionDescription ?? this.nextActionDescription,
      criticalAlerts: criticalAlerts ?? this.criticalAlerts,
      checklistsByRoom: checklistsByRoom ?? this.checklistsByRoom,
      suggestions: suggestions ?? this.suggestions,
      initialHealthScore: initialHealthScore ?? this.initialHealthScore,
      estimatedDurationDays:
          estimatedDurationDays ?? this.estimatedDurationDays,
      phaseConfiguration: phaseConfiguration ?? this.phaseConfiguration,
    );
  }

  @override
  List<Object?> get props => [
        nextAction,
        nextActionDescription,
        criticalAlerts,
        checklistsByRoom,
        suggestions,
        initialHealthScore,
        estimatedDurationDays,
        phaseConfiguration,
      ];
}

// Made with Bob
