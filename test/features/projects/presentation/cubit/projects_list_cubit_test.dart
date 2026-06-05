import 'package:bloc_test/bloc_test.dart';
import 'package:contruttore/core/error/failures.dart';
import 'package:contruttore/features/auth/domain/entities/user_entity.dart';
import 'package:contruttore/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:contruttore/features/auth/domain/usecases/switch_project_usecase.dart';
import 'package:contruttore/features/projects/domain/entities/project_entity.dart';
import 'package:contruttore/features/projects/domain/usecases/get_projects_usecase.dart';
import 'package:contruttore/features/projects/presentation/cubit/projects_list_cubit.dart';
import 'package:contruttore/features/projects/presentation/cubit/projects_list_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProjectsUseCase extends Mock implements GetProjectsUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockSwitchProjectUseCase extends Mock implements SwitchProjectUseCase {}

void main() {
  late ProjectsListCubit projectsListCubit;
  late MockGetProjectsUseCase mockGetProjectsUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockSwitchProjectUseCase mockSwitchProjectUseCase;

  final tUser = UserEntity(
    id: 'user1',
    name: 'Test User',
    email: 'test@example.com',
    currentProjectId: 'p1',
    createdAt: DateTime.now(),
  );

  final tProjects = <ProjectEntity>[
    ProjectEntity(
      id: 'p1',
      userId: 'user1',
      name: 'Apartamento 101',
      address: 'Rua A, 123',
      constructorName: 'Construtora ABC',
      area: 80.0,
      deliveryDate: DateTime.now().add(const Duration(days: 180)),
      contractDate: DateTime.now().subtract(const Duration(days: 30)),
      contingencyPercent: 10.0,
      currentSituation: 'construction',
      createdAt: DateTime.now(),
    ),
    ProjectEntity(
      id: 'p2',
      userId: 'user1',
      name: 'Casa de Praia',
      address: 'Av. Beira Mar, 456',
      constructorName: 'Construtora XYZ',
      area: 120.0,
      deliveryDate: DateTime.now().add(const Duration(days: 365)),
      contractDate: DateTime.now().subtract(const Duration(days: 60)),
      contingencyPercent: 15.0,
      currentSituation: 'just_signed',
      createdAt: DateTime.now(),
    ),
  ];

  setUp(() {
    mockGetProjectsUseCase = MockGetProjectsUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockSwitchProjectUseCase = MockSwitchProjectUseCase();

    projectsListCubit = ProjectsListCubit(
      mockGetProjectsUseCase,
      mockGetCurrentUserUseCase,
      mockSwitchProjectUseCase,
    );
  });

  group('ProjectsListCubit - Gestão de Projetos', () {
    // Teste 1: Estado inicial
    test('O estado inicial deve ser ProjectsListInitial', () {
      expect(projectsListCubit.state, equals(const ProjectsListInitial()));
    });

    // Teste 2: Carregamento de projetos com sucesso
    // O que ele faz: Verifica se os projetos do usuário são carregados corretamente
    blocTest<ProjectsListCubit, ProjectsListState>(
      'Deve emitir [ProjectsListLoading, ProjectsListLoaded] ao carregar projetos',
      build: () {
        when(() => mockGetCurrentUserUseCase()).thenAnswer(
          (_) async => Right(tUser),
        );
        when(() => mockGetProjectsUseCase(any())).thenAnswer(
          (_) async => Right(tProjects),
        );
        return projectsListCubit;
      },
      act: (cubit) => cubit.loadProjects(),
      expect: () => [
        const ProjectsListLoading(),
        ProjectsListLoaded(
          projects: tProjects,
          currentProjectId: 'p1',
        ),
      ],
    );

    // Teste 3: Erro ao carregar projetos - usuário não autenticado
    blocTest<ProjectsListCubit, ProjectsListState>(
      'Deve emitir erro quando usuário não estiver autenticado',
      build: () {
        when(() => mockGetCurrentUserUseCase()).thenAnswer(
          (_) async => const Right(null),
        );
        return projectsListCubit;
      },
      act: (cubit) => cubit.loadProjects(),
      expect: () => [
        const ProjectsListLoading(),
        const ProjectsListError('Usuário não autenticado'),
      ],
    );

    // Teste 4: Erro ao buscar usuário atual
    blocTest<ProjectsListCubit, ProjectsListState>(
      'Deve emitir erro quando falhar ao buscar usuário',
      build: () {
        when(() => mockGetCurrentUserUseCase()).thenAnswer(
          (_) async => const Left(ServerFailure('Erro ao buscar usuário')),
        );
        return projectsListCubit;
      },
      act: (cubit) => cubit.loadProjects(),
      expect: () => [
        const ProjectsListLoading(),
        const ProjectsListError('Erro ao buscar usuário'),
      ],
    );

    // Teste 5: Erro ao buscar projetos
    blocTest<ProjectsListCubit, ProjectsListState>(
      'Deve emitir erro quando falhar ao buscar projetos',
      build: () {
        when(() => mockGetCurrentUserUseCase()).thenAnswer(
          (_) async => Right(tUser),
        );
        when(() => mockGetProjectsUseCase(any())).thenAnswer(
          (_) async => const Left(ServerFailure('Erro ao buscar projetos')),
        );
        return projectsListCubit;
      },
      act: (cubit) => cubit.loadProjects(),
      expect: () => [
        const ProjectsListLoading(),
        const ProjectsListError('Erro ao buscar projetos'),
      ],
    );

    // Teste 6: Erro de índice em construção (Firebase)
    // O que ele faz: Verifica se o erro de índice do Firebase é tratado com mensagem amigável
    blocTest<ProjectsListCubit, ProjectsListState>(
      'Deve emitir mensagem específica para erro de índice em construção',
      build: () {
        when(() => mockGetCurrentUserUseCase()).thenAnswer(
          (_) async => Right(tUser),
        );
        when(() => mockGetProjectsUseCase(any())).thenAnswer(
          (_) async => const Left(
            ServerFailure(
                'The index is currently building. Please try again later.'),
          ),
        );
        return projectsListCubit;
      },
      act: (cubit) => cubit.loadProjects(),
      expect: () => [
        const ProjectsListLoading(),
        const ProjectsListError(
          'O índice do banco de dados está sendo construído. '
          'Isso pode levar alguns minutos. Por favor, tente novamente em breve.',
        ),
      ],
    );

    // Teste 7: Trocar projeto ativo com sucesso
    // O que ele faz: Verifica se o usuário consegue trocar entre projetos
    blocTest<ProjectsListCubit, ProjectsListState>(
      'Deve trocar projeto ativo e recarregar lista',
      build: () {
        when(() => mockGetCurrentUserUseCase()).thenAnswer(
          (_) async => Right(tUser),
        );
        when(() => mockSwitchProjectUseCase(any(), any())).thenAnswer(
          (_) async => const Right(null),
        );
        when(() => mockGetProjectsUseCase(any())).thenAnswer(
          (_) async => Right(tProjects),
        );
        return projectsListCubit;
      },
      seed: () => ProjectsListLoaded(
        projects: tProjects,
        currentProjectId: 'p1',
      ),
      act: (cubit) => cubit.switchProject('p2'),
      expect: () => [
        const ProjectsListLoading(),
        const ProjectSwitched('p2'),
        const ProjectsListLoading(),
        ProjectsListLoaded(
          projects: tProjects,
          currentProjectId: 'p1',
        ),
      ],
    );

    // Teste 8: Erro ao trocar projeto
    blocTest<ProjectsListCubit, ProjectsListState>(
      'Deve emitir erro e recarregar lista quando falhar ao trocar projeto',
      build: () {
        when(() => mockGetCurrentUserUseCase()).thenAnswer(
          (_) async => Right(tUser),
        );
        when(() => mockSwitchProjectUseCase(any(), any())).thenAnswer(
          (_) async => const Left(ServerFailure('Erro ao trocar projeto')),
        );
        when(() => mockGetProjectsUseCase(any())).thenAnswer(
          (_) async => Right(tProjects),
        );
        return projectsListCubit;
      },
      seed: () => ProjectsListLoaded(
        projects: tProjects,
        currentProjectId: 'p1',
      ),
      act: (cubit) => cubit.switchProject('p2'),
      expect: () => [
        const ProjectsListLoading(),
        const ProjectsListError('Erro ao trocar projeto'),
        const ProjectsListLoading(),
        ProjectsListLoaded(
          projects: tProjects,
          currentProjectId: 'p1',
        ),
      ],
    );

    // Teste 9: Não trocar projeto se estado não for ProjectsListLoaded
    blocTest<ProjectsListCubit, ProjectsListState>(
      'Não deve fazer nada se estado não for ProjectsListLoaded',
      build: () => projectsListCubit,
      seed: () => const ProjectsListInitial(),
      act: (cubit) => cubit.switchProject('p2'),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockSwitchProjectUseCase(any(), any()));
      },
    );

    // Teste 10: Limpar estado
    blocTest<ProjectsListCubit, ProjectsListState>(
      'Deve limpar o estado ao chamar clear',
      build: () => projectsListCubit,
      seed: () => ProjectsListLoaded(
        projects: tProjects,
        currentProjectId: 'p1',
      ),
      act: (cubit) => cubit.clear(),
      expect: () => [
        const ProjectsListInitial(),
      ],
    );

    // Teste 11: Lista vazia de projetos
    blocTest<ProjectsListCubit, ProjectsListState>(
      'Deve lidar corretamente com lista vazia de projetos',
      build: () {
        when(() => mockGetCurrentUserUseCase()).thenAnswer(
          (_) async => Right(tUser),
        );
        when(() => mockGetProjectsUseCase(any())).thenAnswer(
          (_) async => const Right([]),
        );
        return projectsListCubit;
      },
      act: (cubit) => cubit.loadProjects(),
      expect: () => [
        const ProjectsListLoading(),
        const ProjectsListLoaded(
          projects: [],
          currentProjectId: 'p1',
        ),
      ],
    );

    // Teste 12: Usuário sem projeto ativo
    blocTest<ProjectsListCubit, ProjectsListState>(
      'Deve carregar projetos mesmo sem projeto ativo definido',
      build: () {
        final userWithoutProject = UserEntity(
          id: 'user1',
          name: 'Test User',
          email: 'test@example.com',
          currentProjectId: null,
          createdAt: DateTime.now(),
        );

        when(() => mockGetCurrentUserUseCase()).thenAnswer(
          (_) async => Right(userWithoutProject),
        );
        when(() => mockGetProjectsUseCase(any())).thenAnswer(
          (_) async => Right(tProjects),
        );
        return projectsListCubit;
      },
      act: (cubit) => cubit.loadProjects(),
      expect: () => [
        const ProjectsListLoading(),
        ProjectsListLoaded(
          projects: tProjects,
          currentProjectId: null,
        ),
      ],
    );

    // Teste 13: Múltiplos projetos com diferentes situações
    test('Deve carregar projetos com diferentes situações', () async {
      final diverseProjects = <ProjectEntity>[
        ProjectEntity(
          id: 'p1',
          userId: 'user1',
          name: 'Projeto A',
          address: 'End A',
          constructorName: 'Const A',
          area: 50.0,
          deliveryDate: DateTime.now(),
          contractDate: DateTime.now(),
          contingencyPercent: 10.0,
          currentSituation: 'just_signed',
          createdAt: DateTime.now(),
        ),
        ProjectEntity(
          id: 'p2',
          userId: 'user1',
          name: 'Projeto B',
          address: 'End B',
          constructorName: 'Const B',
          area: 60.0,
          deliveryDate: DateTime.now(),
          contractDate: DateTime.now(),
          contingencyPercent: 10.0,
          currentSituation: 'construction',
          createdAt: DateTime.now(),
        ),
        ProjectEntity(
          id: 'p3',
          userId: 'user1',
          name: 'Projeto C',
          address: 'End C',
          constructorName: 'Const C',
          area: 70.0,
          deliveryDate: DateTime.now(),
          contractDate: DateTime.now(),
          contingencyPercent: 10.0,
          currentSituation: 'keys_received',
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockGetCurrentUserUseCase()).thenAnswer(
        (_) async => Right(tUser),
      );
      when(() => mockGetProjectsUseCase(any())).thenAnswer(
        (_) async => Right(diverseProjects),
      );

      await projectsListCubit.loadProjects();

      final state = projectsListCubit.state as ProjectsListLoaded;
      expect(state.projects.length, equals(3));
      expect(state.projects[0].currentSituation, equals('a'));
      expect(state.projects[1].currentSituation, equals('b'));
      expect(state.projects[2].currentSituation, equals('e'));
    });

    // Teste 14: Verificar se UseCase é chamado com userId correto
    blocTest<ProjectsListCubit, ProjectsListState>(
      'Deve chamar GetProjectsUseCase com userId correto',
      build: () {
        when(() => mockGetCurrentUserUseCase()).thenAnswer(
          (_) async => Right(tUser),
        );
        when(() => mockGetProjectsUseCase(any())).thenAnswer(
          (_) async => Right(tProjects),
        );
        return projectsListCubit;
      },
      act: (cubit) => cubit.loadProjects(),
      verify: (_) {
        verify(() => mockGetProjectsUseCase('user1')).called(1);
      },
    );

    // Teste 15: Verificar se SwitchProjectUseCase é chamado com parâmetros corretos
    blocTest<ProjectsListCubit, ProjectsListState>(
      'Deve chamar SwitchProjectUseCase com parâmetros corretos',
      build: () {
        when(() => mockGetCurrentUserUseCase()).thenAnswer(
          (_) async => Right(tUser),
        );
        when(() => mockSwitchProjectUseCase(any(), any())).thenAnswer(
          (_) async => const Right(null),
        );
        when(() => mockGetProjectsUseCase(any())).thenAnswer(
          (_) async => Right(tProjects),
        );
        return projectsListCubit;
      },
      seed: () => ProjectsListLoaded(
        projects: tProjects,
        currentProjectId: 'p1',
      ),
      act: (cubit) => cubit.switchProject('p2'),
      verify: (_) {
        verify(() => mockSwitchProjectUseCase('user1', 'p2')).called(1);
      },
    );
  });
}

// Made with Bob
