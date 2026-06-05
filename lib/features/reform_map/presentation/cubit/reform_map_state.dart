import 'package:equatable/equatable.dart';
import '../../domain/entities/reform_map_entity.dart';

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
