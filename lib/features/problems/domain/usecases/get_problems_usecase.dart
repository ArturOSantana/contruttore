import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../reform_map/domain/entities/problem_entity.dart';
import '../repositories/problem_repository.dart';

@injectable
class GetProblemsUseCase {
  final ProblemRepository repository;

  GetProblemsUseCase(this.repository);

  Future<Either<Failure, List<ProblemEntity>>> call(String projectId) {
    return repository.getProblems(projectId);
  }
}

// Made with Bob
