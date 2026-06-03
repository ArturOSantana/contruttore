import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/payment_repository.dart';

@injectable
class MarkPaymentAsPaidUseCase {
  final PaymentRepository _paymentRepository;

  MarkPaymentAsPaidUseCase(this._paymentRepository);

  /// Marca um payment como pago
  ///
  /// Este método:
  /// 1. Marca o payment como pago no Firestore
  /// 2. O recálculo financeiro acontece automaticamente via queries
  ///    (GetFinancialSummaryUseCase busca payments pagos)
  Future<Either<Failure, void>> call({
    required String projectId,
    required String paymentId,
    required DateTime paidAt,
  }) async {
    try {
      await _paymentRepository.markAsPaid(
        projectId: projectId,
        paymentId: paymentId,
        paidAt: paidAt,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao marcar pagamento como pago: $e'));
    }
  }
}

// Made with Bob
