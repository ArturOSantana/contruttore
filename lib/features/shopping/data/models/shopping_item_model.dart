import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/shopping_item_entity.dart';

class ShoppingItemModel extends ShoppingItemEntity {
  const ShoppingItemModel({
    required super.id,
    required super.projectId,
    super.phaseId,
    required super.name,
    required super.category,
    super.estimatedPrice,
    super.actualPrice,
    required super.quantity,
    required super.unit,
    required super.isPurchased,
    super.store,
    super.notes,
    super.purchaseDate,
    super.wishlistItemId,
    super.expenseTransactionId,
    required super.createdAt,
    super.installments = 1,
    super.firstPaymentDate,
  });

  factory ShoppingItemModel.fromMap(Map<String, dynamic> map, String id) {
    // Helper para converter data (aceita Timestamp ou String)
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return ShoppingItemModel(
      id: id,
      projectId: map['projectId'] ?? '',
      phaseId: map['phaseId'],
      name: map['name'] ?? '',
      category: ShoppingCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => ShoppingCategory.other,
      ),
      estimatedPrice: map['estimatedPrice']?.toDouble(),
      actualPrice: map['actualPrice']?.toDouble(),
      quantity: (map['quantity'] ?? 1).toDouble(),
      unit: map['unit'] ?? 'un',
      isPurchased: map['isPurchased'] ?? false,
      store: map['store'],
      notes: map['notes'],
      purchaseDate: parseDate(map['purchaseDate']),
      wishlistItemId: map['wishlistItemId'],
      expenseTransactionId: map['expenseTransactionId'],
      createdAt: parseDate(map['createdAt']) ?? DateTime.now(),
      installments: map['installments'] ?? 1,
      firstPaymentDate: parseDate(map['firstPaymentDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'phaseId': phaseId,
      'name': name,
      'category': category.name,
      'estimatedPrice': estimatedPrice,
      'actualPrice': actualPrice,
      'quantity': quantity,
      'unit': unit,
      'isPurchased': isPurchased,
      'store': store,
      'notes': notes,
      'purchaseDate': purchaseDate != null
          ? Timestamp.fromDate(purchaseDate!)
          : null,
      'wishlistItemId': wishlistItemId,
      'expenseTransactionId': expenseTransactionId,
      'createdAt': Timestamp.fromDate(createdAt),
      'installments': installments,
      'firstPaymentDate': firstPaymentDate != null
          ? Timestamp.fromDate(firstPaymentDate!)
          : null,
    };
  }

  factory ShoppingItemModel.fromEntity(ShoppingItemEntity entity) {
    return ShoppingItemModel(
      id: entity.id,
      projectId: entity.projectId,
      phaseId: entity.phaseId,
      name: entity.name,
      category: entity.category,
      estimatedPrice: entity.estimatedPrice,
      actualPrice: entity.actualPrice,
      quantity: entity.quantity,
      unit: entity.unit,
      isPurchased: entity.isPurchased,
      store: entity.store,
      notes: entity.notes,
      purchaseDate: entity.purchaseDate,
      wishlistItemId: entity.wishlistItemId,
      expenseTransactionId: entity.expenseTransactionId,
      createdAt: entity.createdAt,
      installments: entity.installments,
      firstPaymentDate: entity.firstPaymentDate,
    );
  }
}

// Made with Bob
