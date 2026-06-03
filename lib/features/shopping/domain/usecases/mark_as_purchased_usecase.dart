import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../repositories/shopping_repository.dart';
import '../../../financial/domain/entities/transaction_entity.dart';
import '../../../financial/domain/usecases/create_shopping_purchase_usecase.dart';

/// Use Case para marcar item como comprado
///
/// MIGRADO PARA NOVA ARQUITETURA:
/// - Usa CreateShoppingPurchaseUseCase (operação atômica com WriteBatch)
/// - Cria TransactionEntity (expense) ao invés de criar direto no financeiro
/// - Se havia estimate, marca como fulfilled (preserva histórico)
/// - Garante atomicidade: shopping + transaction juntos ou nenhum
@injectable
class MarkAsPurchasedUseCase {
  final ShoppingRepository _shoppingRepository;
  final CreateShoppingPurchaseUseCase _createPurchaseUseCase;
  final Uuid _uuid;

  MarkAsPurchasedUseCase(
    this._shoppingRepository,
    this._createPurchaseUseCase,
    this._uuid,
  );

  Future<Either<Failure, void>> call({
    required String projectId,
    required String itemId,
    required double actualPrice,
    required String store,
    required DateTime purchaseDate,
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

    // 2. Criar transaction (expense) da compra
    final expenseTransaction = TransactionEntity(
      id: _uuid.v4(),
      projectId: projectId,
      type: TransactionType.expense,
      source: TransactionSource.shopping,
      amount: actualPrice * item.quantity,
      signedAmount: actualPrice * item.quantity, // Positivo
      date: purchaseDate,
      description: '${item.name} (${item.quantity} ${item.unit})',
      shoppingItemId: itemId,
      phaseId: item.phaseId,
      categoryId: null, // Será mapeado pela categoria do shopping
      status: TransactionStatus.active,
      createdAt: DateTime.now(),
    );

    // 3. Preparar update do shopping item
    final shoppingUpdate = {
      'isPurchased': true,
      'actualPrice': actualPrice,
      'store': store,
      'purchaseDate': Timestamp.fromDate(
        purchaseDate,
      ), // CORRIGIDO: usar Timestamp
      'expenseTransactionId':
          expenseTransaction.id, // Armazenar ID da transaction
    };

    // 4. Se havia estimate, buscar para marcar como fulfilled
    // (será feito pelo CreateShoppingPurchaseUseCase)

    // 5. Executar operação atômica
    return await _createPurchaseUseCase(
      CreateShoppingPurchaseParams(
        projectId: projectId,
        shoppingItemId: itemId,
        transaction: expenseTransaction,
        shoppingItemUpdate: shoppingUpdate,
      ),
    );
  }
}

// Made with Bob
