import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/usecases/mark_payment_as_paid_usecase.dart';
import 'payments_state.dart';

@injectable
class PaymentsCubit extends Cubit<PaymentsState> {
  final PaymentRepository _paymentRepository;
  final MarkPaymentAsPaidUseCase _markPaymentAsPaidUseCase;

  PaymentsCubit(this._paymentRepository, this._markPaymentAsPaidUseCase)
    : super(PaymentsInitial());

  /// Carrega todos os payments de um projeto
  Future<void> loadPayments(String projectId) async {
    try {
      emit(PaymentsLoading());

      final payments = await _paymentRepository.getPayments(projectId);

      _emitLoadedState(payments);
    } catch (e) {
      emit(PaymentsError('Erro ao carregar parcelas: ${e.toString()}'));
    }
  }

  /// Carrega apenas payments pendentes
  Future<void> loadPendingPayments(String projectId) async {
    try {
      emit(PaymentsLoading());

      final payments = await _paymentRepository.getPendingPayments(projectId);

      _emitLoadedState(payments);
    } catch (e) {
      emit(
        PaymentsError('Erro ao carregar parcelas pendentes: ${e.toString()}'),
      );
    }
  }

  /// Carrega payments que vencem nos próximos 3 dias
  Future<void> loadUpcomingPayments(String projectId) async {
    try {
      emit(PaymentsLoading());

      final payments = await _paymentRepository.getUpcomingPayments(projectId);

      _emitLoadedState(payments);
    } catch (e) {
      emit(
        PaymentsError('Erro ao carregar próximas parcelas: ${e.toString()}'),
      );
    }
  }

  /// Carrega payments vencidos
  Future<void> loadOverduePayments(String projectId) async {
    try {
      emit(PaymentsLoading());

      final payments = await _paymentRepository.getOverduePayments(projectId);

      _emitLoadedState(payments);
    } catch (e) {
      emit(
        PaymentsError('Erro ao carregar parcelas vencidas: ${e.toString()}'),
      );
    }
  }

  /// Carrega payments de uma fonte específica (supplier ou purchase)
  Future<void> loadPaymentsBySource(String projectId, String sourceId) async {
    try {
      emit(PaymentsLoading());

      final payments = await _paymentRepository.getPaymentsBySource(
        projectId: projectId,
        sourceId: sourceId,
      );

      _emitLoadedState(payments);
    } catch (e) {
      emit(
        PaymentsError('Erro ao carregar parcelas da fonte: ${e.toString()}'),
      );
    }
  }

  /// Marca um payment como pago
  Future<void> markAsPaid(String projectId, String paymentId) async {
    try {
      final result = await _markPaymentAsPaidUseCase(
        projectId: projectId,
        paymentId: paymentId,
        paidAt: DateTime.now(),
      );

      result.fold(
        (failure) => emit(PaymentsError(failure.message)),
        (_) => emit(const PaymentOperationSuccess('Parcela marcada como paga')),
      );
    } catch (e) {
      emit(PaymentsError('Erro ao marcar parcela como paga: ${e.toString()}'));
    }
  }

  /// Cancela payments pendentes de uma fonte
  Future<void> cancelPendingPaymentsBySource(
    String projectId,
    String sourceId,
  ) async {
    try {
      await _paymentRepository.cancelPendingPaymentsBySource(
        projectId: projectId,
        sourceId: sourceId,
      );

      emit(const PaymentOperationSuccess('Parcelas pendentes canceladas'));

      // Recarrega a lista após cancelar
      await loadPayments(projectId);
    } catch (e) {
      emit(PaymentsError('Erro ao cancelar parcelas: ${e.toString()}'));
    }
  }

  /// Stream de payments em tempo real
  Stream<List<PaymentEntity>> watchPayments(String projectId) {
    return _paymentRepository.watchPayments(projectId);
  }

  /// Stream de payments pendentes em tempo real
  Stream<List<PaymentEntity>> watchPendingPayments(String projectId) {
    return _paymentRepository.watchPendingPayments(projectId);
  }

  /// Calcula estatísticas e emite estado carregado
  void _emitLoadedState(List<PaymentEntity> payments) {
    double totalPending = 0;
    double totalPaid = 0;
    int pendingCount = 0;
    int paidCount = 0;
    int overdueCount = 0;

    for (final payment in payments) {
      if (payment.paid) {
        totalPaid += payment.amount;
        paidCount++;
      } else {
        totalPending += payment.amount;
        pendingCount++;

        if (payment.isOverdue) {
          overdueCount++;
        }
      }
    }

    emit(
      PaymentsLoaded(
        payments: payments,
        totalPending: totalPending,
        totalPaid: totalPaid,
        pendingCount: pendingCount,
        paidCount: paidCount,
        overdueCount: overdueCount,
      ),
    );
  }
}

// Made with Bob
