import 'package:equatable/equatable.dart';
import '../../domain/entities/phase_entity.dart';

/// Estados do PhasesCubit
abstract class PhasesState extends Equatable {
  const PhasesState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class PhasesInitial extends PhasesState {
  const PhasesInitial();
}

/// Estado de carregamento
class PhasesLoading extends PhasesState {
  const PhasesLoading();
}

/// Estado de sucesso com fases carregadas
class PhasesLoaded extends PhasesState {
  final List<PhaseEntity> phases;
  final PhaseEntity? currentPhase;

  const PhasesLoaded({
    required this.phases,
    this.currentPhase,
  });

  @override
  List<Object?> get props => [phases, currentPhase];

  PhasesLoaded copyWith({
    List<PhaseEntity>? phases,
    PhaseEntity? currentPhase,
  }) {
    return PhasesLoaded(
      phases: phases ?? this.phases,
      currentPhase: currentPhase ?? this.currentPhase,
    );
  }
}

/// Estado de erro
class PhasesError extends PhasesState {
  final String message;

  const PhasesError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado de sucesso após atualização
class PhaseUpdated extends PhasesState {
  const PhaseUpdated();
}

// Made with Bob
