import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/shopping_item_entity.dart';
import '../repositories/shopping_repository.dart';

@injectable
class GetShoppingItemsUseCase {
  final ShoppingRepository _repository;

  GetShoppingItemsUseCase(this._repository);

  Future<Either<Failure, List<ShoppingItemEntity>>> call(String projectId) {
    return _repository.getShoppingItems(projectId);
  }
}

// Made with Bob
