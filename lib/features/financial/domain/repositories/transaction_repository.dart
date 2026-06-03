import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction_entity.dart';

/// Repository abstrato para transações financeiras
///
/// REGRA CRÍTICA: Toda operação que cria múltiplos documentos
/// DEVE usar WriteBatch para garantir atomicidade
abstract class TransactionRepository {
  /// Busca todas as transações de um projeto
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
    String projectId,
  );

  /// Busca transações por tipo
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByType(
    String projectId,
    TransactionType type,
  );

  /// Busca transações por origem
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsBySource(
    String projectId,
    TransactionSource source,
  );

  /// Busca transações de uma parcela específica
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByInstallment(
    String projectId,
    String installmentId,
  );

  /// Busca transações de um item de compra específico
  Future<Either<Failure, List<TransactionEntity>>>
  getTransactionsByShoppingItem(String projectId, String shoppingItemId);

  /// Cria uma transação manual
  Future<Either<Failure, void>> createManualTransaction(
    TransactionEntity transaction,
  );

  /// Cria transação de pagamento de parcela (COM WriteBatch)
  ///
  /// Operação atômica que:
  /// 1. Atualiza o installment (marca payment como pago)
  /// 2. Cria a transaction (expense)
  ///
  /// Se qualquer operação falhar, NENHUMA é executada
  Future<Either<Failure, void>> createInstallmentPaymentTransaction({
    required String projectId,
    required String installmentId,
    required String paymentId,
    required TransactionEntity transaction,
    required Map<String, dynamic> installmentUpdate,
  });

  /// Cancela pagamento de parcela (COM WriteBatch)
  ///
  /// Operação atômica que:
  /// 1. Atualiza o installment (desmarca payment)
  /// 2. Cria transaction de reversal (signedAmount negativo)
  /// 3. Marca transaction original como cancelled
  Future<Either<Failure, void>> cancelInstallmentPayment({
    required String projectId,
    required String installmentId,
    required String paymentId,
    required String originalTransactionId,
    required TransactionEntity reversalTransaction,
    required Map<String, dynamic> installmentUpdate,
  });

  /// Cria transação de compra (COM WriteBatch)
  ///
  /// Operação atômica que:
  /// 1. Atualiza o shopping item (marca como comprado)
  /// 2. Cria a transaction (expense)
  /// 3. Marca estimate como fulfilled (se existir)
  Future<Either<Failure, void>> createShoppingPurchaseTransaction({
    required String projectId,
    required String shoppingItemId,
    required TransactionEntity transaction,
    required Map<String, dynamic> shoppingItemUpdate,
    String? estimateTransactionId,
  });

  /// Cancela compra (COM WriteBatch)
  ///
  /// Operação atômica que:
  /// 1. Atualiza o shopping item (desmarca como comprado)
  /// 2. Cria transaction de reversal
  /// 3. Marca transaction original como cancelled
  /// 4. Reativa estimate (se existir)
  Future<Either<Failure, void>> cancelShoppingPurchase({
    required String projectId,
    required String shoppingItemId,
    required String originalTransactionId,
    required TransactionEntity reversalTransaction,
    required Map<String, dynamic> shoppingItemUpdate,
    String? estimateTransactionId,
  });

  /// Cria transação de contrato aceito (commitment)
  Future<Either<Failure, void>> createContractCommitment(
    TransactionEntity transaction,
  );

  /// Cancela contrato (COM WriteBatch)
  ///
  /// Operação atômica que:
  /// 1. Cria transaction de reversal
  /// 2. Marca commitment original como cancelled
  Future<Either<Failure, void>> cancelContract({
    required String projectId,
    required String originalTransactionId,
    required TransactionEntity reversalTransaction,
  });

  /// Atualiza uma transação
  Future<Either<Failure, void>> updateTransaction(
    String projectId,
    String transactionId,
    Map<String, dynamic> updates,
  );

  /// Deleta uma transação (apenas manuais)
  Future<Either<Failure, void>> deleteTransaction(
    String projectId,
    String transactionId,
  );

  /// Calcula resumo financeiro
  ///
  /// Retorna:
  /// - totalCommitted: soma de commitments ativos
  /// - totalExpenses: soma de expenses (signedAmount)
  /// - totalEstimates: soma de estimates ativos
  /// - pendingFromContracts: committed - paidFromContracts
  Future<Either<Failure, Map<String, double>>> getFinancialSummary(
    String projectId,
  );
}

// Made with Bob
