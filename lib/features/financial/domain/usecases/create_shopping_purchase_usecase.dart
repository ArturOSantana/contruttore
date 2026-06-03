import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Use case para criar transação de compra de item
///
/// Operação atômica que:
/// 1. Atualiza o shopping item (marca como comprado)
/// 2. Cria a transaction (expense)
/// 3. Marca estimate como fulfilled (se existir)
@lazySingleton
class CreateShoppingPurchaseUseCase
    implements UseCase<void, CreateShoppingPurchaseParams> {
  final TransactionRepository _repository;

  CreateShoppingPurchaseUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(
    CreateShoppingPurchaseParams params,
  ) async {
    return await _repository.createShoppingPurchaseTransaction(
      projectId: params.projectId,
      shoppingItemId: params.shoppingItemId,
      transaction: params.transaction,
      shoppingItemUpdate: params.shoppingItemUpdate,
      estimateTransactionId: params.estimateTransactionId,
    );
  }
}

class CreateShoppingPurchaseParams {
  final String projectId;
  final String shoppingItemId;
  final TransactionEntity transaction;
  final Map<String, dynamic> shoppingItemUpdate;
  final String? estimateTransactionId;

  CreateShoppingPurchaseParams({
    required this.projectId,
    required this.shoppingItemId,
    required this.transaction,
    required this.shoppingItemUpdate,
    this.estimateTransactionId,
  });
}

// Made with Bob
