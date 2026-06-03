import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../repositories/installment_repository.dart';
import '../entities/installment_entity.dart';
import '../../../financial/domain/entities/transaction_entity.dart';
import '../../../financial/domain/usecases/create_installment_payment_usecase.dart';

/// Use Case para marcar parcela como paga
///
/// MIGRADO PARA NOVA ARQUITETURA:
/// - Usa CreateInstallmentPaymentUseCase (operação atômica com WriteBatch)
/// - Cria TransactionEntity ao invés de ExpenseEntity
/// - Garante atomicidade: installment + transaction juntos ou nenhum
@injectable
class MarkPaymentAsPaidUseCase {
  final InstallmentRepository _installmentRepository;
  final CreateInstallmentPaymentUseCase _createPaymentUseCase;
  final Uuid _uuid;

  MarkPaymentAsPaidUseCase(
    this._installmentRepository,
    this._createPaymentUseCase,
    this._uuid,
  );

  Future<Either<Failure, void>> call({
    required String projectId,
    required String installmentId,
    required String paymentId,
    required double paidAmount,
    required DateTime paidAt,
    required String supplierName,
    required String serviceDescription,
    required String supplierId,
    String? phaseId,
    String? categoryId,
  }) async {
    // 1. Buscar o installment atual para preparar o update
    final installmentResult = await _installmentRepository.getInstallment(
      projectId,
      installmentId,
    );

    if (installmentResult.isLeft()) {
      return installmentResult.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    }

    final installment = installmentResult.getOrElse(() => throw Exception());

    // 2. Atualizar os payments
    final updatedPayments = installment.payments.map((payment) {
      if (payment.id == paymentId) {
        return PaymentEntity(
          id: payment.id,
          number: payment.number,
          amount: payment.amount,
          dueDate: payment.dueDate,
          isPaid: true,
          paidAt: paidAt,
          paidAmount: paidAmount,
        );
      }
      return payment;
    }).toList();

    // 3. Calcular novo status
    final allPaid = updatedPayments.every((p) => p.isPaid);
    final hasOverdue = updatedPayments.any(
      (p) => !p.isPaid && p.dueDate.isBefore(DateTime.now()),
    );

    InstallmentStatus newStatus;
    if (allPaid) {
      newStatus = InstallmentStatus.completed;
    } else if (hasOverdue) {
      newStatus = InstallmentStatus.overdue;
    } else {
      newStatus = InstallmentStatus.active;
    }

    // 4. Criar a transaction (expense)
    final transaction = TransactionEntity(
      id: _uuid.v4(),
      projectId: projectId,
      type: TransactionType.expense,
      source: TransactionSource.installment,
      amount: paidAmount,
      signedAmount: paidAmount, // Positivo (não é reversal)
      date: paidAt,
      description: 'Parcela - $supplierName - $serviceDescription',
      supplierId: supplierId,
      installmentId: installmentId,
      paymentId: paymentId,
      phaseId: phaseId,
      categoryId: categoryId,
      status: TransactionStatus.active,
      createdAt: DateTime.now(),
    );

    // 5. Preparar update do installment (será feito atomicamente)
    // Convertemos payments para Map para o Firestore
    final paymentsMap = updatedPayments
        .map(
          (p) => {
            'id': p.id,
            'number': p.number,
            'amount': p.amount,
            'dueDate': p.dueDate.toIso8601String(),
            'isPaid': p.isPaid,
            'paidAt': p.paidAt?.toIso8601String(),
            'paidAmount': p.paidAmount,
          },
        )
        .toList();

    final installmentUpdate = {
      'payments': paymentsMap,
      'status': newStatus.name,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    // 6. Executar operação atômica via CreateInstallmentPaymentUseCase
    return await _createPaymentUseCase(
      CreateInstallmentPaymentParams(
        projectId: projectId,
        installmentId: installmentId,
        paymentId: paymentId,
        transaction: transaction,
        installmentUpdate: installmentUpdate,
      ),
    );
  }
}

// Made with Bob
