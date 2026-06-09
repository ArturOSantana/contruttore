import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/next_step_preparation_entity.dart';
import '../repositories/reform_map_repository.dart';

/// Use case para buscar preparação da próxima etapa
///
/// Retorna o checklist de preparação para a próxima fase da reforma,
/// incluindo itens obrigatórios e opcionais que devem ser completados
/// antes de iniciar a próxima etapa.
@lazySingleton
class GetNextStepPreparationUseCase
    implements
        UseCase<NextStepPreparationEntity?, GetNextStepPreparationParams> {
  final ReformMapRepository repository;

  GetNextStepPreparationUseCase(this.repository);

  @override
  Future<Either<Failure, NextStepPreparationEntity?>> call(
    GetNextStepPreparationParams params,
  ) async {
    return await repository.getNextStepPreparation(params.projectId);
  }
}

/// Parâmetros para buscar preparação da próxima etapa
class GetNextStepPreparationParams {
  final String projectId;

  const GetNextStepPreparationParams({
    required this.projectId,
  });
}

// Made with Bob
