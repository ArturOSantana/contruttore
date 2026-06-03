import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/quote_entity.dart';
import '../../domain/entities/supplier_entity.dart';

class QuoteModel extends QuoteEntity {
  const QuoteModel({
    required super.id,
    required super.projectId,
    required super.supplierId,
    required super.description,
    required super.totalValue,
    required super.validUntil,
    required super.status,
    required super.items,
    super.notes,
    required super.deliveryDays,
    super.installments = 1,
    super.paymentMethods = const [],
    super.downPayment = 0,
    super.warrantyMonths,
    super.shippingCost,
    required super.createdAt,
  });

  factory QuoteModel.fromMap(Map<String, dynamic> map, String id) {
    return QuoteModel(
      id: id,
      projectId: map['projectId'] ?? '',
      supplierId: map['supplierId'] ?? '',
      description: map['description'] ?? '',
      totalValue: (map['totalValue'] ?? 0).toDouble(),
      validUntil: (map['validUntil'] as Timestamp).toDate(),
      status: QuoteStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => QuoteStatus.pending,
      ),
      items:
          (map['items'] as List<dynamic>?)
              ?.map((item) => QuoteItemModel.fromMap(item))
              .toList() ??
          [],
      notes: map['notes'],
      deliveryDays: map['deliveryDays'] ?? 30,
      installments: map['installments'] ?? 1,
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
      downPayment: (map['downPayment'] ?? 0).toDouble(),
      warrantyMonths: map['warrantyMonths'],
      shippingCost: map['shippingCost']?.toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  factory QuoteModel.fromEntity(QuoteEntity entity) {
    return QuoteModel(
      id: entity.id,
      projectId: entity.projectId,
      supplierId: entity.supplierId,
      description: entity.description,
      totalValue: entity.totalValue,
      validUntil: entity.validUntil,
      status: entity.status,
      items: entity.items
          .map((item) => QuoteItemModel.fromEntity(item))
          .toList(),
      notes: entity.notes,
      deliveryDays: entity.deliveryDays,
      installments: entity.installments,
      paymentMethods: entity.paymentMethods,
      downPayment: entity.downPayment,
      warrantyMonths: entity.warrantyMonths,
      shippingCost: entity.shippingCost,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'supplierId': supplierId,
      'description': description,
      'totalValue': totalValue,
      'validUntil': Timestamp.fromDate(validUntil),
      'status': status.name,
      'items': items.map((item) => (item as QuoteItemModel).toMap()).toList(),
      'notes': notes,
      'deliveryDays': deliveryDays,
      'installments': installments,
      'paymentMethods': paymentMethods.map((e) => e.name).toList(),
      'downPayment': downPayment,
      'warrantyMonths': warrantyMonths,
      'shippingCost': shippingCost,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class QuoteItemModel extends QuoteItemEntity {
  const QuoteItemModel({
    required super.description,
    required super.quantity,
    required super.unit,
    required super.unitPrice,
  });

  factory QuoteItemModel.fromMap(Map<String, dynamic> map) {
    return QuoteItemModel(
      description: map['description'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      unit: map['unit'] ?? '',
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
    );
  }

  factory QuoteItemModel.fromEntity(QuoteItemEntity entity) {
    return QuoteItemModel(
      description: entity.description,
      quantity: entity.quantity,
      unit: entity.unit,
      unitPrice: entity.unitPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
    };
  }
}

// Made with Bob
