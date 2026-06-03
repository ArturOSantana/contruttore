import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Realiza login com email e senha
  Future<Either<Failure, UserEntity>> login(String email, String password);

  /// Registra um novo usuário
  Future<Either<Failure, UserEntity>> register(
    String name,
    String email,
    String password,
  );

  /// Realiza logout do usuário atual
  Future<Either<Failure, void>> logout();

  /// Envia email de recuperação de senha
  Future<Either<Failure, void>> forgotPassword(String email);

  /// Obtém o usuário atualmente autenticado
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Stream que emite mudanças no estado de autenticação
  Stream<UserEntity?> get authStateChanges;

  /// Salva o FCM token do usuário no Firestore
  Future<Either<Failure, void>> saveFcmToken(String userId, String token);

  /// Troca o projeto ativo do usuário
  Future<Either<Failure, void>> switchProject(String userId, String projectId);

  /// Atualiza o perfil do usuário (nome e email)
  Future<Either<Failure, UserEntity>> updateProfile(
    String userId,
    String name,
    String email,
  );

  /// Altera a senha do usuário
  Future<Either<Failure, void>> changePassword(
    String currentPassword,
    String newPassword,
  );
}

// Made with Bob
