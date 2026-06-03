import 'package:equatable/equatable.dart';
import '../../domain/entities/installment_entity.dart';

abstract class InstallmentsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InstallmentsInitial extends InstallmentsState {}

class InstallmentsLoading extends InstallmentsState {}

class InstallmentsLoaded extends InstallmentsState {
  final List<InstallmentEntity> installments;
  final double totalPendingNext30Days;
  final int overdueCount;

  InstallmentsLoaded({
    required this.installments,
    required this.totalPendingNext30Days,
    required this.overdueCount,
  });

  @override
  List<Object?> get props => [
    installments,
    totalPendingNext30Days,
    overdueCount,
  ];
}

class InstallmentDetailLoaded extends InstallmentsState {
  final InstallmentEntity installment;

  InstallmentDetailLoaded(this.installment);

  @override
  List<Object?> get props => [installment];
}

class InstallmentsError extends InstallmentsState {
  final String message;

  InstallmentsError(this.message);

  @override
  List<Object?> get props => [message];
}

class InstallmentOperationSuccess extends InstallmentsState {
  final String message;

  InstallmentOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Made with Bob
