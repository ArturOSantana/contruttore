import 'package:equatable/equatable.dart';

class InstallmentEntity extends Equatable {
  final String id;
  final String projectId;
  final String supplierId;
  final String supplierName;
  final String serviceDescription;
  final String? phaseId;
  final double totalValue;
  final int totalInstallments;
  final DateTime contractDate;
  final InstallmentStatus status;
  final List<PaymentEntity> payments;
  final DateTime createdAt;

  const InstallmentEntity({
    required this.id,
    required this.projectId,
    required this.supplierId,
    required this.supplierName,
    required this.serviceDescription,
    this.phaseId,
    required this.totalValue,
    required this.totalInstallments,
    required this.contractDate,
    required this.status,
    required this.payments,
    required this.createdAt,
  });

  // Métodos auxiliares
  int get paidCount => payments.where((p) => p.isPaid).length;
  int get pendingCount => payments.where((p) => !p.isPaid).length;
  double get paidAmount => payments
      .where((p) => p.isPaid)
      .fold(0.0, (sum, p) => sum + (p.paidAmount ?? 0));
  double get pendingAmount =>
      payments.where((p) => !p.isPaid).fold(0.0, (sum, p) => sum + p.amount);
  bool get isCompleted => paidCount == totalInstallments;
  bool get hasOverdue =>
      payments.any((p) => !p.isPaid && p.dueDate.isBefore(DateTime.now()));

  @override
  List<Object?> get props => [
    id,
    projectId,
    supplierId,
    supplierName,
    serviceDescription,
    phaseId,
    totalValue,
    totalInstallments,
    contractDate,
    status,
    payments,
    createdAt,
  ];
}

enum InstallmentStatus { active, completed, overdue }

class PaymentEntity extends Equatable {
  final String id;
  final int number;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final DateTime? paidAt;
  final double? paidAmount;

  const PaymentEntity({
    required this.id,
    required this.number,
    required this.amount,
    required this.dueDate,
    required this.isPaid,
    this.paidAt,
    this.paidAmount,
  });

  // Status da parcela
  PaymentStatus get status {
    if (isPaid) return PaymentStatus.paid;
    final now = DateTime.now();
    final daysUntilDue = dueDate.difference(now).inDays;

    if (daysUntilDue < 0) return PaymentStatus.overdue;
    if (daysUntilDue <= 3) return PaymentStatus.dueSoon;
    if (daysUntilDue <= 7) return PaymentStatus.upcoming;
    return PaymentStatus.future;
  }

  @override
  List<Object?> get props => [
    id,
    number,
    amount,
    dueDate,
    isPaid,
    paidAt,
    paidAmount,
  ];
}

enum PaymentStatus { paid, overdue, dueSoon, upcoming, future }

// Made with Bob
