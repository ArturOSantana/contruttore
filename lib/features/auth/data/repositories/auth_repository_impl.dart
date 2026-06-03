import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._auth, this._firestore);

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    try {
      // Realiza login no Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Left(AuthFailure('Erro ao fazer login'));
      }

      // Busca dados do usuário no Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        return const Left(
          AuthFailure('Usuário não encontrado no banco de dados'),
        );
      }

      final userModel = UserModel.fromMap(userDoc.data()!);
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      // Cria usuário no Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Left(AuthFailure('Erro ao criar conta'));
      }

      // Atualiza displayName no Firebase Auth
      await credential.user!.updateDisplayName(name);

      // Cria modelo do usuário
      final userModel = UserModel.fromFirebaseUser(
        credential.user!,
        name: name,
      );

      // Salva dados do usuário no Firestore
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toMap());

      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Erro ao fazer logout: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;

      if (currentUser == null) {
        return const Right(null);
      }

      // Busca dados do usuário no Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        return const Right(null);
      }

      final userModel = UserModel.fromMap(userDoc.data()!);
      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar usuário: ${e.toString()}'));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }

      try {
        // Busca dados do usuário no Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (!userDoc.exists) {
          return null;
        }

        return UserModel.fromMap(userDoc.data()!);
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<Either<Failure, void>> saveFcmToken(
    String userId,
    String token,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao salvar FCM token: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> switchProject(
    String userId,
    String projectId,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'currentProjectId': projectId,
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao trocar projeto: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(
    String userId,
    String name,
    String email,
  ) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Left(ServerFailure('Usuário não autenticado'));
      }

      // Atualizar email no Firebase Auth se mudou
      if (currentUser.email != email) {
        await currentUser.verifyBeforeUpdateEmail(email);
      }

      // Atualizar nome no Firebase Auth
      await currentUser.updateDisplayName(name);

      // Atualizar dados no Firestore
      await _firestore.collection('users').doc(userId).update({
        'name': name,
        'email': email,
      });

      // Buscar usuário atualizado
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        return Left(ServerFailure('Usuário não encontrado'));
      }

      final user = UserModel.fromMap(doc.data()!);
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar perfil: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Left(ServerFailure('Usuário não autenticado'));
      }

      // Reautenticar usuário com senha atual
      final credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: currentPassword,
      );

      await currentUser.reauthenticateWithCredential(credential);

      // Atualizar senha
      await currentUser.updatePassword(newPassword);

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return Left(ServerFailure('Erro ao alterar senha: ${e.toString()}'));
    }
  }

  /// Converte códigos de erro do Firebase Auth em mensagens amigáveis
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'Este email já está em uso';
      case 'invalid-email':
        return 'Email inválido';
      case 'weak-password':
        return 'Senha muito fraca. Use pelo menos 6 caracteres';
      case 'user-disabled':
        return 'Esta conta foi desativada';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde';
      case 'operation-not-allowed':
        return 'Operação não permitida';
      case 'invalid-credential':
        return 'Credenciais inválidas';
      default:
        return 'Erro ao autenticar: $code';
    }
  }
}

// Made with Bob
