import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/shopping_item_entity.dart';

abstract class ShoppingRepository {
  Future<Either<Failure, List<ShoppingItemEntity>>> getShoppingItems(
    String projectId,
  );
  Future<Either<Failure, void>> addShoppingItem(ShoppingItemEntity item);
  Future<Either<Failure, void>> updateShoppingItem(ShoppingItemEntity item);
  Future<Either<Failure, void>> deleteShoppingItem(
    String projectId,
    String itemId,
  );
  Future<Either<Failure, void>> markAsPurchased({
    required String projectId,
    required String itemId,
    required double actualPrice,
    required String store,
    required DateTime purchaseDate,
  });
}

// Made with Bob
