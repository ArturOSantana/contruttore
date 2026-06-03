import 'package:equatable/equatable.dart';
import '../../../projects/domain/entities/phase_entity.dart';

abstract class PhasesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PhasesInitial extends PhasesState {}

class PhasesLoading extends PhasesState {}

class PhasesLoaded extends PhasesState {
  final List<PhaseEntity> phases;

  PhasesLoaded(this.phases);

  @override
  List<Object?> get props => [phases];
}

class PhasesError extends PhasesState {
  final String message;

  PhasesError(this.message);

  @override
  List<Object?> get props => [message];
}

// Made with Bob
