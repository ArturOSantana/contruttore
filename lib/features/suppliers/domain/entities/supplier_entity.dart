import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:contruttore/core/constants/app_icons.dart';

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

  IconData get icon {
    switch (this) {
      case SupplierType.engineer:
        return AppIcons.engineer;
      case SupplierType.architect:
        return AppIcons.architect;
      case SupplierType.interiorDesigner:
        return AppIcons.interiorDesigner;
      case SupplierType.constructionManager:
        return AppIcons.constructionManager;
      case SupplierType.generalContractor:
        return AppIcons.generalContractor;
      case SupplierType.mason:
        return AppIcons.mason;
      case SupplierType.electrician:
        return AppIcons.electrician;
      case SupplierType.plumber:
        return AppIcons.plumber;
      case SupplierType.painter:
        return AppIcons.painter;
      case SupplierType.plasterer:
        return AppIcons.plasterer;
      case SupplierType.carpenter:
        return AppIcons.carpenter;
      case SupplierType.marbleWorker:
        return AppIcons.marbleWorker;
      case SupplierType.metalWorker:
        return AppIcons.metalWorker;
      case SupplierType.materialsStore:
        return AppIcons.materialsStore;
      case SupplierType.furnitureStore:
        return AppIcons.furnitureStore;
      case SupplierType.other:
        return AppIcons.otherSupplier;
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

  IconData get icon {
    switch (this) {
      case PaymentMethod.cash:
        return AppIcons.cash;
      case PaymentMethod.debit:
        return AppIcons.debit;
      case PaymentMethod.credit:
        return AppIcons.credit;
      case PaymentMethod.pix:
        return AppIcons.pix;
      case PaymentMethod.bankTransfer:
        return AppIcons.bankTransfer;
      case PaymentMethod.check:
        return AppIcons.check;
      case PaymentMethod.installmentPlan:
        return AppIcons.installmentPlan;
    }
  }
}

// Made with Bob
