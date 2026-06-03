import 'package:equatable/equatable.dart';

/// Classe base abstrata para todos os tipos de falhas
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Falha relacionada ao servidor/backend
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Falha relacionada à autenticação
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Falha relacionada à conexão de rede
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Falha relacionada ao cache local
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Falha de validação de dados
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Falha quando um recurso não é encontrado
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

// Made with Bob
