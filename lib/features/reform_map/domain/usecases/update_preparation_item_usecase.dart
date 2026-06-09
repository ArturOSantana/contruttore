import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/reform_map_repository.dart';

/// Use case para atualizar item de preparação da próxima etapa
///
/// Marca um item do checklist de preparação como concluído ou pendente,
/// atualizando automaticamente o progresso geral da preparação.
@lazySingleton
class UpdatePreparationItemUseCase
    implements UseCase<void, UpdatePreparationItemParams> {
  final ReformMapRepository repository;

  UpdatePreparationItemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(
    UpdatePreparationItemParams params,
  ) async {
    return await repository.updatePreparationItem(
      params.projectId,
      params.stepId,
      params.itemId,
      params.isDone,
    );
  }
}

/// Parâmetros para atualizar item de preparação
class UpdatePreparationItemParams {
  final String projectId;
  final String stepId;
  final String itemId;
  final bool isDone;

  const UpdatePreparationItemParams({
    required this.projectId,
    required this.stepId,
    required this.itemId,
    required this.isDone,
  });
}

// Made with Bob
