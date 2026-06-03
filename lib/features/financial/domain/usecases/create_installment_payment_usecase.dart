import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Use case para criar transação de pagamento de parcela
///
/// Operação atômica que:
/// 1. Atualiza o installment (marca payment como pago)
/// 2. Cria a transaction (expense)
@lazySingleton
class CreateInstallmentPaymentUseCase
    implements UseCase<void, CreateInstallmentPaymentParams> {
  final TransactionRepository _repository;

  CreateInstallmentPaymentUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(
    CreateInstallmentPaymentParams params,
  ) async {
    return await _repository.createInstallmentPaymentTransaction(
      projectId: params.projectId,
      installmentId: params.installmentId,
      paymentId: params.paymentId,
      transaction: params.transaction,
      installmentUpdate: params.installmentUpdate,
    );
  }
}

class CreateInstallmentPaymentParams {
  final String projectId;
  final String installmentId;
  final String paymentId;
  final TransactionEntity transaction;
  final Map<String, dynamic> installmentUpdate;

  CreateInstallmentPaymentParams({
    required this.projectId,
    required this.installmentId,
    required this.paymentId,
    required this.transaction,
    required this.installmentUpdate,
  });
}

// Made with Bob
