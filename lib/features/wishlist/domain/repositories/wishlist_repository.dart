import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wishlist_item_entity.dart';

abstract class WishlistRepository {
  Future<Either<Failure, List<WishlistItemEntity>>> getWishlistItems(
    String projectId,
  );
  Future<Either<Failure, void>> addWishlistItem(WishlistItemEntity item);
  Future<Either<Failure, void>> updateWishlistItem(WishlistItemEntity item);
  Future<Either<Failure, void>> deleteWishlistItem(
    String projectId,
    String itemId,
  );
  Future<Either<Failure, void>> toggleSelected(
    String projectId,
    String itemId,
    bool isSelected,
  );
}

// Made with Bob
