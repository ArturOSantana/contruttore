import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/project_entity.dart';
import '../repositories/project_repository.dart';

@injectable
class GetProjectsUseCase {
  final ProjectRepository _repository;

  GetProjectsUseCase(this._repository);

  Future<Either<Failure, List<ProjectEntity>>> call(String userId) async {
    return await _repository.getProjects(userId);
  }
}

// Made with Bob
