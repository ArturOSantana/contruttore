import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../diary/domain/usecases/add_automatic_entry_usecase.dart';
import '../../../diary/domain/entities/diary_entry_entity.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../../domain/usecases/get_wishlist_items_usecase.dart';
import '../../domain/usecases/add_wishlist_item_usecase.dart';
import '../../domain/usecases/toggle_selected_usecase.dart';
import '../../domain/usecases/move_to_shopping_usecase.dart';
import '../../domain/usecases/delete_wishlist_item_usecase.dart';
import 'wishlist_state.dart';

@injectable
class WishlistCubit extends Cubit<WishlistState> {
  final GetWishlistItemsUseCase _getWishlistItemsUseCase;
  final AddWishlistItemUseCase _addWishlistItemUseCase;
  final ToggleSelectedUseCase _toggleSelectedUseCase;
  final MoveToShoppingUseCase _moveToShoppingUseCase;
  final DeleteWishlistItemUseCase _deleteWishlistItemUseCase;
  final AddAutomaticEntryUseCase _addAutomaticEntryUseCase;

  WishlistCubit(
    this._getWishlistItemsUseCase,
    this._addWishlistItemUseCase,
    this._toggleSelectedUseCase,
    this._moveToShoppingUseCase,
    this._deleteWishlistItemUseCase,
    this._addAutomaticEntryUseCase,
  ) : super(WishlistInitial());

  Future<void> loadWishlistItems(String projectId) async {
    emit(WishlistLoading());

    final result = await _getWishlistItemsUseCase(projectId);

    result.fold((failure) => emit(WishlistError(failure.message)), (items) {
      final selectedCount = items.where((item) => item.isSelected).length;
      emit(
        WishlistLoaded(
          items: items,
          selectedCount: selectedCount,
          totalCount: items.length,
        ),
      );
    });
  }

  Future<void> addWishlistItem(WishlistItemEntity item) async {
    final result = await _addWishlistItemUseCase(item);

    result.fold((failure) => emit(WishlistError(failure.message)), (_) {
      emit(WishlistOperationSuccess('Item adicionado com sucesso'));
      loadWishlistItems(item.projectId);
    });
  }

  // Alias para compatibilidade com forms
  Future<void> addItem(WishlistItemEntity item) async {
    await addWishlistItem(item);
  }

  // Método para atualizar item
  Future<void> updateItem(WishlistItemEntity item) async {
    await addWishlistItem(item); // Reutiliza o mesmo método
  }

  Future<void> toggleSelected({
    required String projectId,
    required String itemId,
    required bool isSelected,
    required WishlistItemEntity item,
  }) async {
    // Primeiro atualiza o status de selecionado
    final toggleResult = await _toggleSelectedUseCase(
      projectId: projectId,
      itemId: itemId,
      isSelected: isSelected,
    );

    await toggleResult.fold(
      (failure) async => emit(WishlistError(failure.message)),
      (_) async {
        // Se marcou como selecionado, move para lista de compras
        if (isSelected) {
          final moveResult = await _moveToShoppingUseCase(item);

          await moveResult.fold(
            (failure) async => emit(
              WishlistError(
                'Item selecionado mas não foi possível adicionar à lista de compras: ${failure.message}',
              ),
            ),
            (_) async {
              // INTEGRAÇÃO: Adiciona log automático no diário
              await _addAutomaticEntryUseCase(
                projectId: projectId,
                title: 'Item movido para compras',
                description: '${item.name} - ${item.category}',
                phaseId: item.phaseId,
                type: DiaryEntryType.daily,
              );

              emit(
                WishlistOperationSuccess(
                  'Item selecionado e adicionado à lista de compras',
                ),
              );
            },
          );
        } else {
          emit(WishlistOperationSuccess('Item desmarcado'));
        }

        await loadWishlistItems(projectId);
      },
    );
  }

  Future<void> deleteWishlistItem(String projectId, String itemId) async {
    final result = await _deleteWishlistItemUseCase(
      DeleteWishlistItemParams(projectId: projectId, itemId: itemId),
    );

    result.fold(
      (failure) => emit(WishlistError(failure.message)),
      (_) => loadWishlistItems(projectId),
    );
  }
}

// Made with Bob
