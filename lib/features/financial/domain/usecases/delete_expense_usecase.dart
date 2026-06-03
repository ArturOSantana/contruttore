import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/financial_repository.dart';

@injectable
class DeleteExpenseUseCase implements UseCase<void, DeleteExpenseParams> {
  final FinancialRepository repository;

  DeleteExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteExpenseParams params) async {
    return await repository.deleteExpense(params.projectId, params.expenseId);
  }
}

class DeleteExpenseParams {
  final String projectId;
  final String expenseId;

  DeleteExpenseParams({required this.projectId, required this.expenseId});
}

// Made with Bob
