import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../shopping/domain/entities/shopping_item_entity.dart';
import '../../../shopping/domain/repositories/shopping_repository.dart';
import '../entities/wishlist_item_entity.dart';

@injectable
class MoveToShoppingUseCase {
  final ShoppingRepository _shoppingRepository;
  final Uuid _uuid;

  MoveToShoppingUseCase(this._shoppingRepository, this._uuid);

  Future<Either<Failure, void>> call(
    WishlistItemEntity wishlistItem, {
    int installments = 1,
    DateTime? firstPaymentDate,
  }) async {
    // Mapear categoria da wishlist para categoria do shopping
    final shoppingCategory = _mapCategory(wishlistItem.category);

    final shoppingItem = ShoppingItemEntity(
      id: _uuid.v4(),
      projectId: wishlistItem.projectId,
      phaseId: wishlistItem.phaseId,
      name: wishlistItem.name,
      category: shoppingCategory,
      estimatedPrice: wishlistItem.price,
      quantity: 1,
      unit: 'un',
      isPurchased: false,
      notes: 'Da lista de desejos: ${wishlistItem.url}',
      wishlistItemId: wishlistItem.id,
      createdAt: DateTime.now(),
      installments: installments,
      firstPaymentDate: firstPaymentDate,
    );

    return await _shoppingRepository.addShoppingItem(shoppingItem);
  }

  ShoppingCategory _mapCategory(WishlistCategory category) {
    switch (category) {
      case WishlistCategory.flooring:
        return ShoppingCategory.flooring;
      case WishlistCategory.furniture:
        return ShoppingCategory.furniture;
      case WishlistCategory.lighting:
        return ShoppingCategory.decoration;
      case WishlistCategory.fixtures:
        return ShoppingCategory.fixtures;
      case WishlistCategory.appliances:
        return ShoppingCategory.other;
      case WishlistCategory.decoration:
        return ShoppingCategory.decoration;
      case WishlistCategory.textiles:
        return ShoppingCategory.decoration;
      case WishlistCategory.carpentry:
        return ShoppingCategory.carpentry;
      case WishlistCategory.other:
        return ShoppingCategory.other;
    }
  }
}

// Made with Bob
