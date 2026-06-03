import 'package:equatable/equatable.dart';

/// Entidade que representa toda movimentação financeira do projeto
///
/// Cada transaction tem:
/// - Tipo (expense, commitment, estimate, reversal)
/// - Origem (manual, installment, shopping, contract)
/// - Rastreabilidade completa (supplierId, installmentId, etc)
class TransactionEntity extends Equatable {
  final String id;
  final String projectId;
  final TransactionType type;
  final TransactionSource source;

  // Valores
  final double amount; // SEMPRE positivo
  final double signedAmount; // Negativo se reversal
  final DateTime date;
  final String description;

  // Rastreabilidade (todos opcionais)
  final String? supplierId;
  final String? installmentId;
  final String? paymentId;
  final String? shoppingItemId;
  final String? relatedTransactionId; // Para reversals e fulfillments
  final String? phaseId;
  final String? categoryId;

  // Comprovação
  final String? invoicePhotoUrl;
  final String? notes;

  // Status (para estimates)
  final TransactionStatus status;

  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.projectId,
    required this.type,
    required this.source,
    required this.amount,
    required this.signedAmount,
    required this.date,
    required this.description,
    this.supplierId,
    this.installmentId,
    this.paymentId,
    this.shoppingItemId,
    this.relatedTransactionId,
    this.phaseId,
    this.categoryId,
    this.invoicePhotoUrl,
    this.notes,
    this.status = TransactionStatus.active,
    required this.createdAt,
  });

  // Helpers
  bool get isReversal => type == TransactionType.reversal;
  bool get isActive => status == TransactionStatus.active;
  bool get isFulfilled => status == TransactionStatus.fulfilled;
  bool get isCancelled => status == TransactionStatus.cancelled;

  @override
  List<Object?> get props => [
    id,
    projectId,
    type,
    source,
    amount,
    signedAmount,
    date,
    description,
    supplierId,
    installmentId,
    paymentId,
    shoppingItemId,
    relatedTransactionId,
    phaseId,
    categoryId,
    invoicePhotoUrl,
    notes,
    status,
    createdAt,
  ];
}

/// Tipo da transação
enum TransactionType {
  expense, // Gasto confirmado - dinheiro já saiu
  commitment, // Compromisso futuro - vai sair
  estimate, // Estimativa - pode mudar
  reversal, // Estorno/cancelamento
}

/// Origem da transação
enum TransactionSource {
  manual, // Criado manualmente pelo usuário
  installment, // Gerado ao pagar parcela
  installmentReversal, // Cancelamento de parcela
  shopping, // Gerado ao comprar item
  shoppingReversal, // Devolução de compra
  contract, // Gerado ao aceitar orçamento
  contractCancel, // Cancelamento de contrato
}

/// Status da transação
enum TransactionStatus {
  active, // Ativo
  fulfilled, // Cumprido (para estimates)
  cancelled, // Cancelado
}

// Extensions para display names
extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.expense:
        return 'Gasto';
      case TransactionType.commitment:
        return 'Compromisso';
      case TransactionType.estimate:
        return 'Estimativa';
      case TransactionType.reversal:
        return 'Estorno';
    }
  }

  String get icon {
    switch (this) {
      case TransactionType.expense:
        return '💰';
      case TransactionType.commitment:
        return '📋';
      case TransactionType.estimate:
        return '📊';
      case TransactionType.reversal:
        return '↩️';
    }
  }
}

extension TransactionSourceExtension on TransactionSource {
  String get displayName {
    switch (this) {
      case TransactionSource.manual:
        return 'Manual';
      case TransactionSource.installment:
        return 'Parcela';
      case TransactionSource.installmentReversal:
        return 'Cancelamento de Parcela';
      case TransactionSource.shopping:
        return 'Compra';
      case TransactionSource.shoppingReversal:
        return 'Devolução';
      case TransactionSource.contract:
        return 'Contrato';
      case TransactionSource.contractCancel:
        return 'Cancelamento de Contrato';
    }
  }

  String get icon {
    switch (this) {
      case TransactionSource.manual:
        return '✍️';
      case TransactionSource.installment:
        return '👷';
      case TransactionSource.installmentReversal:
        return '↩️';
      case TransactionSource.shopping:
        return '🛒';
      case TransactionSource.shoppingReversal:
        return '↩️';
      case TransactionSource.contract:
        return '📄';
      case TransactionSource.contractCancel:
        return '❌';
    }
  }
}

extension TransactionStatusExtension on TransactionStatus {
  String get displayName {
    switch (this) {
      case TransactionStatus.active:
        return 'Ativo';
      case TransactionStatus.fulfilled:
        return 'Cumprido';
      case TransactionStatus.cancelled:
        return 'Cancelado';
    }
  }
}

// Made with Bob
