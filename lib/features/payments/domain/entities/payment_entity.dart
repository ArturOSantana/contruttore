import 'package:equatable/equatable.dart';

/// Entidade de Pagamento (Parcela)
/// Gerada automaticamente por Suppliers e Purchases
/// NUNCA criada diretamente pelo usuário
class PaymentEntity extends Equatable {
  final String id;
  final String projectId;

  /// Nome da parcela (obrigatório)
  final String name;

  /// Tipo de origem: 'supplier' | 'purchase' | 'manual'
  final String sourceType;

  /// ID do documento de origem (supplierId ou purchaseId) - vazio se manual
  final String sourceId;

  /// Número da parcela (ex: 2 de 4)
  final int installmentNumber;

  /// Total de parcelas
  final int totalInstallments;

  /// Valor da parcela
  final double amount;

  /// Data de vencimento
  final DateTime dueDate;

  /// Se foi pago
  final bool paid;

  /// Data do pagamento (null se não pago)
  final DateTime? paidAt;

  /// Data de criação
  final DateTime createdAt;

  const PaymentEntity({
    required this.id,
    required this.projectId,
    required this.name,
    required this.sourceType,
    required this.sourceId,
    required this.installmentNumber,
    required this.totalInstallments,
    required this.amount,
    required this.dueDate,
    required this.paid,
    this.paidAt,
    required this.createdAt,
  });

  /// Retorna descrição da parcela (ex: "2/4")
  String get installmentDescription => '$installmentNumber/$totalInstallments';

  /// Verifica se está vencida
  bool get isOverdue => !paid && dueDate.isBefore(DateTime.now());

  /// Verifica se vence em breve (próximos 3 dias)
  bool get isDueSoon {
    if (paid) return false;
    final now = DateTime.now();
    final diff = dueDate.difference(now).inDays;
    return diff >= 0 && diff <= 3;
  }

  /// Verifica se vence este mês
  bool get isDueThisMonth {
    if (paid) return false;
    final now = DateTime.now();
    return dueDate.year == now.year && dueDate.month == now.month;
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    name,
    sourceType,
    sourceId,
    installmentNumber,
    totalInstallments,
    amount,
    dueDate,
    paid,
    paidAt,
    createdAt,
  ];

  PaymentEntity copyWith({
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
    return PaymentEntity(
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
