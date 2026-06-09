import 'package:equatable/equatable.dart';
import '../../domain/entities/next_step_preparation_entity.dart';
import '../../domain/entities/reform_map_entity.dart';
import '../../domain/entities/upcoming_expenses_entity.dart';

/// Estados do Mapa da Reforma
abstract class ReformMapState extends Equatable {
  const ReformMapState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ReformMapInitial extends ReformMapState {
  const ReformMapInitial();
}

/// Carregando o mapa
class ReformMapLoading extends ReformMapState {
  const ReformMapLoading();
}

/// Mapa carregado com sucesso
class ReformMapLoaded extends ReformMapState {
  final ReformMapEntity reformMap;

  const ReformMapLoaded(this.reformMap);

  @override
  List<Object?> get props => [reformMap];
}

/// Erro ao carregar
class ReformMapError extends ReformMapState {
  final String message;

  const ReformMapError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Atualizando o mapa (mostra loading overlay)
class ReformMapUpdating extends ReformMapState {
  final ReformMapEntity currentMap;

  const ReformMapUpdating(this.currentMap);

  @override
  List<Object?> get props => [currentMap];
}

// Made with Bob

/// Estado com dados de despesas futuras carregados
class UpcomingExpensesLoaded extends ReformMapState {
  final UpcomingExpensesEntity expenses;
  final int days; // 30, 60 ou 90

  const UpcomingExpensesLoaded(this.expenses, this.days);

  @override
  List<Object?> get props => [expenses, days];
}

/// Estado com preparação da próxima etapa carregada
class NextStepPreparationLoaded extends ReformMapState {
  final NextStepPreparationEntity? preparation;

  const NextStepPreparationLoaded(this.preparation);

  @override
  List<Object?> get props => [preparation];
}

/// Estado combinado com mapa e dados adicionais
class ReformMapLoadedWithExtras extends ReformMapState {
  final ReformMapEntity reformMap;
  final UpcomingExpensesEntity? upcomingExpenses;
  final NextStepPreparationEntity? nextStepPreparation;

  const ReformMapLoadedWithExtras({
    required this.reformMap,
    this.upcomingExpenses,
    this.nextStepPreparation,
  });

  @override
  List<Object?> get props => [
        reformMap,
        upcomingExpenses,
        nextStepPreparation,
      ];

  /// Cria uma cópia com novos valores
  ReformMapLoadedWithExtras copyWith({
    ReformMapEntity? reformMap,
    UpcomingExpensesEntity? upcomingExpenses,
    NextStepPreparationEntity? nextStepPreparation,
  }) {
    return ReformMapLoadedWithExtras(
      reformMap: reformMap ?? this.reformMap,
      upcomingExpenses: upcomingExpenses ?? this.upcomingExpenses,
      nextStepPreparation: nextStepPreparation ?? this.nextStepPreparation,
    );
  }
}

// Made with Bob
