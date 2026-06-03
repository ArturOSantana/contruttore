import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/wishlist_repository.dart';

@injectable
class DeleteWishlistItemUseCase
    implements UseCase<void, DeleteWishlistItemParams> {
  final WishlistRepository repository;

  DeleteWishlistItemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteWishlistItemParams params) async {
    return await repository.deleteWishlistItem(params.projectId, params.itemId);
  }
}

class DeleteWishlistItemParams {
  final String projectId;
  final String itemId;

  DeleteWishlistItemParams({required this.projectId, required this.itemId});
}
