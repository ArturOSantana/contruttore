import 'package:equatable/equatable.dart';
import '../../domain/entities/project_entity.dart';

/// Estados do ProjectCubit
abstract class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ProjectInitial extends ProjectState {
  const ProjectInitial();
}

/// Estado de carregamento
class ProjectLoading extends ProjectState {
  const ProjectLoading();
}

/// Estado de sucesso com projeto carregado
class ProjectLoaded extends ProjectState {
  final ProjectEntity? project;

  const ProjectLoaded({this.project});

  @override
  List<Object?> get props => [project];
}

/// Estado de erro
class ProjectError extends ProjectState {
  final String message;

  const ProjectError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado de sucesso após atualização
class ProjectUpdated extends ProjectState {
  const ProjectUpdated();
}

// Made with Bob
