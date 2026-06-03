import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Interface base para todos os use cases
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Classe para use cases que não precisam de parâmetros
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

// Made with Bob
