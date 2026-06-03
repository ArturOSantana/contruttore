import 'package:equatable/equatable.dart';
import '../../../projects/domain/entities/project_entity.dart';

abstract class OnboardingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingInProgress extends OnboardingState {
  final int currentStep;
  final Map<String, dynamic> data;

  OnboardingInProgress({required this.currentStep, required this.data});

  @override
  List<Object?> get props => [currentStep, data];
}

class OnboardingLoading extends OnboardingState {}

class OnboardingCompleted extends OnboardingState {
  final ProjectEntity project;

  OnboardingCompleted(this.project);

  @override
  List<Object?> get props => [project];
}

class OnboardingError extends OnboardingState {
  final String message;

  OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}

// Made with Bob
