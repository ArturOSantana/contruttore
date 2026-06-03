import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/project_entity.dart';
import '../repositories/project_repository.dart';

@injectable
class CreateProjectUseCase {
  final ProjectRepository _repository;

  CreateProjectUseCase(this._repository);

  Future<Either<Failure, ProjectEntity>> call(ProjectEntity project) async {
    return await _repository.createProject(project);
  }
}

// Made with Bob
