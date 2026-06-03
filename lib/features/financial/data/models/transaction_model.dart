import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction_entity.dart';

/// Model para serialização/deserialização do Firestore
class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.projectId,
    required super.type,
    required super.source,
    required super.amount,
    required super.signedAmount,
    required super.date,
    required super.description,
    super.supplierId,
    super.installmentId,
    super.paymentId,
    super.shoppingItemId,
    super.relatedTransactionId,
    super.phaseId,
    super.categoryId,
    super.invoicePhotoUrl,
    super.notes,
    super.status,
    required super.createdAt,
  });

  /// Converte de Map (Firestore) para Model
  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel(
      id: id,
      projectId: map['projectId'] as String,
      type: _typeFromString(map['type'] as String),
      source: _sourceFromString(map['source'] as String),
      amount: (map['amount'] as num).toDouble(),
      signedAmount: (map['signedAmount'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'] as String,
      supplierId: map['supplierId'] as String?,
      installmentId: map['installmentId'] as String?,
      paymentId: map['paymentId'] as String?,
      shoppingItemId: map['shoppingItemId'] as String?,
      relatedTransactionId: map['relatedTransactionId'] as String?,
      phaseId: map['phaseId'] as String?,
      categoryId: map['categoryId'] as String?,
      invoicePhotoUrl: map['invoicePhotoUrl'] as String?,
      notes: map['notes'] as String?,
      status: _statusFromString(map['status'] as String? ?? 'active'),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Converte de Entity para Model
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      projectId: entity.projectId,
      type: entity.type,
      source: entity.source,
      amount: entity.amount,
      signedAmount: entity.signedAmount,
      date: entity.date,
      description: entity.description,
      supplierId: entity.supplierId,
      installmentId: entity.installmentId,
      paymentId: entity.paymentId,
      shoppingItemId: entity.shoppingItemId,
      relatedTransactionId: entity.relatedTransactionId,
      phaseId: entity.phaseId,
      categoryId: entity.categoryId,
      invoicePhotoUrl: entity.invoicePhotoUrl,
      notes: entity.notes,
      status: entity.status,
      createdAt: entity.createdAt,
    );
  }

  /// Converte para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'type': _typeToString(type),
      'source': _sourceToString(source),
      'amount': amount,
      'signedAmount': signedAmount,
      'date': Timestamp.fromDate(date),
      'description': description,
      'supplierId': supplierId,
      'installmentId': installmentId,
      'paymentId': paymentId,
      'shoppingItemId': shoppingItemId,
      'relatedTransactionId': relatedTransactionId,
      'phaseId': phaseId,
      'categoryId': categoryId,
      'invoicePhotoUrl': invoicePhotoUrl,
      'notes': notes,
      'status': _statusToString(status),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Conversores de enum para string
  static String _typeToString(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return 'expense';
      case TransactionType.commitment:
        return 'commitment';
      case TransactionType.estimate:
        return 'estimate';
      case TransactionType.reversal:
        return 'reversal';
    }
  }

  static TransactionType _typeFromString(String type) {
    switch (type) {
      case 'expense':
        return TransactionType.expense;
      case 'commitment':
        return TransactionType.commitment;
      case 'estimate':
        return TransactionType.estimate;
      case 'reversal':
        return TransactionType.reversal;
      default:
        throw ArgumentError('Invalid transaction type: $type');
    }
  }

  static String _sourceToString(TransactionSource source) {
    switch (source) {
      case TransactionSource.manual:
        return 'manual';
      case TransactionSource.installment:
        return 'installment';
      case TransactionSource.installmentReversal:
        return 'installment_reversal';
      case TransactionSource.shopping:
        return 'shopping';
      case TransactionSource.shoppingReversal:
        return 'shopping_reversal';
      case TransactionSource.contract:
        return 'contract';
      case TransactionSource.contractCancel:
        return 'contract_cancel';
    }
  }

  static TransactionSource _sourceFromString(String source) {
    switch (source) {
      case 'manual':
        return TransactionSource.manual;
      case 'installment':
        return TransactionSource.installment;
      case 'installment_reversal':
        return TransactionSource.installmentReversal;
      case 'shopping':
        return TransactionSource.shopping;
      case 'shopping_reversal':
        return TransactionSource.shoppingReversal;
      case 'contract':
        return TransactionSource.contract;
      case 'contract_cancel':
        return TransactionSource.contractCancel;
      default:
        throw ArgumentError('Invalid transaction source: $source');
    }
  }

  static String _statusToString(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.active:
        return 'active';
      case TransactionStatus.fulfilled:
        return 'fulfilled';
      case TransactionStatus.cancelled:
        return 'cancelled';
    }
  }

  static TransactionStatus _statusFromString(String status) {
    switch (status) {
      case 'active':
        return TransactionStatus.active;
      case 'fulfilled':
        return TransactionStatus.fulfilled;
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.active;
    }
  }
}

// Made with Bob
