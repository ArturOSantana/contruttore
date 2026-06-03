import 'package:equatable/equatable.dart';

class ExpenseEntity extends Equatable {
  final String id;
  final String projectId;
  final String categoryId;
  final double amount;
  final DateTime date;
  final String description;
  final ExpenseStatus status;
  final String? supplierId;
  final String? invoicePhotoUrl;
  final String? phaseId;
  final DateTime createdAt;

  const ExpenseEntity({
    required this.id,
    required this.projectId,
    required this.categoryId,
    required this.amount,
    required this.date,
    required this.description,
    required this.status,
    this.supplierId,
    this.invoicePhotoUrl,
    this.phaseId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    projectId,
    categoryId,
    amount,
    date,
    description,
    status,
    supplierId,
    invoicePhotoUrl,
    phaseId,
    createdAt,
  ];
}

enum ExpenseStatus {
  confirmed, // Pago
  committed, // Orçamento aceito
  estimated, // Estimativa
}

// Made with Bob
