import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/project_entity.dart';
import '../repositories/project_repository.dart';

@injectable
class UpdateProjectUseCase {
  final ProjectRepository repository;

  UpdateProjectUseCase(this.repository);

  Future<Either<Failure, void>> call(ProjectEntity project) async {
    return await repository.updateProject(project);
  }
}

// Made with Bob
