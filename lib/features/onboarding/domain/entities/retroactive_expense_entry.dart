import 'package:equatable/equatable.dart';

/// Entrada de despesa retroativa (importação rápida)
class RetroactiveExpenseEntry extends Equatable {
  final String id;
  final String description;
  final double amount;
  final String categoryId;
  final String status; // 'confirmed' | 'estimated'
  final String? invoicePhotoUrl;
  final DateTime approximateDate; // mês/ano aproximado

  const RetroactiveExpenseEntry({
    required this.id,
    required this.description,
    required this.amount,
    required this.categoryId,
    required this.status,
    this.invoicePhotoUrl,
    required this.approximateDate,
  });

  RetroactiveExpenseEntry copyWith({
    String? id,
    String? description,
    double? amount,
    String? categoryId,
    String? status,
    String? invoicePhotoUrl,
    DateTime? approximateDate,
  }) {
    return RetroactiveExpenseEntry(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      status: status ?? this.status,
      invoicePhotoUrl: invoicePhotoUrl ?? this.invoicePhotoUrl,
      approximateDate: approximateDate ?? this.approximateDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    description,
    amount,
    categoryId,
    status,
    invoicePhotoUrl,
    approximateDate,
  ];
}

// Made with Bob
