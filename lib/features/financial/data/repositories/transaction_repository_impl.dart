import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

/// Implementação do TransactionRepository com WriteBatch
///
/// REGRA CRÍTICA: Toda operação que modifica múltiplos documentos
/// USA WriteBatch para garantir atomicidade (tudo ou nada)
@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl implements TransactionRepository {
  final FirebaseFirestore _firestore;

  TransactionRepositoryImpl(this._firestore);

  // Helper para obter a coleção de transactions
  CollectionReference _transactionsCollection(String projectId) {
    return _firestore
        .collection('projects')
        .doc(projectId)
        .collection('transactions');
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
    String projectId,
  ) async {
    try {
      final snapshot = await _transactionsCollection(
        projectId,
      ).orderBy('date', descending: true).get();

      final transactions = snapshot.docs
          .map(
            (doc) => TransactionModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();

      return Right(transactions);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao buscar transações'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByType(
    String projectId,
    TransactionType type,
  ) async {
    try {
      final typeString = _typeToString(type);
      final snapshot = await _transactionsCollection(projectId)
          .where('type', isEqualTo: typeString)
          .orderBy('date', descending: true)
          .get();

      final transactions = snapshot.docs
          .map(
            (doc) => TransactionModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();

      return Right(transactions);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao buscar transações'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsBySource(
    String projectId,
    TransactionSource source,
  ) async {
    try {
      final sourceString = _sourceToString(source);
      final snapshot = await _transactionsCollection(projectId)
          .where('source', isEqualTo: sourceString)
          .orderBy('date', descending: true)
          .get();

      final transactions = snapshot.docs
          .map(
            (doc) => TransactionModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();

      return Right(transactions);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao buscar transações'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByInstallment(
    String projectId,
    String installmentId,
  ) async {
    try {
      final snapshot = await _transactionsCollection(projectId)
          .where('installmentId', isEqualTo: installmentId)
          .orderBy('date', descending: true)
          .get();

      final transactions = snapshot.docs
          .map(
            (doc) => TransactionModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();

      return Right(transactions);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao buscar transações'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>>
  getTransactionsByShoppingItem(String projectId, String shoppingItemId) async {
    try {
      final snapshot = await _transactionsCollection(projectId)
          .where('shoppingItemId', isEqualTo: shoppingItemId)
          .orderBy('date', descending: true)
          .get();

      final transactions = snapshot.docs
          .map(
            (doc) => TransactionModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();

      return Right(transactions);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao buscar transações'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> createManualTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await _transactionsCollection(
        transaction.projectId,
      ).doc(transaction.id).set(model.toMap());

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao criar transação'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> createInstallmentPaymentTransaction({
    required String projectId,
    required String installmentId,
    required String paymentId,
    required TransactionEntity transaction,
    required Map<String, dynamic> installmentUpdate,
  }) async {
    try {
      // WRITEBATCH: Operação atômica
      final batch = _firestore.batch();

      // 1. Atualiza o installment (marca payment como pago)
      final installmentRef = _firestore
          .collection('projects')
          .doc(projectId)
          .collection('installments')
          .doc(installmentId);

      batch.update(installmentRef, installmentUpdate);

      // 2. Cria a transaction (expense)
      final transactionRef = _transactionsCollection(
        projectId,
      ).doc(transaction.id);
      final model = TransactionModel.fromEntity(transaction);
      batch.set(transactionRef, model.toMap());

      // Commit: ambas as operações ou nenhuma
      await batch.commit();

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(e.message ?? 'Erro ao criar transação de pagamento'),
      );
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelInstallmentPayment({
    required String projectId,
    required String installmentId,
    required String paymentId,
    required String originalTransactionId,
    required TransactionEntity reversalTransaction,
    required Map<String, dynamic> installmentUpdate,
  }) async {
    try {
      // WRITEBATCH: Operação atômica
      final batch = _firestore.batch();

      // 1. Atualiza o installment (desmarca payment)
      final installmentRef = _firestore
          .collection('projects')
          .doc(projectId)
          .collection('installments')
          .doc(installmentId);

      batch.update(installmentRef, installmentUpdate);

      // 2. Cria transaction de reversal (signedAmount negativo)
      final reversalRef = _transactionsCollection(
        projectId,
      ).doc(reversalTransaction.id);
      final reversalModel = TransactionModel.fromEntity(reversalTransaction);
      batch.set(reversalRef, reversalModel.toMap());

      // 3. Marca transaction original como cancelled
      final originalRef = _transactionsCollection(
        projectId,
      ).doc(originalTransactionId);
      batch.update(originalRef, {'status': 'cancelled'});

      // Commit: todas as operações ou nenhuma
      await batch.commit();

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao cancelar pagamento'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> createShoppingPurchaseTransaction({
    required String projectId,
    required String shoppingItemId,
    required TransactionEntity transaction,
    required Map<String, dynamic> shoppingItemUpdate,
    String? estimateTransactionId,
  }) async {
    try {
      // WRITEBATCH: Operação atômica
      final batch = _firestore.batch();

      // 1. Atualiza o shopping item (marca como comprado)
      final shoppingRef = _firestore
          .collection('projects')
          .doc(projectId)
          .collection('shopping')
          .doc(shoppingItemId);

      batch.update(shoppingRef, shoppingItemUpdate);

      // 2. Cria a transaction (expense)
      final transactionRef = _transactionsCollection(
        projectId,
      ).doc(transaction.id);
      final model = TransactionModel.fromEntity(transaction);
      batch.set(transactionRef, model.toMap());

      // 3. Marca estimate como fulfilled (se existir)
      if (estimateTransactionId != null) {
        final estimateRef = _transactionsCollection(
          projectId,
        ).doc(estimateTransactionId);
        batch.update(estimateRef, {
          'status': 'fulfilled',
          'relatedTransactionId': transaction.id,
        });
      }

      // Commit: todas as operações ou nenhuma
      await batch.commit();

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(e.message ?? 'Erro ao criar transação de compra'),
      );
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelShoppingPurchase({
    required String projectId,
    required String shoppingItemId,
    required String originalTransactionId,
    required TransactionEntity reversalTransaction,
    required Map<String, dynamic> shoppingItemUpdate,
    String? estimateTransactionId,
  }) async {
    try {
      // WRITEBATCH: Operação atômica
      final batch = _firestore.batch();

      // 1. Atualiza o shopping item (desmarca como comprado)
      final shoppingRef = _firestore
          .collection('projects')
          .doc(projectId)
          .collection('shopping')
          .doc(shoppingItemId);

      batch.update(shoppingRef, shoppingItemUpdate);

      // 2. Cria transaction de reversal
      final reversalRef = _transactionsCollection(
        projectId,
      ).doc(reversalTransaction.id);
      final reversalModel = TransactionModel.fromEntity(reversalTransaction);
      batch.set(reversalRef, reversalModel.toMap());

      // 3. Marca transaction original como cancelled
      final originalRef = _transactionsCollection(
        projectId,
      ).doc(originalTransactionId);
      batch.update(originalRef, {'status': 'cancelled'});

      // 4. Reativa estimate (se existir)
      if (estimateTransactionId != null) {
        final estimateRef = _transactionsCollection(
          projectId,
        ).doc(estimateTransactionId);
        batch.update(estimateRef, {
          'status': 'active',
          'relatedTransactionId': null,
        });
      }

      // Commit: todas as operações ou nenhuma
      await batch.commit();

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao cancelar compra'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> createContractCommitment(
    TransactionEntity transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await _transactionsCollection(
        transaction.projectId,
      ).doc(transaction.id).set(model.toMap());

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao criar compromisso'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelContract({
    required String projectId,
    required String originalTransactionId,
    required TransactionEntity reversalTransaction,
  }) async {
    try {
      // WRITEBATCH: Operação atômica
      final batch = _firestore.batch();

      // 1. Cria transaction de reversal
      final reversalRef = _transactionsCollection(
        projectId,
      ).doc(reversalTransaction.id);
      final reversalModel = TransactionModel.fromEntity(reversalTransaction);
      batch.set(reversalRef, reversalModel.toMap());

      // 2. Marca commitment original como cancelled
      final originalRef = _transactionsCollection(
        projectId,
      ).doc(originalTransactionId);
      batch.update(originalRef, {'status': 'cancelled'});

      // Commit: ambas as operações ou nenhuma
      await batch.commit();

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao cancelar contrato'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTransaction(
    String projectId,
    String transactionId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _transactionsCollection(
        projectId,
      ).doc(transactionId).update(updates);

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao atualizar transação'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(
    String projectId,
    String transactionId,
  ) async {
    try {
      await _transactionsCollection(projectId).doc(transactionId).delete();

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao deletar transação'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getFinancialSummary(
    String projectId,
  ) async {
    try {
      final snapshot = await _transactionsCollection(projectId).get();

      final transactions = snapshot.docs
          .map(
            (doc) => TransactionModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();

      // Filtra apenas transações ativas
      final activeTransactions = transactions.where((t) => t.isActive).toList();

      // Calcula totais usando signedAmount (considera reversals)
      double totalCommitted = 0;
      double totalExpenses = 0;
      double totalEstimates = 0;

      for (final transaction in activeTransactions) {
        switch (transaction.type) {
          case TransactionType.commitment:
            totalCommitted += transaction.amount; // Sempre positivo
            break;
          case TransactionType.expense:
            totalExpenses +=
                transaction.signedAmount; // Pode ser negativo (reversal)
            break;
          case TransactionType.estimate:
            totalEstimates += transaction.amount;
            break;
          case TransactionType.reversal:
            // Reversals já estão incluídos via signedAmount
            break;
        }
      }

      // Calcula pendente de contratos
      // Pega expenses que vieram de installments
      final expensesFromContracts = activeTransactions
          .where(
            (t) =>
                t.type == TransactionType.expense &&
                t.source == TransactionSource.installment,
          )
          .fold<double>(0, (sum, t) => sum + t.signedAmount);

      final pendingFromContracts = totalCommitted - expensesFromContracts;

      return Right({
        'totalCommitted': totalCommitted,
        'totalExpenses': totalExpenses,
        'totalEstimates': totalEstimates,
        'pendingFromContracts': pendingFromContracts,
        'expensesFromContracts': expensesFromContracts,
      });
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao calcular resumo'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  // Helpers para conversão de enum
  String _typeToString(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return 'expense';
      case TransactionType.commitment:
        return 'commitment';
      case TransactionType.estimate:
        return 'estimate';
      case TransactionType.reversal:
        return 'reversal';
    }
  }

  String _sourceToString(TransactionSource source) {
    switch (source) {
      case TransactionSource.manual:
        return 'manual';
      case TransactionSource.installment:
        return 'installment';
      case TransactionSource.installmentReversal:
        return 'installment_reversal';
      case TransactionSource.shopping:
        return 'shopping';
      case TransactionSource.shoppingReversal:
        return 'shopping_reversal';
      case TransactionSource.contract:
        return 'contract';
      case TransactionSource.contractCancel:
        return 'contract_cancel';
    }
  }
}

// Made with Bob
