import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment_entity.dart';

/// Modelo de dados para Payment (Firestore)
class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.projectId,
    required super.name,
    required super.sourceType,
    required super.sourceId,
    required super.installmentNumber,
    required super.totalInstallments,
    required super.amount,
    required super.dueDate,
    required super.paid,
    super.paidAt,
    required super.createdAt,
  });

  /// Cria PaymentModel a partir de Map (Firestore)
  factory PaymentModel.fromMap(Map<String, dynamic> map, String id) {
    return PaymentModel(
      id: id,
      projectId: map['projectId'] as String,
      name: map['name'] as String,
      sourceType: map['sourceType'] as String,
      sourceId: map['sourceId'] as String? ?? '',
      installmentNumber: map['installmentNumber'] as int,
      totalInstallments: map['totalInstallments'] as int,
      amount: (map['amount'] as num).toDouble(),
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      paid: map['paid'] as bool,
      paidAt: map['paidAt'] != null
          ? (map['paidAt'] as Timestamp).toDate()
          : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Converte PaymentModel para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'name': name,
      'sourceType': sourceType,
      'sourceId': sourceId,
      'installmentNumber': installmentNumber,
      'totalInstallments': totalInstallments,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'paid': paid,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Cria PaymentModel a partir de PaymentEntity
  factory PaymentModel.fromEntity(PaymentEntity entity) {
    return PaymentModel(
      id: entity.id,
      projectId: entity.projectId,
      name: entity.name,
      sourceType: entity.sourceType,
      sourceId: entity.sourceId,
      installmentNumber: entity.installmentNumber,
      totalInstallments: entity.totalInstallments,
      amount: entity.amount,
      dueDate: entity.dueDate,
      paid: entity.paid,
      paidAt: entity.paidAt,
      createdAt: entity.createdAt,
    );
  }

  /// Converte para PaymentEntity
  PaymentEntity toEntity() {
    return PaymentEntity(
      id: id,
      projectId: projectId,
      name: name,
      sourceType: sourceType,
      sourceId: sourceId,
      installmentNumber: installmentNumber,
      totalInstallments: totalInstallments,
      amount: amount,
      dueDate: dueDate,
      paid: paid,
      paidAt: paidAt,
      createdAt: createdAt,
    );
  }

  @override
  PaymentModel copyWith({
    String? id,
    String? projectId,
    String? name,
    String? sourceType,
    String? sourceId,
    int? installmentNumber,
    int? totalInstallments,
    double? amount,
    DateTime? dueDate,
    bool? paid,
    DateTime? paidAt,
    DateTime? createdAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      paid: paid ?? this.paid,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Made with Bob
