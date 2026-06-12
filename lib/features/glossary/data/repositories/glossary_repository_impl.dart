import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/glossary_term_entity.dart';
import '../../domain/repositories/glossary_repository.dart';
import '../models/glossary_term_model.dart';
import '../seed/glossary_seed_data.dart';

/// Implementação do repositório de glossário
@LazySingleton(as: GlossaryRepository)
class GlossaryRepositoryImpl implements GlossaryRepository {
  final FirebaseFirestore firestore;
  static const String _glossaryCollection = 'glossary';
  static const String _favoritesBoxName = 'glossary_favorites';

  GlossaryRepositoryImpl(this.firestore);

  @override
  Future<Either<Failure, List<GlossaryTermEntity>>> getAllTerms() async {
    try {
      final snapshot =
          await firestore.collection(_glossaryCollection).orderBy('term').get();

      // Se não houver dados no Firestore, usa dados locais de seed
      if (snapshot.docs.isEmpty) {
        final localTerms = glossarySeedData
            .map((data) => GlossaryTermModel.fromMap(data))
            .toList();
        return Right(localTerms);
      }

      final terms = snapshot.docs
          .map((doc) => GlossaryTermModel.fromFirestore(doc))
          .toList();

      return Right(terms);
    } on FirebaseException catch (e) {
      // Em caso de erro do Firebase, tenta usar dados locais
      try {
        final localTerms = glossarySeedData
            .map((data) => GlossaryTermModel.fromMap(data))
            .toList();
        return Right(localTerms);
      } catch (localError) {
        return Left(ServerFailure('Erro ao buscar termos: ${e.message}'));
      }
    } catch (e) {
      // Em caso de erro genérico, tenta usar dados locais
      try {
        final localTerms = glossarySeedData
            .map((data) => GlossaryTermModel.fromMap(data))
            .toList();
        return Right(localTerms);
      } catch (localError) {
        return Left(ServerFailure('Erro inesperado: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, GlossaryTermEntity>> getTermById(String termId) async {
    try {
      final doc =
          await firestore.collection(_glossaryCollection).doc(termId).get();

      if (!doc.exists) {
        return Left(NotFoundFailure('Termo não encontrado'));
      }

      final term = GlossaryTermModel.fromFirestore(doc);
      return Right(term);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao buscar termo: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<GlossaryTermEntity>>> getTermsByCategory(
    String category,
  ) async {
    try {
      final snapshot = await firestore
          .collection(_glossaryCollection)
          .where('category', isEqualTo: category)
          .orderBy('term')
          .get();

      final terms = snapshot.docs
          .map((doc) => GlossaryTermModel.fromFirestore(doc))
          .toList();

      return Right(terms);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao buscar termos: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<GlossaryTermEntity>>> searchTerms(
    String query,
  ) async {
    try {
      // Busca todos os termos e filtra localmente
      // Firestore não suporta busca full-text nativa
      final allTermsResult = await getAllTerms();

      return allTermsResult.fold((failure) => Left(failure), (terms) {
        final filteredTerms =
            terms.where((term) => term.matchesSearch(query)).toList();
        return Right(filteredTerms);
      });
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar termos: $e'));
    }
  }

  @override
  Future<Either<Failure, List<GlossaryTermEntity>>> getTermsByPhase(
    int phaseNumber,
  ) async {
    try {
      final snapshot = await firestore
          .collection(_glossaryCollection)
          .where('relatedPhase', isEqualTo: phaseNumber)
          .orderBy('term')
          .get();

      final terms = snapshot.docs
          .map((doc) => GlossaryTermModel.fromFirestore(doc))
          .toList();

      return Right(terms);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao buscar termos: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorites(String termId) async {
    try {
      final box = await Hive.openBox<String>(_favoritesBoxName);
      final favorites = box.values.toList();

      if (!favorites.contains(termId)) {
        await box.add(termId);
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao adicionar favorito: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(String termId) async {
    try {
      final box = await Hive.openBox<String>(_favoritesBoxName);
      final favorites = box.values.toList();
      final index = favorites.indexOf(termId);

      if (index != -1) {
        await box.deleteAt(index);
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao remover favorito: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getFavoriteTermIds() async {
    try {
      final box = await Hive.openBox<String>(_favoritesBoxName);
      final favorites = box.values.toList();
      return Right(favorites);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar favoritos: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String termId) async {
    try {
      final box = await Hive.openBox<String>(_favoritesBoxName);
      final favorites = box.values.toList();
      return Right(favorites.contains(termId));
    } catch (e) {
      return Left(CacheFailure('Erro ao verificar favorito: $e'));
    }
  }
}

// Made with Bob
