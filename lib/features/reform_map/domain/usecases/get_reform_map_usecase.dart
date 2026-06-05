import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reform_map_entity.dart';
import '../repositories/reform_map_repository.dart';

/// Use case para buscar o mapa completo da reforma
@injectable
class GetReformMapUseCase implements UseCase<ReformMapEntity, String> {
  final ReformMapRepository repository;

  GetReformMapUseCase(this.repository);

  @override
  Future<Either<Failure, ReformMapEntity>> call(String projectId) async {
    return await repository.getReformMap(projectId);
  }
}

// Made with Bob
