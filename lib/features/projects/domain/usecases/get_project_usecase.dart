import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project_entity.dart';
import '../repositories/project_repository.dart';

/// Use case para buscar um projeto pelo ID
@injectable
class GetProjectUsecase implements UseCase<ProjectEntity?, String> {
  final ProjectRepository repository;

  GetProjectUsecase(this.repository);

  @override
  Future<Either<Failure, ProjectEntity?>> call(String projectId) async {
    return await repository.getProject(projectId);
  }
}

// Made with Bob
