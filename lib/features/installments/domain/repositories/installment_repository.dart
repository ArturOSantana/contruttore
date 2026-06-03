import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/installment_entity.dart';

abstract class InstallmentRepository {
  Future<Either<Failure, List<InstallmentEntity>>> getInstallments(
    String projectId,
  );
  Future<Either<Failure, InstallmentEntity>> getInstallment(
    String projectId,
    String installmentId,
  );
  Future<Either<Failure, void>> addInstallment(InstallmentEntity installment);
  Future<Either<Failure, void>> updateInstallment(
    InstallmentEntity installment,
  );
  Future<Either<Failure, void>> deleteInstallment(
    String projectId,
    String installmentId,
  );
  Future<Either<Failure, void>> markPaymentAsPaid({
    required String projectId,
    required String installmentId,
    required String paymentId,
    required double paidAmount,
    required DateTime paidAt,
  });
}

// Made with Bob
