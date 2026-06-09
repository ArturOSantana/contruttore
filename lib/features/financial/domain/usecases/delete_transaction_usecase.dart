import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/transaction_repository.dart';

/// Use case para deletar uma transação
///
/// IMPORTANTE: Apenas transações manuais podem ser deletadas
/// Transações de shopping, installments e contracts devem ser canceladas
/// usando os métodos específicos (cancelShoppingPurchase, cancelInstallmentPayment, etc)
@lazySingleton
class DeleteTransactionUseCase {
  final TransactionRepository _repository;

  DeleteTransactionUseCase(this._repository);

  /// Deleta uma transação manual
  ///
  /// Retorna erro se tentar deletar transação não-manual
  Future<Either<Failure, void>> call({
    required String projectId,
    required String transactionId,
  }) async {
    return _repository.deleteTransaction(projectId, transactionId);
  }
}

// Made with Bob
