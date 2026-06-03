import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/shopping_item_entity.dart';
import '../../domain/repositories/shopping_repository.dart';
import '../models/shopping_item_model.dart';

@LazySingleton(as: ShoppingRepository)
class ShoppingRepositoryImpl implements ShoppingRepository {
  final FirebaseFirestore _firestore;

  ShoppingRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, List<ShoppingItemEntity>>> getShoppingItems(
    String projectId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('shopping')
          .orderBy('createdAt', descending: true)
          .get();

      final items = snapshot.docs
          .map((doc) => ShoppingItemModel.fromMap(doc.data(), doc.id))
          .toList();

      return Right(items);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar itens: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addShoppingItem(ShoppingItemEntity item) async {
    try {
      // Converte Entity para Model antes de salvar
      final model = item is ShoppingItemModel
          ? item
          : ShoppingItemModel.fromEntity(item);

      await _firestore
          .collection('projects')
          .doc(item.projectId)
          .collection('shopping')
          .doc(item.id)
          .set(model.toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao adicionar item: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateShoppingItem(
    ShoppingItemEntity item,
  ) async {
    try {
      // Converte Entity para Model antes de atualizar
      final model = item is ShoppingItemModel
          ? item
          : ShoppingItemModel.fromEntity(item);

      await _firestore
          .collection('projects')
          .doc(item.projectId)
          .collection('shopping')
          .doc(item.id)
          .update(model.toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar item: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteShoppingItem(
    String projectId,
    String itemId,
  ) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('shopping')
          .doc(itemId)
          .delete();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao deletar item: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsPurchased({
    required String projectId,
    required String itemId,
    required double actualPrice,
    required String store,
    required DateTime purchaseDate,
  }) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('shopping')
          .doc(itemId)
          .update({
            'isPurchased': true,
            'actualPrice': actualPrice,
            'store': store,
            'purchaseDate': Timestamp.fromDate(purchaseDate),
          });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao marcar como comprado: $e'));
    }
  }
}

// Made with Bob
