import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/project_entity.dart';

abstract class ProjectRepository {
  Future<Either<Failure, ProjectEntity>> createProject(ProjectEntity project);
  Future<Either<Failure, List<ProjectEntity>>> getProjects(String userId);
  Future<Either<Failure, ProjectEntity>> getProject(String projectId);
  Future<Either<Failure, void>> updateProject(ProjectEntity project);
  Future<Either<Failure, void>> deleteProject(String projectId);
}

// Made with Bob
