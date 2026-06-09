import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/transaction_repository.dart';

/// Use case para atualizar uma transação
///
/// IMPORTANTE: Apenas transações manuais podem ser editadas
/// Transações de shopping, installments e contracts não podem ser editadas
@lazySingleton
class UpdateTransactionUseCase {
  final TransactionRepository _repository;

  UpdateTransactionUseCase(this._repository);

  /// Atualiza uma transação manual
  ///
  /// Parâmetros que podem ser atualizados:
  /// - description: Nova descrição
  /// - amount: Novo valor
  /// - date: Nova data
  /// - phaseId: Nova fase
  /// - categoryId: Nova categoria
  /// - supplierId: Novo fornecedor
  /// - invoicePhotoUrl: Nova foto da nota
  /// - notes: Novas observações
  Future<Either<Failure, void>> call({
    required String projectId,
    required String transactionId,
    String? description,
    double? amount,
    DateTime? date,
    String? phaseId,
    String? categoryId,
    String? supplierId,
    String? invoicePhotoUrl,
    String? notes,
  }) async {
    // Validações
    if (amount != null && amount <= 0) {
      return Left(ValidationFailure('Valor deve ser maior que zero'));
    }

    if (description != null && description.trim().isEmpty) {
      return Left(ValidationFailure('Descrição não pode estar vazia'));
    }

    // Monta o mapa de updates
    final Map<String, dynamic> updates = {};

    if (description != null) updates['description'] = description;
    if (amount != null) {
      updates['amount'] = amount;
      updates['signedAmount'] = amount;
    }
    if (date != null) updates['date'] = date.toIso8601String();
    if (phaseId != null) updates['phaseId'] = phaseId;
    if (categoryId != null) updates['categoryId'] = categoryId;
    if (supplierId != null) updates['supplierId'] = supplierId;
    if (invoicePhotoUrl != null) updates['invoicePhotoUrl'] = invoicePhotoUrl;
    if (notes != null) updates['notes'] = notes;

    if (updates.isEmpty) {
      return Left(ValidationFailure('Nenhum campo para atualizar'));
    }

    return _repository.updateTransaction(projectId, transactionId, updates);
  }
}

// Made with Bob
