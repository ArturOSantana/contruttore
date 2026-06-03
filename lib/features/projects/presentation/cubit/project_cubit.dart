import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/usecases/get_project_usecase.dart';
import '../../domain/usecases/update_project_usecase.dart';
import 'project_state.dart';

/// Cubit para gerenciar o estado de projetos
@injectable
class ProjectCubit extends Cubit<ProjectState> {
  final GetProjectUsecase _getProjectUsecase;
  final UpdateProjectUseCase _updateProjectUsecase;

  ProjectCubit(this._getProjectUsecase, this._updateProjectUsecase)
    : super(const ProjectInitial());

  /// Carrega um projeto pelo ID
  Future<void> getProject(String projectId) async {
    if (projectId.isEmpty) {
      emit(const ProjectError('ID do projeto não fornecido'));
      return;
    }

    emit(const ProjectLoading());

    final result = await _getProjectUsecase(projectId);

    result.fold(
      (failure) => emit(ProjectError(failure.message)),
      (project) => emit(ProjectLoaded(project: project)),
    );
  }

  /// Atualiza um projeto
  Future<void> updateProject(ProjectEntity project) async {
    emit(const ProjectLoading());

    final result = await _updateProjectUsecase(project);

    result.fold((failure) => emit(ProjectError(failure.message)), (_) {
      emit(const ProjectUpdated());
      // Recarrega o projeto atualizado
      getProject(project.id);
    });
  }

  /// Limpa o estado
  void clear() {
    emit(const ProjectInitial());
  }
}

// Made with Bob
