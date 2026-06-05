import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:contruttore/core/constants/app_icons.dart';

class DocumentEntity extends Equatable {
  final String id;
  final String projectId;
  final DocumentType type;
  final String name;
  final String fileUrl;
  final DateTime? expiryDate;
  final String? notes;
  final DateTime createdAt;

  const DocumentEntity({
    required this.id,
    required this.projectId,
    required this.type,
    required this.name,
    required this.fileUrl,
    this.expiryDate,
    this.notes,
    required this.createdAt,
  });

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry >= 0;
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        type,
        name,
        fileUrl,
        expiryDate,
        notes,
        createdAt,
      ];
}

enum DocumentType { contract, art, alvara, floorPlan, memorial, other }

extension DocumentTypeExtension on DocumentType {
  String get displayName {
    switch (this) {
      case DocumentType.contract:
        return 'Contrato de Compra e Venda';
      case DocumentType.art:
        return 'ART do Engenheiro';
      case DocumentType.alvara:
        return 'Alvará de Construção';
      case DocumentType.floorPlan:
        return 'Planta Baixa';
      case DocumentType.memorial:
        return 'Memorial Descritivo';
      case DocumentType.other:
        return 'Outros';
    }
  }

  IconData get icon {
    switch (this) {
      case DocumentType.contract:
        return AppIcons.documentContract;
      case DocumentType.art:
        return AppIcons.art;
      case DocumentType.alvara:
        return AppIcons.alvara;
      case DocumentType.floorPlan:
        return AppIcons.floorPlan;
      case DocumentType.memorial:
        return AppIcons.memorial;
      case DocumentType.other:
        return AppIcons.otherDocument;
    }
  }

  bool get requiresExpiryDate {
    return this == DocumentType.art || this == DocumentType.alvara;
  }
}

// Made with Bob
