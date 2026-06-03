import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense_entity.dart';
import '../repositories/financial_repository.dart';

@injectable
class GetExpensesUseCase {
  final FinancialRepository _repository;

  GetExpensesUseCase(this._repository);

  Future<Either<Failure, List<ExpenseEntity>>> call(String projectId) {
    return _repository.getExpenses(projectId);
  }
}

// Made with Bob
