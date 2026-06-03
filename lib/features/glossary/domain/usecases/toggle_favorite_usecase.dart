import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/glossary_repository.dart';

/// Use case para adicionar/remover termo dos favoritos
@injectable
class ToggleFavoriteUseCase implements UseCase<void, ToggleFavoriteParams> {
  final GlossaryRepository repository;

  ToggleFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleFavoriteParams params) async {
    final isFavoriteResult = await repository.isFavorite(params.termId);

    return isFavoriteResult.fold((failure) => Left(failure), (
      isFavorite,
    ) async {
      if (isFavorite) {
        return await repository.removeFromFavorites(params.termId);
      } else {
        return await repository.addToFavorites(params.termId);
      }
    });
  }
}

class ToggleFavoriteParams extends Equatable {
  final String termId;

  const ToggleFavoriteParams({required this.termId});

  @override
  List<Object?> get props => [termId];
}

// Made with Bob
