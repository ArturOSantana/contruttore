import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Use case para cancelar pagamento de parcela
///
/// Operação atômica que:
/// 1. Atualiza o installment (desmarca payment)
/// 2. Cria transaction de reversal (signedAmount negativo)
/// 3. Marca transaction original como cancelled
@lazySingleton
class CancelInstallmentPaymentUseCase
    implements UseCase<void, CancelInstallmentPaymentParams> {
  final TransactionRepository _repository;

  CancelInstallmentPaymentUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(
    CancelInstallmentPaymentParams params,
  ) async {
    return await _repository.cancelInstallmentPayment(
      projectId: params.projectId,
      installmentId: params.installmentId,
      paymentId: params.paymentId,
      originalTransactionId: params.originalTransactionId,
      reversalTransaction: params.reversalTransaction,
      installmentUpdate: params.installmentUpdate,
    );
  }
}

class CancelInstallmentPaymentParams {
  final String projectId;
  final String installmentId;
  final String paymentId;
  final String originalTransactionId;
  final TransactionEntity reversalTransaction;
  final Map<String, dynamic> installmentUpdate;

  CancelInstallmentPaymentParams({
    required this.projectId,
    required this.installmentId,
    required this.paymentId,
    required this.originalTransactionId,
    required this.reversalTransaction,
    required this.installmentUpdate,
  });
}

// Made with Bob
