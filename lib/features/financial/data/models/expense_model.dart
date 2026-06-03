import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    required super.projectId,
    required super.categoryId,
    required super.amount,
    required super.date,
    required super.description,
    required super.status,
    super.supplierId,
    super.invoicePhotoUrl,
    super.phaseId,
    required super.createdAt,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String id) {
    return ExpenseModel(
      id: id,
      projectId: map['projectId'] ?? '',
      categoryId: map['categoryId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'] ?? '',
      status: ExpenseStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ExpenseStatus.estimated,
      ),
      supplierId: map['supplierId'],
      invoicePhotoUrl: map['invoicePhotoUrl'],
      phaseId: map['phaseId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'categoryId': categoryId,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
      'status': status.name,
      'supplierId': supplierId,
      'invoicePhotoUrl': invoicePhotoUrl,
      'phaseId': phaseId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      projectId: entity.projectId,
      categoryId: entity.categoryId,
      amount: entity.amount,
      date: entity.date,
      description: entity.description,
      status: entity.status,
      supplierId: entity.supplierId,
      invoicePhotoUrl: entity.invoicePhotoUrl,
      phaseId: entity.phaseId,
      createdAt: entity.createdAt,
    );
  }
}

// Made with Bob
