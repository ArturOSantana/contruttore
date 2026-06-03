import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/shopping_item_entity.dart';
import '../repositories/shopping_repository.dart';

@injectable
class AddShoppingItemUseCase {
  final ShoppingRepository _repository;

  AddShoppingItemUseCase(this._repository);

  Future<Either<Failure, void>> call(ShoppingItemEntity item) {
    return _repository.addShoppingItem(item);
  }
}

// Made with Bob
