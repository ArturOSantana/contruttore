import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../../auth/domain/usecases/switch_project_usecase.dart';
import '../../domain/usecases/get_projects_usecase.dart';
import 'projects_list_state.dart';

/// Cubit para gerenciar a lista de projetos do usuário
@injectable
class ProjectsListCubit extends Cubit<ProjectsListState> {
  final GetProjectsUseCase _getProjectsUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SwitchProjectUseCase _switchProjectUseCase;

  ProjectsListCubit(
    this._getProjectsUseCase,
    this._getCurrentUserUseCase,
    this._switchProjectUseCase,
  ) : super(const ProjectsListInitial());

  /// Carrega todos os projetos do usuário
  Future<void> loadProjects() async {
    emit(const ProjectsListLoading());

    // Buscar usuário atual
    final userResult = await _getCurrentUserUseCase();

    await userResult.fold(
      (failure) async {
        emit(ProjectsListError(failure.message));
      },
      (user) async {
        if (user == null) {
          emit(const ProjectsListError('Usuário não autenticado'));
          return;
        }

        // Buscar projetos do usuário
        final projectsResult = await _getProjectsUseCase(user.id);

        projectsResult.fold(
          (failure) {
            // Verificar se é erro de índice em construção
            if (failure.message.contains('index') &&
                failure.message.contains('building')) {
              emit(
                const ProjectsListError(
                  'O índice do banco de dados está sendo construído. '
                  'Isso pode levar alguns minutos. Por favor, tente novamente em breve.',
                ),
              );
            } else {
              emit(ProjectsListError(failure.message));
            }
          },
          (projects) => emit(
            ProjectsListLoaded(
              projects: projects,
              currentProjectId: user.currentProjectId,
            ),
          ),
        );
      },
    );
  }

  /// Troca o projeto ativo
  Future<void> switchProject(String projectId) async {
    final currentState = state;
    if (currentState is! ProjectsListLoaded) return;

    emit(const ProjectsListLoading());

    // Buscar usuário atual
    final userResult = await _getCurrentUserUseCase();

    await userResult.fold(
      (failure) async {
        emit(ProjectsListError(failure.message));
      },
      (user) async {
        if (user == null) {
          emit(const ProjectsListError('Usuário não autenticado'));
          return;
        }

        // Trocar projeto
        final switchResult = await _switchProjectUseCase(user.id, projectId);

        switchResult.fold(
          (failure) {
            emit(ProjectsListError(failure.message));
            // Recarregar lista em caso de erro
            loadProjects();
          },
          (_) {
            emit(ProjectSwitched(projectId));
            // Recarregar lista após trocar
            loadProjects();
          },
        );
      },
    );
  }

  /// Limpa o estado
  void clear() {
    emit(const ProjectsListInitial());
  }
}

// Made with Bob
