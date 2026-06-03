import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project_entity.dart';
import '../repositories/project_repository.dart';

@injectable
class UpdateProjectUseCase implements UseCase<void, ProjectEntity> {
  final ProjectRepository _repository;

  UpdateProjectUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ProjectEntity params) async {
    return await _repository.updateProject(params);
  }
}

// Made with Bob
