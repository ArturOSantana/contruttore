import 'package:equatable/equatable.dart';
import '../../domain/entities/project_entity.dart';

/// Estados do ProjectsListCubit
abstract class ProjectsListState extends Equatable {
  const ProjectsListState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ProjectsListInitial extends ProjectsListState {
  const ProjectsListInitial();
}

/// Estado de carregamento
class ProjectsListLoading extends ProjectsListState {
  const ProjectsListLoading();
}

/// Estado de sucesso com lista de projetos
class ProjectsListLoaded extends ProjectsListState {
  final List<ProjectEntity> projects;
  final String? currentProjectId;

  const ProjectsListLoaded({required this.projects, this.currentProjectId});

  @override
  List<Object?> get props => [projects, currentProjectId];
}

/// Estado de erro
class ProjectsListError extends ProjectsListState {
  final String message;

  const ProjectsListError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado de sucesso após trocar projeto
class ProjectSwitched extends ProjectsListState {
  final String projectId;

  const ProjectSwitched(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

// Made with Bob
