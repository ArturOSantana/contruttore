import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../diary/domain/usecases/add_automatic_entry_usecase.dart';
import '../../../diary/domain/entities/diary_entry_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/usecases/add_manual_transaction_usecase.dart';
import '../../domain/usecases/update_transaction_usecase.dart';
import '../../domain/usecases/delete_transaction_usecase.dart';
import '../../domain/usecases/get_financial_summary_usecase.dart';
import '../../domain/usecases/update_phase_financials_usecase.dart';
import 'financial_state.dart';

@injectable
class FinancialCubit extends Cubit<FinancialState> {
  final GetFinancialSummaryUseCase _getFinancialSummaryUseCase;
  final GetTransactionsUseCase _getTransactionsUseCase;
  final AddManualTransactionUseCase _addManualTransactionUseCase;
  final UpdateTransactionUseCase _updateTransactionUseCase;
  final DeleteTransactionUseCase _deleteTransactionUseCase;
  final UpdatePhaseFinancialsUseCase _updatePhaseFinancialsUseCase;
  final AddAutomaticEntryUseCase _addAutomaticEntryUseCase;

  FinancialCubit(
    this._getFinancialSummaryUseCase,
    this._getTransactionsUseCase,
    this._addManualTransactionUseCase,
    this._updateTransactionUseCase,
    this._deleteTransactionUseCase,
    this._updatePhaseFinancialsUseCase,
    this._addAutomaticEntryUseCase,
  ) : super(FinancialInitial());

  Future<void> loadFinancialData(String projectId) async {
    emit(FinancialLoading());

    final summaryResult = await _getFinancialSummaryUseCase(projectId);
    final transactionsResult = await _getTransactionsUseCase(projectId);

    if (summaryResult.isLeft() || transactionsResult.isLeft()) {
      emit(FinancialError('Erro ao carregar dados financeiros'));
      return;
    }

    final summary = summaryResult.getOrElse(() => throw Exception());
    final transactions = transactionsResult.getOrElse(() => throw Exception());

    emit(
      FinancialLoaded(
        summary: summary,
        transactions: transactions,
        categories: [], // Categorias já estão no summary
      ),
    );
  }

  Future<void> addTransaction({
    required String projectId,
    required String description,
    required double amount,
    required DateTime date,
    String? phaseId,
    String? categoryId,
    String? supplierId,
    String? invoicePhotoUrl,
    String? notes,
  }) async {
    final result = await _addManualTransactionUseCase(
      projectId: projectId,
      description: description,
      amount: amount,
      date: date,
      phaseId: phaseId,
      categoryId: categoryId,
      supplierId: supplierId,
      invoicePhotoUrl: invoicePhotoUrl,
      notes: notes,
    );

    result.fold(
      (failure) {
        emit(FinancialError(failure.message));
      },
      (_) async {
        // Atualizar financeiro da fase se houver phaseId
        if (phaseId != null) {
          await _updatePhaseFinancialsUseCase(
            projectId: projectId,
            phaseId: phaseId,
          );
        }

        // Adicionar log automático no diário
        await _addAutomaticEntryUseCase(
          projectId: projectId,
          title: 'Despesa adicionada',
          description: '$description - R\$ ${amount.toStringAsFixed(2)}',
          phaseId: phaseId,
          type: DiaryEntryType.daily,
        );

        await loadFinancialData(projectId);
      },
    );
  }

  Future<void> updateTransaction({
    required String projectId,
    required String transactionId,
    String? description,
    double? amount,
    DateTime? date,
    String? phaseId,
    String? categoryId,
    String? supplierId,
    String? invoicePhotoUrl,
    String? notes,
  }) async {
    final result = await _updateTransactionUseCase(
      projectId: projectId,
      transactionId: transactionId,
      description: description,
      amount: amount,
      date: date,
      phaseId: phaseId,
      categoryId: categoryId,
      supplierId: supplierId,
      invoicePhotoUrl: invoicePhotoUrl,
      notes: notes,
    );

    result.fold(
      (failure) {
        emit(FinancialError(failure.message));
      },
      (_) async {
        // Atualizar financeiro da fase se houver phaseId
        if (phaseId != null) {
          await _updatePhaseFinancialsUseCase(
            projectId: projectId,
            phaseId: phaseId,
          );
        }

        // Adicionar log automático no diário
        if (description != null) {
          await _addAutomaticEntryUseCase(
            projectId: projectId,
            title: 'Despesa atualizada',
            description: description,
            phaseId: phaseId,
            type: DiaryEntryType.daily,
          );
        }

        await loadFinancialData(projectId);
      },
    );
  }

  Future<void> deleteTransaction(
    String projectId,
    String transactionId, {
    String? phaseId,
    String? description,
  }) async {
    final result = await _deleteTransactionUseCase(
      projectId: projectId,
      transactionId: transactionId,
    );

    result.fold(
      (failure) {
        emit(FinancialError(failure.message));
      },
      (_) async {
        // Atualizar financeiro da fase se houver phaseId
        if (phaseId != null) {
          await _updatePhaseFinancialsUseCase(
            projectId: projectId,
            phaseId: phaseId,
          );
        }

        // Adicionar log automático no diário
        if (description != null) {
          await _addAutomaticEntryUseCase(
            projectId: projectId,
            title: 'Despesa removida',
            description: description,
            phaseId: phaseId,
            type: DiaryEntryType.daily,
          );
        }

        await loadFinancialData(projectId);
      },
    );
  }

  void filterByType(TransactionType? type) {
    final currentState = state;
    if (currentState is! FinancialLoaded) return;

    if (type == null) {
      // Recarregar todos
      loadFinancialData(currentState.summary.totalBudget.toString());
    } else {
      // Filtrar por tipo
      final filteredTransactions =
          currentState.transactions.where((t) => t.type == type).toList();

      emit(
        FinancialLoaded(
          summary: currentState.summary,
          transactions: filteredTransactions,
          categories: currentState.categories,
        ),
      );
    }
  }

  void filterBySource(TransactionSource? source) {
    final currentState = state;
    if (currentState is! FinancialLoaded) return;

    if (source == null) {
      // Recarregar todos
      loadFinancialData(currentState.summary.totalBudget.toString());
    } else {
      // Filtrar por origem
      final filteredTransactions =
          currentState.transactions.where((t) => t.source == source).toList();

      emit(
        FinancialLoaded(
          summary: currentState.summary,
          transactions: filteredTransactions,
          categories: currentState.categories,
        ),
      );
    }
  }

  void filterByStatus(TransactionStatus? status) {
    final currentState = state;
    if (currentState is! FinancialLoaded) return;

    if (status == null) {
      // Recarregar todos
      loadFinancialData(currentState.summary.totalBudget.toString());
    } else {
      // Filtrar por status
      final filteredTransactions =
          currentState.transactions.where((t) => t.status == status).toList();

      emit(
        FinancialLoaded(
          summary: currentState.summary,
          transactions: filteredTransactions,
          categories: currentState.categories,
        ),
      );
    }
  }
}

// Made with Bob
