import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_entity.dart';

abstract class PaymentsState extends Equatable {
  const PaymentsState();

  @override
  List<Object?> get props => [];
}

class PaymentsInitial extends PaymentsState {}

class PaymentsLoading extends PaymentsState {}

class PaymentsLoaded extends PaymentsState {
  final List<PaymentEntity> payments;
  final double totalPending;
  final double totalPaid;
  final int pendingCount;
  final int paidCount;
  final int overdueCount;

  const PaymentsLoaded({
    required this.payments,
    required this.totalPending,
    required this.totalPaid,
    required this.pendingCount,
    required this.paidCount,
    required this.overdueCount,
  });

  @override
  List<Object?> get props => [
    payments,
    totalPending,
    totalPaid,
    pendingCount,
    paidCount,
    overdueCount,
  ];
}

class PaymentsError extends PaymentsState {
  final String message;

  const PaymentsError(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentOperationSuccess extends PaymentsState {
  final String message;

  const PaymentOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Made with Bob
