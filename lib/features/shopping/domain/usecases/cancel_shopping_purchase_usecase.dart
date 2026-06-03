import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../repositories/shopping_repository.dart';
import '../../../financial/domain/entities/transaction_entity.dart';
import '../../../financial/domain/repositories/transaction_repository.dart';

/// Use Case para cancelar uma compra (devolver item)
///
/// NOVA ARQUITETURA:
/// - Usa TransactionRepository.cancelShoppingPurchase (operação atômica)
/// - Cria TransactionEntity de reversal (signedAmount negativo)
/// - Desmarca item como comprado
/// - Garante atomicidade: shopping + reversal juntos ou nenhum
@injectable
class CancelShoppingPurchaseUseCase {
  final ShoppingRepository _shoppingRepository;
  final TransactionRepository _transactionRepository;
  final Uuid _uuid;

  CancelShoppingPurchaseUseCase(
    this._shoppingRepository,
    this._transactionRepository,
    this._uuid,
  );

  Future<Either<Failure, void>> call({
    required String projectId,
    required String itemId,
    required String expenseTransactionId,
  }) async {
    // 1. Buscar o item atual para preparar o update
    final itemsResult = await _shoppingRepository.getShoppingItems(projectId);

    if (itemsResult.isLeft()) {
      return itemsResult.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    }

    final items = itemsResult.getOrElse(() => throw Exception());
    final item = items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );

    // Validar que o item está comprado
    if (!item.isPurchased) {
      return Left(ValidationFailure('Item não está marcado como comprado'));
    }

    // 2. Criar transaction de reversal (signedAmount negativo)
    final reversalTransaction = TransactionEntity(
      id: _uuid.v4(),
      projectId: projectId,
      type: TransactionType.reversal,
      source: TransactionSource.shoppingReversal,
      amount: item.totalActual,
      signedAmount: -item.totalActual, // NEGATIVO para reversal
      date: DateTime.now(),
      description: 'Devolução: ${item.name} (${item.quantity} ${item.unit})',
      shoppingItemId: itemId,
      phaseId: item.phaseId,
      categoryId: null,
      relatedTransactionId: expenseTransactionId, // Link para expense original
      status: TransactionStatus.active,
      createdAt: DateTime.now(),
    );

    // 3. Preparar update do shopping item (desmarcar como comprado)
    final shoppingUpdate = {
      'isPurchased': false,
      'actualPrice': null,
      'store': null,
      'purchaseDate': null,
    };

    // 4. Executar operação atômica
    return await _transactionRepository.cancelShoppingPurchase(
      projectId: projectId,
      shoppingItemId: itemId,
      originalTransactionId: expenseTransactionId,
      reversalTransaction: reversalTransaction,
      shoppingItemUpdate: shoppingUpdate,
    );
  }
}

// Made with Bob
