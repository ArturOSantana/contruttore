import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../entities/installment_entity.dart';
import '../repositories/installment_repository.dart';

@injectable
class AddInstallmentUseCase {
  final InstallmentRepository _repository;
  final Uuid _uuid;

  AddInstallmentUseCase(this._repository, this._uuid);

  Future<Either<Failure, void>> call({
    required String projectId,
    required String supplierId,
    required String supplierName,
    required String serviceDescription,
    String? phaseId,
    required double totalValue,
    required int totalInstallments,
    required DateTime contractDate,
    required DateTime firstPaymentDate,
  }) async {
    // Gerar parcelas automaticamente
    final payments = <PaymentEntity>[];
    final installmentValue = totalValue / totalInstallments;

    for (int i = 0; i < totalInstallments; i++) {
      final dueDate = DateTime(
        firstPaymentDate.year,
        firstPaymentDate.month + i,
        firstPaymentDate.day,
      );

      payments.add(
        PaymentEntity(
          id: _uuid.v4(),
          number: i + 1,
          amount: installmentValue,
          dueDate: dueDate,
          isPaid: false,
        ),
      );
    }

    final installment = InstallmentEntity(
      id: _uuid.v4(),
      projectId: projectId,
      supplierId: supplierId,
      supplierName: supplierName,
      serviceDescription: serviceDescription,
      phaseId: phaseId,
      totalValue: totalValue,
      totalInstallments: totalInstallments,
      contractDate: contractDate,
      status: InstallmentStatus.active,
      payments: payments,
      createdAt: DateTime.now(),
    );

    return _repository.addInstallment(installment);
  }
}

// Made with Bob
