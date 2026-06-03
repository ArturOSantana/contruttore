import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/glossary_term_entity.dart';

/// Repositório para operações com o glossário
abstract class GlossaryRepository {
  /// Busca todos os termos do glossário
  Future<Either<Failure, List<GlossaryTermEntity>>> getAllTerms();

  /// Busca um termo específico por ID
  Future<Either<Failure, GlossaryTermEntity>> getTermById(String termId);

  /// Busca termos por categoria
  Future<Either<Failure, List<GlossaryTermEntity>>> getTermsByCategory(
    String category,
  );

  /// Busca termos que correspondem à query
  Future<Either<Failure, List<GlossaryTermEntity>>> searchTerms(String query);

  /// Busca termos relacionados a uma fase específica
  Future<Either<Failure, List<GlossaryTermEntity>>> getTermsByPhase(
    int phaseNumber,
  );

  /// Adiciona um termo aos favoritos (local)
  Future<Either<Failure, void>> addToFavorites(String termId);

  /// Remove um termo dos favoritos (local)
  Future<Either<Failure, void>> removeFromFavorites(String termId);

  /// Busca IDs dos termos favoritos (local)
  Future<Either<Failure, List<String>>> getFavoriteTermIds();

  /// Verifica se um termo está nos favoritos
  Future<Either<Failure, bool>> isFavorite(String termId);
}

// Made with Bob
