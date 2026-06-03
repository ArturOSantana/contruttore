import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/installment_entity.dart';

class InstallmentModel extends InstallmentEntity {
  const InstallmentModel({
    required super.id,
    required super.projectId,
    required super.supplierId,
    required super.supplierName,
    required super.serviceDescription,
    super.phaseId,
    required super.totalValue,
    required super.totalInstallments,
    required super.contractDate,
    required super.status,
    required super.payments,
    required super.createdAt,
  });

  factory InstallmentModel.fromMap(Map<String, dynamic> map, String id) {
    return InstallmentModel(
      id: id,
      projectId: map['projectId'] ?? '',
      supplierId: map['supplierId'] ?? '',
      supplierName: map['supplierName'] ?? '',
      serviceDescription: map['serviceDescription'] ?? '',
      phaseId: map['phaseId'],
      totalValue: (map['totalValue'] ?? 0).toDouble(),
      totalInstallments: map['totalInstallments'] ?? 0,
      contractDate: (map['contractDate'] as Timestamp).toDate(),
      status: InstallmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => InstallmentStatus.active,
      ),
      payments:
          (map['payments'] as List<dynamic>?)
              ?.map((p) => PaymentModel.fromMap(p))
              .toList() ??
          [],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'serviceDescription': serviceDescription,
      'phaseId': phaseId,
      'totalValue': totalValue,
      'totalInstallments': totalInstallments,
      'contractDate': Timestamp.fromDate(contractDate),
      'status': status.name,
      'payments': payments.map((p) => (p as PaymentModel).toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.number,
    required super.amount,
    required super.dueDate,
    required super.isPaid,
    super.paidAt,
    super.paidAmount,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] ?? '',
      number: map['number'] ?? 0,
      amount: (map['amount'] ?? 0).toDouble(),
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      isPaid: map['isPaid'] ?? false,
      paidAt: map['paidAt'] != null
          ? (map['paidAt'] as Timestamp).toDate()
          : null,
      paidAmount: map['paidAmount']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'isPaid': isPaid,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'paidAmount': paidAmount,
    };
  }
}

// Made with Bob
