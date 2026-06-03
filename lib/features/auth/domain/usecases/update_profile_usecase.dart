import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case para atualizar perfil do usuário
@injectable
class UpdateProfileUseCase {
  final AuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call({
    required String userId,
    required String name,
    required String email,
  }) async {
    return await _repository.updateProfile(userId, name, email);
  }
}

// Made with Bob
