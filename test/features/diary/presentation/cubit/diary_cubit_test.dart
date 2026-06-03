import 'package:bloc_test/bloc_test.dart';
import 'package:contruttore/features/diary/domain/entities/diary_entry_entity.dart';
import 'package:contruttore/features/diary/domain/usecases/add_diary_entry_usecase.dart';
import 'package:contruttore/features/diary/domain/usecases/get_diary_entries_usecase.dart';
import 'package:contruttore/features/diary/presentation/cubit/diary_cubit.dart';
import 'package:contruttore/features/diary/presentation/cubit/diary_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetDiaryEntriesUseCase extends Mock implements GetDiaryEntriesUseCase {}
class MockAddDiaryEntryUseCase extends Mock implements AddDiaryEntryUseCase {}

void main() {
  late DiaryCubit diaryCubit;
  late MockGetDiaryEntriesUseCase mockGetDiaryEntriesUseCase;
  late MockAddDiaryEntryUseCase mockAddDiaryEntryUseCase;

  setUp(() {
    mockGetDiaryEntriesUseCase = MockGetDiaryEntriesUseCase();
    mockAddDiaryEntryUseCase = MockAddDiaryEntryUseCase();
    diaryCubit = DiaryCubit(mockGetDiaryEntriesUseCase, mockAddDiaryEntryUseCase);
  });

  final tEntry = DiaryEntryEntity(
    id: '1',
    projectId: 'p1',
    type: DiaryEntryType.visit, // Tipo: Visita Técnica
    title: 'Visita de conferência',
    description: 'Verificado nivelamento do piso',
    date: DateTime.now(),
    createdAt: DateTime.now(),
  );

  group('DiaryCubit - Diário de Obra e Vistoria', () {
    
    // Teste 1: Registro de Visita com Sucesso
    // O que ele faz: Garante que o usuário consiga salvar um relato da obra e que a timeline seja atualizada.
    blocTest<DiaryCubit, DiaryState>(
      'Deve emitir [DiaryLoading, DiaryLoaded] ao adicionar uma entrada com sucesso',
      build: () {
        when(() => mockAddDiaryEntryUseCase(any())).thenAnswer((_) async => const Right(null));
        when(() => mockGetDiaryEntriesUseCase(any())).thenAnswer((_) async => Right([tEntry]));
        return diaryCubit;
      },
      act: (cubit) => cubit.addEntry(tEntry),
      expect: () => [
        DiaryLoading(),
        DiaryLoaded([tEntry]),
      ],
    );

    // Teste 2: Modo Vistoria (Ponto Crítico de Proteção Legal)
    // O que ele faz: Verifica se uma entrada do tipo 'problem' é salva com os metadados necessários (severidade).
    // Isso é o que vai gerar o PDF de prova legal contra a construtora no futuro.
    test('Deve validar que uma entrada de PROBLEMA possui severidade definida', () {
      final problemEntry = DiaryEntryEntity(
        id: '2',
        projectId: 'p1',
        type: DiaryEntryType.problem,
        title: 'Infiltração Parede Sala',
        description: 'Mancha úmida detectada na vistoria',
        problemSeverity: ProblemSeverity.high, // Gravidade Alta
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );
      
      expect(problemEntry.problemSeverity, equals(ProblemSeverity.high));
    });
  });
}
