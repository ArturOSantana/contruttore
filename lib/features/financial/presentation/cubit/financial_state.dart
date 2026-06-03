import 'package:equatable/equatable.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/financial_summary_entity.dart';

abstract class FinancialState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FinancialInitial extends FinancialState {}

class FinancialLoading extends FinancialState {}

class FinancialLoaded extends FinancialState {
  final FinancialSummaryEntity summary;
  final List<ExpenseEntity> expenses;
  final List<CategoryEntity> categories;

  FinancialLoaded({
    required this.summary,
    required this.expenses,
    required this.categories,
  });

  @override
  List<Object?> get props => [summary, expenses, categories];
}

class FinancialError extends FinancialState {
  final String message;

  FinancialError(this.message);

  @override
  List<Object?> get props => [message];
}

// Made with Bob
