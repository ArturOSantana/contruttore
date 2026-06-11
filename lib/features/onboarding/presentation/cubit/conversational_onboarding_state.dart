import 'package:equatable/equatable.dart';
import '../../domain/entities/conversational_onboarding_progress.dart';
import '../../../projects/domain/entities/project_entity.dart';

/// Estados do onboarding conversacional
abstract class ConversationalOnboardingState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial - verificando se existe progresso salvo
class ConversationalOnboardingInitial extends ConversationalOnboardingState {}

/// Progresso sendo carregado
class ConversationalOnboardingLoading extends ConversationalOnboardingState {}

/// Onboarding em progresso
class ConversationalOnboardingInProgress extends ConversationalOnboardingState {
  final ConversationalOnboardingProgress progress;
  final bool hasUnsavedChanges;

  ConversationalOnboardingInProgress({
    required this.progress,
    this.hasUnsavedChanges = false,
  });

  @override
  List<Object?> get props => [progress, hasUnsavedChanges];
}

/// Progresso salvo encontrado - perguntar se quer continuar
class ConversationalOnboardingResumePrompt
    extends ConversationalOnboardingState {
  final ConversationalOnboardingProgress savedProgress;
  final DateTime lastUpdate;

  ConversationalOnboardingResumePrompt({
    required this.savedProgress,
    required this.lastUpdate,
  });

  @override
  List<Object?> get props => [savedProgress, lastUpdate];
}

/// Gerando resultados finais
class ConversationalOnboardingGeneratingResults
    extends ConversationalOnboardingState {
  final ConversationalOnboardingProgress progress;

  ConversationalOnboardingGeneratingResults(this.progress);

  @override
  List<Object?> get props => [progress];
}

/// Resultados prontos para exibir
class ConversationalOnboardingResultsReady
    extends ConversationalOnboardingState {
  final String nextAction;
  final String nextActionDescription;
  final List<String> criticalAlerts;
  final int estimatedDurationDays;
  final double estimatedBudget;
  final String currentPhase;
  final int alertsCount;

  ConversationalOnboardingResultsReady({
    required this.nextAction,
    required this.nextActionDescription,
    required this.criticalAlerts,
    required this.estimatedDurationDays,
    required this.estimatedBudget,
    required this.currentPhase,
    required this.alertsCount,
  });

  @override
  List<Object?> get props => [
        nextAction,
        nextActionDescription,
        criticalAlerts,
        estimatedDurationDays,
        estimatedBudget,
        currentPhase,
        alertsCount,
      ];
}

/// Onboarding completo - projeto criado
class ConversationalOnboardingCompleted extends ConversationalOnboardingState {
  final ProjectEntity project;

  ConversationalOnboardingCompleted(this.project);

  @override
  List<Object?> get props => [project];
}

/// Erro durante o onboarding
class ConversationalOnboardingError extends ConversationalOnboardingState {
  final String message;
  final ConversationalOnboardingProgress? lastProgress;

  ConversationalOnboardingError(this.message, {this.lastProgress});

  @override
  List<Object?> get props => [message, lastProgress];
}

// Made with ❤️ by Bob

// Made with Bob
