import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

@injectable
class SwitchProjectUseCase {
  final AuthRepository _repository;

  SwitchProjectUseCase(this._repository);

  Future<Either<Failure, void>> call(String userId, String projectId) async {
    return await _repository.switchProject(userId, projectId);
  }
}

// Made with Bob
