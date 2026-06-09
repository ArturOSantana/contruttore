import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Use case para adicionar transação manual (despesa ou receita)
///
/// Cria uma transaction com:
/// - type: expense (gasto confirmado)
/// - source: manual (criado pelo usuário)
/// - status: active
@lazySingleton
class AddManualTransactionUseCase {
  final TransactionRepository _repository;
  final Uuid _uuid;

  AddManualTransactionUseCase(
    this._repository,
    this._uuid,
  );

  /// Adiciona uma transação manual
  ///
  /// Parâmetros:
  /// - projectId: ID do projeto
  /// - description: Descrição da transação
  /// - amount: Valor (sempre positivo)
  /// - date: Data da transação
  /// - phaseId: ID da fase (opcional)
  /// - categoryId: ID da categoria (opcional)
  /// - supplierId: ID do fornecedor (opcional)
  /// - invoicePhotoUrl: URL da foto da nota fiscal (opcional)
  /// - notes: Observações (opcional)
  Future<Either<Failure, void>> call({
    required String projectId,
    required String description,
    required double amount,
    required DateTime date,
    String? phaseId,
    String? categoryId,
    String? supplierId,
    String? invoicePhotoUrl,
    String? notes,
  }) async {
    // Validações
    if (description.trim().isEmpty) {
      return Left(ValidationFailure('Descrição não pode estar vazia'));
    }

    if (amount <= 0) {
      return Left(ValidationFailure('Valor deve ser maior que zero'));
    }

    // Cria a transaction
    final transaction = TransactionEntity(
      id: _uuid.v4(),
      projectId: projectId,
      type: TransactionType.expense,
      source: TransactionSource.manual,
      amount: amount,
      signedAmount: amount, // Positivo para despesa
      date: date,
      description: description,
      phaseId: phaseId,
      categoryId: categoryId,
      supplierId: supplierId,
      invoicePhotoUrl: invoicePhotoUrl,
      notes: notes,
      status: TransactionStatus.active,
      createdAt: DateTime.now(),
    );

    return _repository.createManualTransaction(transaction);
  }
}

// Made with Bob
