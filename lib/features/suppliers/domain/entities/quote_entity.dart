import 'package:equatable/equatable.dart';
import '../../../suppliers/domain/entities/supplier_entity.dart';

class QuoteEntity extends Equatable {
  final String id;
  final String projectId;
  final String supplierId;
  final String description;
  final double totalValue;
  final DateTime validUntil;
  final QuoteStatus status;
  final List<QuoteItemEntity> items;
  final String? notes;

  /// Prazo de entrega/execução (em dias)
  final int deliveryDays;

  /// Número de parcelas (1 = à vista)
  final int installments;

  /// Formas de pagamento aceitas
  final List<PaymentMethod> paymentMethods;

  /// Valor de entrada (0 = sem entrada)
  final double downPayment;

  /// Garantia em meses (null = sem garantia)
  final int? warrantyMonths;

  /// Valor do frete (null = frete incluso ou não aplicável)
  final double? shippingCost;

  final DateTime createdAt;

  const QuoteEntity({
    required this.id,
    required this.projectId,
    required this.supplierId,
    required this.description,
    required this.totalValue,
    required this.validUntil,
    required this.status,
    required this.items,
    this.notes,
    required this.deliveryDays,
    this.installments = 1,
    this.paymentMethods = const [],
    this.downPayment = 0,
    this.warrantyMonths,
    this.shippingCost,
    required this.createdAt,
  });

  bool get isExpired => DateTime.now().isAfter(validUntil);

  double get installmentValue => totalValue / installments;

  double get financedAmount => totalValue - downPayment;

  double get installmentValueAfterDown => financedAmount / installments;

  QuoteEntity copyWith({
    String? id,
    String? projectId,
    String? supplierId,
    String? description,
    double? totalValue,
    DateTime? validUntil,
    QuoteStatus? status,
    List<QuoteItemEntity>? items,
    String? notes,
    int? deliveryDays,
    int? installments,
    List<PaymentMethod>? paymentMethods,
    double? downPayment,
    int? warrantyMonths,
    double? shippingCost,
    DateTime? createdAt,
  }) {
    return QuoteEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      supplierId: supplierId ?? this.supplierId,
      description: description ?? this.description,
      totalValue: totalValue ?? this.totalValue,
      validUntil: validUntil ?? this.validUntil,
      status: status ?? this.status,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      deliveryDays: deliveryDays ?? this.deliveryDays,
      installments: installments ?? this.installments,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      downPayment: downPayment ?? this.downPayment,
      warrantyMonths: warrantyMonths ?? this.warrantyMonths,
      shippingCost: shippingCost ?? this.shippingCost,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    supplierId,
    description,
    totalValue,
    validUntil,
    status,
    items,
    notes,
    deliveryDays,
    installments,
    paymentMethods,
    downPayment,
    warrantyMonths,
    shippingCost,
    createdAt,
  ];
}

enum QuoteStatus { pending, accepted, rejected, expired }

extension QuoteStatusExtension on QuoteStatus {
  String get displayName {
    switch (this) {
      case QuoteStatus.pending:
        return 'Pendente';
      case QuoteStatus.accepted:
        return 'Aceito';
      case QuoteStatus.rejected:
        return 'Rejeitado';
      case QuoteStatus.expired:
        return 'Expirado';
    }
  }

  String get color {
    switch (this) {
      case QuoteStatus.pending:
        return 'orange';
      case QuoteStatus.accepted:
        return 'green';
      case QuoteStatus.rejected:
        return 'red';
      case QuoteStatus.expired:
        return 'grey';
    }
  }
}

class QuoteItemEntity extends Equatable {
  final String description;
  final double quantity;
  final String unit;
  final double unitPrice;

  const QuoteItemEntity({
    required this.description,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;

  QuoteItemEntity copyWith({
    String? description,
    double? quantity,
    String? unit,
    double? unitPrice,
  }) {
    return QuoteItemEntity(
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  @override
  List<Object?> get props => [description, quantity, unit, unitPrice];
}

// Made with Bob
