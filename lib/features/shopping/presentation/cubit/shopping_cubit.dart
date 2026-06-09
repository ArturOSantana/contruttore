import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/payment_generator.dart';
import '../../../payments/domain/repositories/payment_repository.dart';
import '../../../financial/domain/usecases/update_phase_financials_usecase.dart';
import '../../../diary/domain/usecases/add_automatic_entry_usecase.dart';
import '../../../diary/domain/entities/diary_entry_entity.dart';
import '../../domain/entities/shopping_item_entity.dart';
import '../../domain/usecases/get_shopping_items_usecase.dart';
import '../../domain/usecases/add_shopping_item_usecase.dart';
import '../../domain/usecases/mark_as_purchased_usecase.dart';
import '../../domain/usecases/cancel_shopping_purchase_usecase.dart';
import '../../domain/usecases/generate_suggestions_usecase.dart';
import '../../domain/usecases/delete_shopping_item_usecase.dart';
import 'shopping_state.dart';

@injectable
class ShoppingCubit extends Cubit<ShoppingState> {
  final GetShoppingItemsUseCase _getShoppingItemsUseCase;
  final AddShoppingItemUseCase _addShoppingItemUseCase;
  final MarkAsPurchasedUseCase _markAsPurchasedUseCase;
  final CancelShoppingPurchaseUseCase _cancelPurchaseUseCase;
  final GenerateSuggestionsUseCase _generateSuggestionsUseCase;
  final DeleteShoppingItemUseCase _deleteShoppingItemUseCase;
  final PaymentRepository _paymentRepository;
  final UpdatePhaseFinancialsUseCase _updatePhaseFinancialsUseCase;
  final AddAutomaticEntryUseCase _addAutomaticEntryUseCase;

  ShoppingCubit(
    this._getShoppingItemsUseCase,
    this._addShoppingItemUseCase,
    this._markAsPurchasedUseCase,
    this._cancelPurchaseUseCase,
    this._generateSuggestionsUseCase,
    this._deleteShoppingItemUseCase,
    this._paymentRepository,
    this._updatePhaseFinancialsUseCase,
    this._addAutomaticEntryUseCase,
  ) : super(ShoppingInitial());

  Future<void> loadShoppingItems(String projectId) async {
    emit(ShoppingLoading());

    final result = await _getShoppingItemsUseCase(projectId);

    result.fold((failure) => emit(ShoppingError(failure.message)), (items) {
      double totalEstimated = 0;
      double totalPaid = 0;
      int pendingCount = 0;
      int purchasedCount = 0;

      for (final item in items) {
        totalEstimated += item.totalEstimated;
        if (item.isPurchased) {
          totalPaid += item.totalActual;
          purchasedCount++;
        } else {
          pendingCount++;
        }
      }

      emit(
        ShoppingLoaded(
          items: items,
          totalEstimated: totalEstimated,
          totalPaid: totalPaid,
          pendingCount: pendingCount,
          purchasedCount: purchasedCount,
        ),
      );
    });
  }

  Future<void> addShoppingItem(ShoppingItemEntity item) async {
    final result = await _addShoppingItemUseCase(item);

    result.fold((failure) => emit(ShoppingError(failure.message)), (_) {
      emit(ShoppingOperationSuccess('Item adicionado com sucesso'));
      loadShoppingItems(item.projectId);
    });
  }

  // Alias para compatibilidade com forms
  Future<void> addItem(ShoppingItemEntity item) async {
    await addShoppingItem(item);
  }

  // Método para atualizar item
  Future<void> updateItem(ShoppingItemEntity item) async {
    await addShoppingItem(item); // Reutiliza o mesmo método
  }

  /// Marca item como comprado
  ///
  /// MIGRADO PARA NOVA ARQUITETURA:
  /// - Usa MarkAsPurchasedUseCase que cria TransactionEntity
  /// - Operação atômica (shopping + transaction)
  /// - Se havia estimate, marca como fulfilled
  /// - Se parcelado, gera payments automaticamente
  /// - Atualiza financeiro da fase automaticamente
  /// - Adiciona log no diário automaticamente
  Future<void> markAsPurchased({
    required String projectId,
    required String itemId,
    required double actualPrice,
    required String store,
    required DateTime purchaseDate,
    int installments = 1,
    DateTime? firstPaymentDate,
  }) async {
    // Busca o item para pegar informações
    final itemsResult = await _getShoppingItemsUseCase(projectId);
    String itemName = 'Compra';
    String? phaseId;

    itemsResult.fold((_) => itemName = 'Compra', (items) {
      try {
        final item = items.firstWhere((i) => i.id == itemId);
        itemName = item.name;
        phaseId = item.phaseId;
      } catch (e) {
        // Item não encontrado, usa valores padrão
        itemName = 'Compra';
        phaseId = null;
      }
    });

    final result = await _markAsPurchasedUseCase(
      projectId: projectId,
      itemId: itemId,
      actualPrice: actualPrice,
      store: store,
      purchaseDate: purchaseDate,
    );

    await result.fold((failure) async => emit(ShoppingError(failure.message)), (
      _,
    ) async {
      // Se a compra é parcelada, gera payments automaticamente
      if (installments > 1 && firstPaymentDate != null) {
        try {
          final payments = PaymentGenerator.generatePayments(
            projectId: projectId,
            name: itemName,
            sourceType: 'purchase',
            sourceId: itemId,
            totalAmount: actualPrice,
            installments: installments,
            firstPaymentDate: firstPaymentDate,
          );

          await _paymentRepository.createPayments(payments);
        } catch (e) {
          // Se falhar ao criar payments, emite erro mas não falha a operação
          emit(ShoppingError('Item comprado, mas erro ao gerar parcelas: $e'));
          return;
        }
      }

      // Atualizar financeiro da fase se houver phaseId
      if (phaseId != null) {
        await _updatePhaseFinancialsUseCase(
          projectId: projectId,
          phaseId: phaseId!,
        );
      }

      // Adicionar log automático no diário
      await _addAutomaticEntryUseCase(
        projectId: projectId,
        title: 'Compra realizada',
        description:
            '$itemName - $store - R\$ ${actualPrice.toStringAsFixed(2)}',
        phaseId: phaseId,
        type: DiaryEntryType.delivery,
      );

      emit(ShoppingOperationSuccess('Item marcado como comprado'));
      loadShoppingItems(projectId);
    });
  }

  /// Cancela uma compra (devolve item)
  ///
  /// NOVA ARQUITETURA:
  /// - Usa CancelShoppingPurchaseUseCase
  /// - Cria TransactionEntity de reversal (signedAmount negativo)
  /// - Desmarca item como comprado
  /// - Operação atômica (shopping + reversal)
  Future<void> returnItem({
    required String projectId,
    required String itemId,
    required String expenseTransactionId,
  }) async {
    final result = await _cancelPurchaseUseCase(
      projectId: projectId,
      itemId: itemId,
      expenseTransactionId: expenseTransactionId,
    );

    result.fold((failure) => emit(ShoppingError(failure.message)), (_) {
      emit(ShoppingOperationSuccess('Item devolvido com sucesso'));
      loadShoppingItems(projectId);
    });
  }

  Future<void> generateSuggestions({
    required String projectId,
    required int phaseNumber,
  }) async {
    final suggestions = _generateSuggestionsUseCase(
      projectId: projectId,
      phaseNumber: phaseNumber,
    );

    for (final suggestion in suggestions) {
      await _addShoppingItemUseCase(suggestion);
    }

    emit(
      ShoppingOperationSuccess('${suggestions.length} sugestões adicionadas'),
    );
    loadShoppingItems(projectId);
  }

  Future<void> deleteShoppingItem(String projectId, String itemId) async {
    emit(ShoppingLoading());

    // Primeiro cancela os payments pendentes deste item
    try {
      await _paymentRepository.cancelPendingPaymentsBySource(
        projectId: projectId,
        sourceId: itemId,
      );
    } catch (e) {
      // Se falhar ao cancelar payments, emite erro e não continua
      emit(
        ShoppingError(
          'Erro ao cancelar parcelas pendentes: $e. Tente novamente.',
        ),
      );
      return;
    }

    // Depois deleta o item
    final result = await _deleteShoppingItemUseCase(
      DeleteShoppingItemParams(projectId: projectId, itemId: itemId),
    );

    await result.fold((failure) async => emit(ShoppingError(failure.message)), (
      _,
    ) async {
      emit(ShoppingOperationSuccess('Item removido com sucesso'));
      await loadShoppingItems(projectId);
    });
  }
}

// Made with Bob
