import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/supplier_entity.dart';

class SupplierModel extends SupplierEntity {
  const SupplierModel({
    required super.id,
    required super.projectId,
    required super.name,
    required super.type,
    required super.phone,
    super.email,
    super.cnpj,
    super.cpf,
    super.rating,
    super.notes,
    super.phaseId,
    required super.status,
    super.totalValue,
    super.installments = 1,
    super.firstPaymentDate,
    super.paymentMethods = const [],
    required super.createdAt,
  });

  factory SupplierModel.fromMap(Map<String, dynamic> map, String id) {
    return SupplierModel(
      id: id,
      projectId: map['projectId'] ?? '',
      name: map['name'] ?? '',
      type: SupplierType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => SupplierType.other,
      ),
      phone: map['phone'] ?? '',
      email: map['email'],
      cnpj: map['cnpj'],
      cpf: map['cpf'],
      rating: map['rating']?.toDouble(),
      notes: map['notes'],
      phaseId: map['phaseId'],
      status: SupplierStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SupplierStatus.active,
      ),
      totalValue: map['totalValue']?.toDouble(),
      installments: map['installments'] ?? 1,
      firstPaymentDate: map['firstPaymentDate'] != null
          ? (map['firstPaymentDate'] as Timestamp).toDate()
          : null,
      paymentMethods: map['paymentMethods'] != null
          ? (map['paymentMethods'] as List)
                .map(
                  (e) => PaymentMethod.values.firstWhere(
                    (pm) => pm.name == e,
                    orElse: () => PaymentMethod.cash,
                  ),
                )
                .toList()
          : [],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  factory SupplierModel.fromEntity(SupplierEntity entity) {
    return SupplierModel(
      id: entity.id,
      projectId: entity.projectId,
      name: entity.name,
      type: entity.type,
      phone: entity.phone,
      email: entity.email,
      cnpj: entity.cnpj,
      cpf: entity.cpf,
      rating: entity.rating,
      notes: entity.notes,
      phaseId: entity.phaseId,
      status: entity.status,
      totalValue: entity.totalValue,
      installments: entity.installments,
      firstPaymentDate: entity.firstPaymentDate,
      paymentMethods: entity.paymentMethods,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'name': name,
      'type': type.name,
      'phone': phone,
      'email': email,
      'cnpj': cnpj,
      'cpf': cpf,
      'rating': rating,
      'notes': notes,
      'phaseId': phaseId,
      'status': status.name,
      'totalValue': totalValue,
      'installments': installments,
      'firstPaymentDate': firstPaymentDate != null
          ? Timestamp.fromDate(firstPaymentDate!)
          : null,
      'paymentMethods': paymentMethods.map((e) => e.name).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

// Made with Bob
