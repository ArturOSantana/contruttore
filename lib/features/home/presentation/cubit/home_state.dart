import 'package:equatable/equatable.dart';
import 'package:contruttore/features/home/domain/entities/home_data_entity.dart';

/// Estados possíveis da tela Home
abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class HomeInitial extends HomeState {}

/// Estado de carregamento
class HomeLoading extends HomeState {}

/// Estado com dados carregados
class HomeLoaded extends HomeState {
  final HomeDataEntity data;

  HomeLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

/// Estado de erro
class HomeError extends HomeState {
  final String message;

  HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

// Made with Bob
