import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/wishlist_item_entity.dart';
import '../repositories/wishlist_repository.dart';

@injectable
class AddWishlistItemUseCase {
  final WishlistRepository _repository;

  AddWishlistItemUseCase(this._repository);

  Future<Either<Failure, void>> call(WishlistItemEntity item) {
    return _repository.addWishlistItem(item);
  }
}

// Made with Bob
