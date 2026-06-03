import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/shopping_repository.dart';

@injectable
class DeleteShoppingItemUseCase
    implements UseCase<void, DeleteShoppingItemParams> {
  final ShoppingRepository repository;

  DeleteShoppingItemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteShoppingItemParams params) async {
    return await repository.deleteShoppingItem(params.projectId, params.itemId);
  }
}

class DeleteShoppingItemParams {
  final String projectId;
  final String itemId;

  DeleteShoppingItemParams({required this.projectId, required this.itemId});
}
