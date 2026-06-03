import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense_entity.dart';
import '../entities/category_entity.dart';
import '../entities/financial_summary_entity.dart';

abstract class FinancialRepository {
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses(String projectId);
  Future<Either<Failure, ExpenseEntity>> getExpense(
    String projectId,
    String expenseId,
  );
  Future<Either<Failure, void>> addExpense(ExpenseEntity expense);
  Future<Either<Failure, void>> updateExpense(ExpenseEntity expense);
  Future<Either<Failure, void>> deleteExpense(
    String projectId,
    String expenseId,
  );

  Future<Either<Failure, List<CategoryEntity>>> getCategories(String projectId);
  Future<Either<Failure, void>> updateCategoryBudget(
    String projectId,
    String categoryId,
    double newBudget,
  );
  Future<Either<Failure, void>> initializeDefaultCategories(
    String projectId,
    CategoryType type,
  );

  Future<Either<Failure, FinancialSummaryEntity>> getFinancialSummary(
    String projectId,
  );
}

// Made with Bob
