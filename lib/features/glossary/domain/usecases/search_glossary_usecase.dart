import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/glossary_term_entity.dart';
import '../repositories/glossary_repository.dart';

/// Use case para buscar termos do glossário por query
@injectable
class SearchGlossaryUseCase
    implements UseCase<List<GlossaryTermEntity>, SearchGlossaryParams> {
  final GlossaryRepository repository;

  SearchGlossaryUseCase(this.repository);

  @override
  Future<Either<Failure, List<GlossaryTermEntity>>> call(
    SearchGlossaryParams params,
  ) async {
    return await repository.searchTerms(params.query);
  }
}

class SearchGlossaryParams extends Equatable {
  final String query;

  const SearchGlossaryParams({required this.query});

  @override
  List<Object?> get props => [query];
}

// Made with Bob
