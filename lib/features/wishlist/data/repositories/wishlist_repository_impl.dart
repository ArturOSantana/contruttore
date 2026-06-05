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
      // Query simples sem orderBy para funcionar enquanto índice está sendo construído
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('wishlist')
          .get();

      final items = snapshot.docs
          .map((doc) => WishlistItemModel.fromMap(doc.data(), doc.id))
          .toList();

      // Ordenação em memória: selecionados primeiro, depois por data
      items.sort((a, b) {
        // Primeiro ordena por isSelected (true primeiro)
        if (a.isSelected != b.isSelected) {
          return a.isSelected ? -1 : 1;
        }
        // Depois ordena por data (mais recente primeiro)
        return b.createdAt.compareTo(a.createdAt);
      });

      return Right(items);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar itens: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addWishlistItem(WishlistItemEntity item) async {
    try {
      // Converter Entity para Model
      final model = WishlistItemModel(
        id: item.id,
        projectId: item.projectId,
        name: item.name,
        url: item.url,
        imageUrl: item.imageUrl,
        storeName: item.storeName,
        price: item.price,
        notes: item.notes,
        category: item.category,
        phaseId: item.phaseId,
        isSelected: item.isSelected,
        createdAt: item.createdAt,
      );

      await _firestore
          .collection('projects')
          .doc(item.projectId)
          .collection('wishlist')
          .doc(item.id)
          .set(model.toMap());

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
      // Converter Entity para Model
      final model = WishlistItemModel(
        id: item.id,
        projectId: item.projectId,
        name: item.name,
        url: item.url,
        imageUrl: item.imageUrl,
        storeName: item.storeName,
        price: item.price,
        notes: item.notes,
        category: item.category,
        phaseId: item.phaseId,
        isSelected: item.isSelected,
        createdAt: item.createdAt,
      );

      await _firestore
          .collection('projects')
          .doc(item.projectId)
          .collection('wishlist')
          .doc(item.id)
          .update(model.toMap());

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
