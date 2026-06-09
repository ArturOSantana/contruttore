import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Use case para buscar todas as transações de um projeto
///
/// Retorna lista ordenada por data (mais recente primeiro)
@lazySingleton
class GetTransactionsUseCase {
  final TransactionRepository _repository;

  GetTransactionsUseCase(this._repository);

  Future<Either<Failure, List<TransactionEntity>>> call(String projectId) {
    return _repository.getTransactions(projectId);
  }
}

// Made with Bob
