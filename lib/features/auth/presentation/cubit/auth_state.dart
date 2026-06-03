import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// Estados possíveis da autenticação
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial - ainda não verificou autenticação
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado de carregamento - processando operação de autenticação
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Estado autenticado - usuário logado com sucesso
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Estado não autenticado - usuário não está logado
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Estado de erro - ocorreu um erro durante autenticação
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado de sucesso em operação (ex: email de recuperação enviado)
class AuthSuccess extends AuthState {
  final String message;

  const AuthSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Made with Bob
