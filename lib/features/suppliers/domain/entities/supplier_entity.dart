import 'package:equatable/equatable.dart';

class SupplierEntity extends Equatable {
  final String id;
  final String projectId;
  final String name;
  final SupplierType type;
  final String phone;
  final String? email;
  final String? cnpj;
  final String? cpf;
  final double? rating;
  final String? notes;
  final String? phaseId;
  final SupplierStatus status;

  /// Valor total do contrato (null = em cotação, não entra no financeiro)
  final double? totalValue;

  /// Número de parcelas (padrão: 1 = pagamento único)
  final int installments;

  /// Data da primeira parcela
  final DateTime? firstPaymentDate;

  /// Formas de pagamento aceitas
  final List<PaymentMethod> paymentMethods;

  final DateTime createdAt;

  const SupplierEntity({
    required this.id,
    required this.projectId,
    required this.name,
    required this.type,
    required this.phone,
    this.email,
    this.cnpj,
    this.cpf,
    this.rating,
    this.notes,
    this.phaseId,
    required this.status,
    this.totalValue,
    this.installments = 1,
    this.firstPaymentDate,
    this.paymentMethods = const [],
    required this.createdAt,
  });

  SupplierEntity copyWith({
    String? id,
    String? projectId,
    String? name,
    SupplierType? type,
    String? phone,
    String? email,
    String? cnpj,
    String? cpf,
    double? rating,
    String? notes,
    String? phaseId,
    SupplierStatus? status,
    double? totalValue,
    int? installments,
    DateTime? firstPaymentDate,
    List<PaymentMethod>? paymentMethods,
    DateTime? createdAt,
  }) {
    return SupplierEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      cnpj: cnpj ?? this.cnpj,
      cpf: cpf ?? this.cpf,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      phaseId: phaseId ?? this.phaseId,
      status: status ?? this.status,
      totalValue: totalValue ?? this.totalValue,
      installments: installments ?? this.installments,
      firstPaymentDate: firstPaymentDate ?? this.firstPaymentDate,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    name,
    type,
    phone,
    email,
    cnpj,
    cpf,
    rating,
    notes,
    phaseId,
    status,
    totalValue,
    installments,
    firstPaymentDate,
    paymentMethods,
    createdAt,
  ];
}

enum SupplierType {
  engineer,
  architect,
  interiorDesigner,
  constructionManager,
  generalContractor,
  mason,
  electrician,
  plumber,
  painter,
  plasterer,
  carpenter,
  marbleWorker,
  metalWorker,
  materialsStore,
  furnitureStore,
  other,
}

enum SupplierStatus { active, completed, problem }

extension SupplierTypeExtension on SupplierType {
  String get displayName {
    switch (this) {
      case SupplierType.engineer:
        return 'Engenheiro';
      case SupplierType.architect:
        return 'Arquiteto';
      case SupplierType.interiorDesigner:
        return 'Designer de Interiores';
      case SupplierType.constructionManager:
        return 'Mestre de Obras';
      case SupplierType.generalContractor:
        return 'Empreiteiro Geral';
      case SupplierType.mason:
        return 'Pedreiro';
      case SupplierType.electrician:
        return 'Eletricista';
      case SupplierType.plumber:
        return 'Encanador';
      case SupplierType.painter:
        return 'Pintor';
      case SupplierType.plasterer:
        return 'Gesseiro';
      case SupplierType.carpenter:
        return 'Marceneiro';
      case SupplierType.marbleWorker:
        return 'Marmorista';
      case SupplierType.metalWorker:
        return 'Serralheiro';
      case SupplierType.materialsStore:
        return 'Loja de Materiais';
      case SupplierType.furnitureStore:
        return 'Loja de Móveis';
      case SupplierType.other:
        return 'Outro';
    }
  }

  String get icon {
    switch (this) {
      case SupplierType.engineer:
        return '👷';
      case SupplierType.architect:
        return '📐';
      case SupplierType.interiorDesigner:
        return '🎨';
      case SupplierType.constructionManager:
        return '👨‍🔧';
      case SupplierType.generalContractor:
        return '🏗️';
      case SupplierType.mason:
        return '🧱';
      case SupplierType.electrician:
        return '⚡';
      case SupplierType.plumber:
        return '🔧';
      case SupplierType.painter:
        return '🎨';
      case SupplierType.plasterer:
        return '🏠';
      case SupplierType.carpenter:
        return '🪚';
      case SupplierType.marbleWorker:
        return '💎';
      case SupplierType.metalWorker:
        return '🔩';
      case SupplierType.materialsStore:
        return '🏪';
      case SupplierType.furnitureStore:
        return '🛋️';
      case SupplierType.other:
        return '👤';
    }
  }
}

extension SupplierStatusExtension on SupplierStatus {
  String get displayName {
    switch (this) {
      case SupplierStatus.active:
        return 'Ativo';
      case SupplierStatus.completed:
        return 'Concluído';
      case SupplierStatus.problem:
        return 'Problema';
    }
  }

  String get color {
    switch (this) {
      case SupplierStatus.active:
        return 'green';
      case SupplierStatus.completed:
        return 'blue';
      case SupplierStatus.problem:
        return 'red';
    }
  }
}

/// Formas de pagamento aceitas pelo fornecedor
enum PaymentMethod {
  cash,
  debit,
  credit,
  pix,
  bankTransfer,
  check,
  installmentPlan,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Dinheiro';
      case PaymentMethod.debit:
        return 'Débito';
      case PaymentMethod.credit:
        return 'Crédito';
      case PaymentMethod.pix:
        return 'PIX';
      case PaymentMethod.bankTransfer:
        return 'Transferência';
      case PaymentMethod.check:
        return 'Cheque';
      case PaymentMethod.installmentPlan:
        return 'Parcelamento';
    }
  }

  String get icon {
    switch (this) {
      case PaymentMethod.cash:
        return '💵';
      case PaymentMethod.debit:
        return '💳';
      case PaymentMethod.credit:
        return '💳';
      case PaymentMethod.pix:
        return '📱';
      case PaymentMethod.bankTransfer:
        return '🏦';
      case PaymentMethod.check:
        return '📝';
      case PaymentMethod.installmentPlan:
        return '📊';
    }
  }
}

// Made with Bob
