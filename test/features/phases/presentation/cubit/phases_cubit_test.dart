import 'package:bloc_test/bloc_test.dart';
import 'package:contruttore/features/phases/domain/entities/phase_entity.dart';
import 'package:contruttore/features/phases/domain/usecases/complete_phase_usecase.dart';
import 'package:contruttore/features/phases/domain/usecases/get_phases_usecase.dart';
import 'package:contruttore/features/phases/domain/usecases/toggle_subtask_usecase.dart';
import 'package:contruttore/features/phases/presentation/cubit/phases_cubit.dart';
import 'package:contruttore/features/phases/presentation/cubit/phases_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetPhasesUseCase extends Mock implements GetPhasesUseCase {}
class MockToggleSubtaskUseCase extends Mock implements ToggleSubtaskUseCase {}
class MockCompletePhaseUseCase extends Mock implements CompletePhaseUseCase {}

void main() {
  late PhasesCubit phasesCubit;
  late MockGetPhasesUseCase mockGetPhasesUseCase;
  late MockToggleSubtaskUseCase mockToggleSubtaskUseCase;
  late MockCompletePhaseUseCase mockCompletePhaseUseCase;

  setUp(() {
    mockGetPhasesUseCase = MockGetPhasesUseCase();
    mockToggleSubtaskUseCase = MockToggleSubtaskUseCase();
    mockCompletePhaseUseCase = MockCompletePhaseUseCase();

    phasesCubit = PhasesCubit(
      mockGetPhasesUseCase,
      mockToggleSubtaskUseCase,
      mockCompletePhaseUseCase,
    );
  });

  final tPhases = [
    PhaseEntity(
      id: '1',
      number: 1,
      name: 'Assinatura',
      description: 'Fase inicial',
      status: PhaseStatus.active,
      subtasks: const [],
    ),
  ];

  group('PhasesCubit - Gestão de Cronograma', () {
    
    // Teste 1: Carregamento das 12 fases
    // O que ele faz: Verifica se ao entrar no projeto, o app carrega a lista completa de fases e emite o estado Loaded.
    blocTest<PhasesCubit, PhasesState>(
      'Deve emitir [PhasesLoading, PhasesLoaded] ao carregar as fases com sucesso',
      build: () {
        when(() => mockGetPhasesUseCase(any()))
            .thenAnswer((_) async => Right(tPhases));
        return phasesCubit;
      },
      act: (cubit) => cubit.loadPhases('project_123'),
      expect: () => [
        PhasesLoading(),
        PhasesLoaded(tPhases),
      ],
    );

    // Teste 2: Regra de Negócio - Marcar Subtarefa
    // O que ele faz: Garante que ao clicar em uma tarefa (ex: "Salvar contrato"), 
    // o app chama o caso de uso e recarrega a lista para atualizar o progresso visual.
    blocTest<PhasesCubit, PhasesState>(
      'Deve chamar toggleSubtask e recarregar a lista para atualizar o progresso',
      build: () {
        when(() => mockToggleSubtaskUseCase(
              projectId: any(named: 'projectId'),
              phaseId: any(named: 'phaseId'),
              subtaskId: any(named: 'subtaskId'),
            )).thenAnswer((_) async => const Right(null));
        when(() => mockGetPhasesUseCase(any()))
            .thenAnswer((_) async => Right(tPhases));
        return phasesCubit;
      },
      act: (cubit) => cubit.toggleSubtask(
        projectId: 'p1',
        phaseId: 'f1',
        subtaskId: 's1',
      ),
      verify: (_) {
        verify(() => mockToggleSubtaskUseCase(
          projectId: 'p1',
          phaseId: 'f1',
          subtaskId: 's1',
        )).called(1);
      },
    );

    // Teste 3 (Futuro): Bloqueio de Fase Incompleta
    // O que ele faz: Este teste simula a tentativa de concluir uma fase sem marcar as tarefas obrigatórias.
    // Atualmente, a lógica deve impedir a chamada do usecase ou retornar um erro específico.
    blocTest<PhasesCubit, PhasesState>(
      'Deve emitir PhasesError se tentar concluir uma fase que possui subtarefas obrigatórias pendentes',
      build: () {
        // Mock de falha na regra de negócio (futuro)
        when(() => mockCompletePhaseUseCase(
          projectId: any(named: 'projectId'),
          phaseId: any(named: 'phaseId'),
        )).thenAnswer((_) async => const Left(BusinessFailure('Conclua todas as tarefas obrigatórias antes.')));
        return phasesCubit;
      },
      act: (cubit) => cubit.completePhase(projectId: 'p1', phaseId: 'f1'),
      expect: () => [
        const PhasesError('Conclua todas as tarefas obrigatórias antes.'),
      ],
    );
  });
}
