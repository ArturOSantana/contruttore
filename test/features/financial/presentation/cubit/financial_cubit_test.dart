import 'package:bloc_test/bloc_test.dart';
import 'package:contruttore/features/financial/domain/entities/expense_entity.dart';
import 'package:contruttore/features/financial/domain/entities/financial_summary_entity.dart';
import 'package:contruttore/features/financial/domain/usecases/add_expense_usecase.dart';
import 'package:contruttore/features/financial/domain/usecases/get_expenses_usecase.dart';
import 'package:contruttore/features/financial/domain/usecases/get_financial_summary_usecase.dart';
import 'package:contruttore/features/financial/domain/usecases/update_expense_usecase.dart';
import 'package:contruttore/features/financial/presentation/cubit/financial_cubit.dart';
import 'package:contruttore/features/financial/presentation/cubit/financial_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetFinancialSummaryUseCase extends Mock implements GetFinancialSummaryUseCase {}
class MockGetExpensesUseCase extends Mock implements GetExpensesUseCase {}
class MockAddExpenseUseCase extends Mock implements AddExpenseUseCase {}
class MockUpdateExpenseUseCase extends Mock implements UpdateExpenseUseCase {}

void main() {
  late FinancialCubit financialCubit;
  late MockGetFinancialSummaryUseCase mockGetFinancialSummaryUseCase;
  late MockGetExpensesUseCase mockGetExpensesUseCase;
  late MockAddExpenseUseCase mockAddExpenseUseCase;
  late MockUpdateExpenseUseCase mockUpdateExpenseUseCase;

  setUp(() {
    mockGetFinancialSummaryUseCase = MockGetFinancialSummaryUseCase();
    mockGetExpensesUseCase = MockGetExpensesUseCase();
    mockAddExpenseUseCase = MockAddExpenseUseCase();
    mockUpdateExpenseUseCase = MockUpdateExpenseUseCase();

    financialCubit = FinancialCubit(
      mockGetFinancialSummaryUseCase,
      mockGetExpensesUseCase,
      mockAddExpenseUseCase,
      mockUpdateExpenseUseCase,
    );
  });

  const tSummary = FinancialSummaryEntity(
    totalBudget: 100000,
    totalSpent: 45000,
    totalCommitted: 20000,
    totalEstimated: 35000,
    categories: [],
  );

  final tExpenses = [
    ExpenseEntity(
      id: '1',
      projectId: 'p1',
      categoryId: 'cat1',
      amount: 1000,
      date: DateTime.now(),
      description: 'Piso',
      status: ExpenseStatus.confirmed,
      createdAt: DateTime.now(),
    ),
    ExpenseEntity(
      id: '2',
      projectId: 'p1',
      categoryId: 'cat2',
      amount: 500,
      date: DateTime.now(),
      description: 'Torneira',
      status: ExpenseStatus.estimated,
      createdAt: DateTime.now(),
    ),
  ];

  group('FinancialCubit - Gestão de Gastos', () {
    
    // Teste 1: Carregamento de dados financeiros
    // O que ele faz: Garante que o resumo e a lista de despesas são carregados juntos, emitindo o estado de Loaded.
    blocTest<FinancialCubit, FinancialState>(
      'Deve emitir [FinancialLoading, FinancialLoaded] quando os dados forem carregados com sucesso',
      build: () {
        when(() => mockGetFinancialSummaryUseCase(any()))
            .thenAnswer((_) async => const Right(tSummary));
        when(() => mockGetExpensesUseCase(any()))
            .thenAnswer((_) async => Right(tExpenses));
        return financialCubit;
      },
      act: (cubit) => cubit.loadFinancialData('p1'),
      expect: () => [
        FinancialLoading(),
        FinancialLoaded(summary: tSummary, expenses: tExpenses, categories: const []),
      ],
    );

    // Teste 2: Filtro por Status (Confirmação dos 3 medos)
    // O que ele faz: Verifica se o Cubit consegue filtrar a lista entre o que já foi pago (confirmed) e o que é estimativa (estimated).
    // Isso atende ao requisito de "Custo Total Real" vs "Gasto Confirmado".
    blocTest<FinancialCubit, FinancialState>(
      'Deve filtrar a lista de despesas para mostrar apenas as ESTIMADAS',
      build: () {
        // Primeiro carrega o estado com dados
        financialCubit.emit(FinancialLoaded(summary: tSummary, expenses: tExpenses, categories: const []));
        return financialCubit;
      },
      act: (cubit) => cubit.filterByStatus(ExpenseStatus.estimated),
      expect: () => [
        isA<FinancialLoaded>().having((s) => s.expenses.length, 'length', 1)
                                .having((s) => s.expenses.first.description, 'item', 'Torneira'),
      ],
    );

    // Teste 3: Adição de Despesa com Recarregamento
    // O que ele faz: Após adicionar uma nova despesa, o Cubit deve automaticamente recarregar os dados do projeto.
    blocTest<FinancialCubit, FinancialState>(
      'Deve recarregar os dados financeiros após adicionar uma nova despesa',
      build: () {
        when(() => mockAddExpenseUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetFinancialSummaryUseCase(any()))
            .thenAnswer((_) async => const Right(tSummary));
        when(() => mockGetExpensesUseCase(any()))
            .thenAnswer((_) async => Right(tExpenses));
        return financialCubit;
      },
      act: (cubit) => cubit.addExpense(tExpenses.first),
      verify: (_) {
        verify(() => mockAddExpenseUseCase(any())).called(1);
        verify(() => mockGetFinancialSummaryUseCase('p1')).called(1);
      },
    );
  });
}
