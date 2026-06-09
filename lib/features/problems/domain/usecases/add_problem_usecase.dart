import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../reform_map/domain/entities/problem_entity.dart';
import '../repositories/problem_repository.dart';

@injectable
class AddProblemUseCase {
  final ProblemRepository repository;

  AddProblemUseCase(this.repository);

  Future<Either<Failure, void>> call(ProblemEntity problem) {
    return repository.addProblem(problem);
  }
}

// Made with Bob
