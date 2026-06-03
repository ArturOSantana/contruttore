import 'package:equatable/equatable.dart';

class ShoppingItemEntity extends Equatable {
  final String id;
  final String projectId;
  final String? phaseId;
  final String name;
  final ShoppingCategory category;
  final double? estimatedPrice;
  final double? actualPrice;
  final double quantity;
  final String unit;
  final bool isPurchased;
  final String? store;
  final String? notes;
  final DateTime? purchaseDate;
  final String? wishlistItemId;
  final String?
  expenseTransactionId; // ID da transação de despesa (para reversal)
  final DateTime createdAt;

  // Campos para parcelamento (quando compra é parcelada)
  final int installments; // Número de parcelas (padrão: 1 = à vista)
  final DateTime? firstPaymentDate; // Data da primeira parcela

  const ShoppingItemEntity({
    required this.id,
    required this.projectId,
    this.phaseId,
    required this.name,
    required this.category,
    this.estimatedPrice,
    this.actualPrice,
    required this.quantity,
    required this.unit,
    required this.isPurchased,
    this.store,
    this.notes,
    this.purchaseDate,
    this.wishlistItemId,
    this.expenseTransactionId,
    required this.createdAt,
    this.installments = 1,
    this.firstPaymentDate,
  });

  double get totalEstimated => (estimatedPrice ?? 0) * quantity;
  double get totalActual => (actualPrice ?? 0) * quantity;

  /// Verifica se a compra é parcelada
  bool get isInstallment => installments > 1;

  ShoppingItemEntity copyWith({
    String? id,
    String? projectId,
    String? phaseId,
    String? name,
    ShoppingCategory? category,
    double? estimatedPrice,
    double? actualPrice,
    double? quantity,
    String? unit,
    bool? isPurchased,
    String? store,
    String? notes,
    DateTime? purchaseDate,
    String? wishlistItemId,
    String? expenseTransactionId,
    DateTime? createdAt,
    int? installments,
    DateTime? firstPaymentDate,
  }) {
    return ShoppingItemEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      phaseId: phaseId ?? this.phaseId,
      name: name ?? this.name,
      category: category ?? this.category,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      actualPrice: actualPrice ?? this.actualPrice,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isPurchased: isPurchased ?? this.isPurchased,
      store: store ?? this.store,
      notes: notes ?? this.notes,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      wishlistItemId: wishlistItemId ?? this.wishlistItemId,
      expenseTransactionId: expenseTransactionId ?? this.expenseTransactionId,
      createdAt: createdAt ?? this.createdAt,
      installments: installments ?? this.installments,
      firstPaymentDate: firstPaymentDate ?? this.firstPaymentDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    phaseId,
    name,
    category,
    estimatedPrice,
    actualPrice,
    quantity,
    unit,
    isPurchased,
    store,
    notes,
    purchaseDate,
    wishlistItemId,
    expenseTransactionId,
    createdAt,
    installments,
    firstPaymentDate,
  ];
}

enum ShoppingCategory {
  electrical,
  plumbing,
  coating,
  flooring,
  painting,
  fixtures,
  metals,
  frames,
  carpentry,
  furniture,
  decoration,
  other,
}

extension ShoppingCategoryExtension on ShoppingCategory {
  String get displayName {
    switch (this) {
      case ShoppingCategory.electrical:
        return 'Elétrica';
      case ShoppingCategory.plumbing:
        return 'Hidráulica';
      case ShoppingCategory.coating:
        return 'Revestimentos';
      case ShoppingCategory.flooring:
        return 'Pisos';
      case ShoppingCategory.painting:
        return 'Pintura';
      case ShoppingCategory.fixtures:
        return 'Louças';
      case ShoppingCategory.metals:
        return 'Metais';
      case ShoppingCategory.frames:
        return 'Esquadrias';
      case ShoppingCategory.carpentry:
        return 'Marcenaria';
      case ShoppingCategory.furniture:
        return 'Mobiliário';
      case ShoppingCategory.decoration:
        return 'Decoração';
      case ShoppingCategory.other:
        return 'Outros';
    }
  }
}

// Made with Bob
