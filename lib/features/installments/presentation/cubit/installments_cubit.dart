import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../diary/domain/usecases/add_automatic_entry_usecase.dart';
import '../../../diary/domain/entities/diary_entry_entity.dart';
import '../../../financial/domain/usecases/update_phase_financials_usecase.dart';
import '../../domain/entities/installment_entity.dart';
import '../../domain/repositories/installment_repository.dart';
import '../../domain/usecases/get_installments_usecase.dart';
import '../../domain/usecases/add_installment_usecase.dart';
import '../../domain/usecases/mark_payment_as_paid_usecase.dart';
import '../../domain/usecases/delete_installment_usecase.dart';
import '../../../financial/domain/entities/transaction_entity.dart';
import '../../../financial/domain/usecases/cancel_installment_payment_usecase.dart';
import '../../../../injection_container.dart';
import 'installments_state.dart';

@injectable
class InstallmentsCubit extends Cubit<InstallmentsState> {
  final GetInstallmentsUseCase _getInstallmentsUseCase;
  final AddInstallmentUseCase _addInstallmentUseCase;
  final MarkPaymentAsPaidUseCase _markPaymentAsPaidUseCase;
  final CancelInstallmentPaymentUseCase _cancelPaymentUseCase;
  final DeleteInstallmentUseCase _deleteInstallmentUseCase;
  final UpdatePhaseFinancialsUseCase _updatePhaseFinancialsUseCase;
  final AddAutomaticEntryUseCase _addAutomaticEntryUseCase;

  InstallmentsCubit(
    this._getInstallmentsUseCase,
    this._addInstallmentUseCase,
    this._markPaymentAsPaidUseCase,
    this._cancelPaymentUseCase,
    this._deleteInstallmentUseCase,
    this._updatePhaseFinancialsUseCase,
    this._addAutomaticEntryUseCase,
  ) : super(InstallmentsInitial());

  Future<void> loadInstallments(String projectId) async {
    emit(InstallmentsLoading());

    final result = await _getInstallmentsUseCase(projectId);

    result.fold((failure) => emit(InstallmentsError(failure.message)), (
      installments,
    ) {
      // Calcular total pendente nos próximos 30 dias
      final now = DateTime.now();
      final next30Days = now.add(const Duration(days: 30));

      double totalPending = 0;
      int overdueCount = 0;

      for (final installment in installments) {
        for (final payment in installment.payments) {
          if (!payment.isPaid) {
            if (payment.dueDate.isBefore(now)) {
              overdueCount++;
            }
            if (payment.dueDate.isAfter(now) &&
                payment.dueDate.isBefore(next30Days)) {
              totalPending += payment.amount;
            }
          }
        }
      }

      emit(
        InstallmentsLoaded(
          installments: installments,
          totalPendingNext30Days: totalPending,
          overdueCount: overdueCount,
        ),
      );
    });
  }

  Future<void> addInstallment({
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
    final result = await _addInstallmentUseCase(
      projectId: projectId,
      supplierId: supplierId,
      supplierName: supplierName,
      serviceDescription: serviceDescription,
      phaseId: phaseId,
      totalValue: totalValue,
      totalInstallments: totalInstallments,
      contractDate: contractDate,
      firstPaymentDate: firstPaymentDate,
    );

    result.fold((failure) => emit(InstallmentsError(failure.message)), (_) {
      emit(InstallmentOperationSuccess('Contrato adicionado com sucesso'));
      loadInstallments(projectId);
    });
  }

  Future<void> markPaymentAsPaid({
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
    final result = await _markPaymentAsPaidUseCase(
      projectId: projectId,
      installmentId: installmentId,
      paymentId: paymentId,
      paidAmount: paidAmount,
      paidAt: paidAt,
      supplierName: supplierName,
      serviceDescription: serviceDescription,
      supplierId: supplierId,
      phaseId: phaseId,
      categoryId: categoryId,
    );

    await result.fold(
      (failure) async => emit(InstallmentsError(failure.message)),
      (_) async {
        // INTEGRAÇÃO: Atualiza financeiro da fase
        if (phaseId != null) {
          await _updatePhaseFinancialsUseCase(
            projectId: projectId,
            phaseId: phaseId,
          );
        }

        // INTEGRAÇÃO: Adiciona log automático no diário
        await _addAutomaticEntryUseCase(
          projectId: projectId,
          title: 'Parcela paga',
          description:
              '$supplierName - $serviceDescription - R\$ ${paidAmount.toStringAsFixed(2)}',
          phaseId: phaseId,
          type: DiaryEntryType.daily,
        );

        emit(InstallmentOperationSuccess('Parcela marcada como paga'));
        await loadInstallments(projectId);
      },
    );
  }

  /// Cancela um pagamento já realizado
  /// Cria uma transaction de reversal (signedAmount negativo)
  Future<void> cancelPayment({
    required String projectId,
    required String installmentId,
    required String paymentId,
    required String originalTransactionId,
    required double paidAmount,
    required String supplierName,
    required String serviceDescription,
    required String supplierId,
    String? phaseId,
    String? categoryId,
  }) async {
    // 1. Buscar o installment para preparar o update
    final installmentRepository = getIt<InstallmentRepository>();
    final installmentResult = await installmentRepository.getInstallment(
      projectId,
      installmentId,
    );

    if (installmentResult.isLeft()) {
      emit(InstallmentsError('Erro ao buscar contrato'));
      return;
    }

    final installment = installmentResult.getOrElse(() => throw Exception());

    // 2. Atualizar os payments (desmarcar como pago)
    final updatedPayments = installment.payments.map((payment) {
      if (payment.id == paymentId) {
        return PaymentEntity(
          id: payment.id,
          number: payment.number,
          amount: payment.amount,
          dueDate: payment.dueDate,
          isPaid: false,
          paidAt: null,
          paidAmount: null,
        );
      }
      return payment;
    }).toList();

    // 3. Recalcular status
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

    // 4. Criar reversal transaction
    final uuid = getIt<Uuid>();
    final reversalTransaction = TransactionEntity(
      id: uuid.v4(),
      projectId: projectId,
      type: TransactionType.reversal,
      source: TransactionSource.installmentReversal,
      amount: paidAmount,
      signedAmount: -paidAmount, // NEGATIVO para reversal
      date: DateTime.now(),
      description: 'Cancelamento - $supplierName - $serviceDescription',
      supplierId: supplierId,
      installmentId: installmentId,
      paymentId: paymentId,
      relatedTransactionId: originalTransactionId,
      phaseId: phaseId,
      categoryId: categoryId,
      status: TransactionStatus.active,
      createdAt: DateTime.now(),
    );

    // 5. Preparar installment update
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

    // 6. Executar cancelamento atômico
    final result = await _cancelPaymentUseCase(
      CancelInstallmentPaymentParams(
        projectId: projectId,
        installmentId: installmentId,
        paymentId: paymentId,
        originalTransactionId: originalTransactionId,
        reversalTransaction: reversalTransaction,
        installmentUpdate: installmentUpdate,
      ),
    );

    result.fold((failure) => emit(InstallmentsError(failure.message)), (_) {
      emit(
        InstallmentOperationSuccess(
          'Pagamento cancelado. O valor foi estornado.',
        ),
      );
      loadInstallments(projectId);
    });
  }

  Future<void> deleteInstallment(String projectId, String installmentId) async {
    final result = await _deleteInstallmentUseCase(
      DeleteInstallmentParams(
        projectId: projectId,
        installmentId: installmentId,
      ),
    );

    result.fold(
      (failure) => emit(InstallmentsError(failure.message)),
      (_) => loadInstallments(projectId),
    );
  }

  // Métodos de conveniência para compatibilidade com forms
  Future<void> createInstallment(InstallmentEntity installment) async {
    await addInstallment(
      projectId: installment.projectId,
      supplierId: installment.supplierId,
      supplierName: installment.supplierName,
      serviceDescription: installment.serviceDescription,
      phaseId: installment.phaseId,
      totalValue: installment.totalValue,
      totalInstallments: installment.totalInstallments,
      contractDate: installment.contractDate,
      firstPaymentDate: installment.payments.first.dueDate,
    );
  }

  Future<void> updateInstallment(InstallmentEntity installment) async {
    // Para atualizar, deletamos e recriamos
    await deleteInstallment(installment.projectId, installment.id);
    await createInstallment(installment);
  }
}

// Made with Bob
