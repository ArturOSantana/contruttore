import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../models/wishlist_item_model.dart';

@LazySingleton(as: WishlistRepository)
class WishlistRepositoryImpl implements WishlistRepository {
  final FirebaseFirestore _firestore;

  WishlistRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, List<WishlistItemEntity>>> getWishlistItems(
    String projectId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('wishlist')
          .orderBy('isSelected', descending: true)
          .orderBy('createdAt', descending: true)
          .get();

      final items = snapshot.docs
          .map((doc) => WishlistItemModel.fromMap(doc.data(), doc.id))
          .toList();

      return Right(items);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar itens: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addWishlistItem(WishlistItemEntity item) async {
    try {
      await _firestore
          .collection('projects')
          .doc(item.projectId)
          .collection('wishlist')
          .doc(item.id)
          .set((item as WishlistItemModel).toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao adicionar item: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateWishlistItem(
    WishlistItemEntity item,
  ) async {
    try {
      await _firestore
          .collection('projects')
          .doc(item.projectId)
          .collection('wishlist')
          .doc(item.id)
          .update((item as WishlistItemModel).toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar item: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWishlistItem(
    String projectId,
    String itemId,
  ) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('wishlist')
          .doc(itemId)
          .delete();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao deletar item: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleSelected(
    String projectId,
    String itemId,
    bool isSelected,
  ) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('wishlist')
          .doc(itemId)
          .update({'isSelected': isSelected});

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar seleção: $e'));
    }
  }
}

// Made with Bob
