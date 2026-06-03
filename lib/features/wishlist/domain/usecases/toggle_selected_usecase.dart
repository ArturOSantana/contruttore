import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/wishlist_repository.dart';

@injectable
class ToggleSelectedUseCase {
  final WishlistRepository _repository;

  ToggleSelectedUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required String itemId,
    required bool isSelected,
  }) {
    return _repository.toggleSelected(projectId, itemId, isSelected);
  }
}

// Made with Bob
