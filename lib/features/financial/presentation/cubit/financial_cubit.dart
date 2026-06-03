import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import '../../domain/usecases/get_financial_summary_usecase.dart';
import '../../domain/usecases/update_expense_usecase.dart';
import 'financial_state.dart';

@injectable
class FinancialCubit extends Cubit<FinancialState> {
  final GetFinancialSummaryUseCase _getFinancialSummaryUseCase;
  final GetExpensesUseCase _getExpensesUseCase;
  final AddExpenseUseCase _addExpenseUseCase;
  final UpdateExpenseUseCase _updateExpenseUseCase;
  final DeleteExpenseUseCase _deleteExpenseUseCase;

  FinancialCubit(
    this._getFinancialSummaryUseCase,
    this._getExpensesUseCase,
    this._addExpenseUseCase,
    this._updateExpenseUseCase,
    this._deleteExpenseUseCase,
  ) : super(FinancialInitial());

  Future<void> loadFinancialData(String projectId) async {
    emit(FinancialLoading());

    final summaryResult = await _getFinancialSummaryUseCase(projectId);
    final expensesResult = await _getExpensesUseCase(projectId);

    if (summaryResult.isLeft() || expensesResult.isLeft()) {
      emit(FinancialError('Erro ao carregar dados financeiros'));
      return;
    }

    final summary = summaryResult.getOrElse(() => throw Exception());
    final expenses = expensesResult.getOrElse(() => throw Exception());

    emit(
      FinancialLoaded(
        summary: summary,
        expenses: expenses,
        categories: [], // Categorias já estão no summary
      ),
    );
  }

  Future<void> addExpense(ExpenseEntity expense) async {
    final result = await _addExpenseUseCase(expense);

    result.fold(
      (failure) => emit(FinancialError(failure.message)),
      (_) => loadFinancialData(expense.projectId),
    );
  }

  Future<void> updateExpense(ExpenseEntity expense) async {
    final result = await _updateExpenseUseCase(expense);

    result.fold(
      (failure) => emit(FinancialError(failure.message)),
      (_) => loadFinancialData(expense.projectId),
    );
  }

  Future<void> deleteExpense(String projectId, String expenseId) async {
    final result = await _deleteExpenseUseCase(
      DeleteExpenseParams(projectId: projectId, expenseId: expenseId),
    );

    result.fold(
      (failure) => emit(FinancialError(failure.message)),
      (_) => loadFinancialData(projectId),
    );
  }

  void filterByCategory(String? categoryId) {
    final currentState = state;
    if (currentState is! FinancialLoaded) return;

    if (categoryId == null) {
      // Mostrar todas as despesas
      emit(
        FinancialLoaded(
          summary: currentState.summary,
          expenses: currentState.expenses,
          categories: currentState.categories,
        ),
      );
    } else {
      // Filtrar por categoria
      final filteredExpenses = currentState.expenses
          .where((e) => e.categoryId == categoryId)
          .toList();

      emit(
        FinancialLoaded(
          summary: currentState.summary,
          expenses: filteredExpenses,
          categories: currentState.categories,
        ),
      );
    }
  }

  void filterByStatus(ExpenseStatus? status) {
    final currentState = state;
    if (currentState is! FinancialLoaded) return;

    if (status == null) {
      // Mostrar todas as despesas
      emit(
        FinancialLoaded(
          summary: currentState.summary,
          expenses: currentState.expenses,
          categories: currentState.categories,
        ),
      );
    } else {
      // Filtrar por status
      final filteredExpenses = currentState.expenses
          .where((e) => e.status == status)
          .toList();

      emit(
        FinancialLoaded(
          summary: currentState.summary,
          expenses: filteredExpenses,
          categories: currentState.categories,
        ),
      );
    }
  }
}

// Made with Bob
