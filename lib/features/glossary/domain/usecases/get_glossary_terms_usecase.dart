import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/glossary_term_entity.dart';
import '../repositories/glossary_repository.dart';

/// Use case para buscar todos os termos do glossário
@injectable
class GetGlossaryTermsUseCase
    implements UseCase<List<GlossaryTermEntity>, NoParams> {
  final GlossaryRepository repository;

  GetGlossaryTermsUseCase(this.repository);

  @override
  Future<Either<Failure, List<GlossaryTermEntity>>> call(
    NoParams params,
  ) async {
    return await repository.getAllTerms();
  }
}

// Made with Bob
