import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense_entity.dart';
import '../repositories/financial_repository.dart';

@injectable
class UpdateExpenseUseCase {
  final FinancialRepository _repository;

  UpdateExpenseUseCase(this._repository);

  Future<Either<Failure, void>> call(ExpenseEntity expense) {
    return _repository.updateExpense(expense);
  }
}

// Made with Bob
