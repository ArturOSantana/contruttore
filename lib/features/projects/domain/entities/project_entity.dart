import 'package:equatable/equatable.dart';

class ProjectEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String address;
  final String constructorName;
  final double area;
  final DateTime deliveryDate;
  final DateTime contractDate;
  final double? totalBudget;
  final double contingencyPercent;
  final double? propertyValue;
  final String
      currentSituation; // 'just_signed' | 'construction' | 'keys_received' | 'renovation'
  final DateTime? plannedMoveInDate; // Data planejada para mudança

  // Dados do onboarding conversacional
  final String?
      mainPriority; // save_money, finish_fast, avoid_problems, best_finish, control_costs, organize_everything
  final List<String>
      criticalItems; // ar_conditioner, wired_internet, dishwasher, etc

  // Tipo de imóvel para checklist dinâmico
  final PropertyType propertyType; // house, apartment, commercial

  final DateTime createdAt;

  const ProjectEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.address,
    required this.constructorName,
    required this.area,
    required this.deliveryDate,
    required this.contractDate,
    this.totalBudget,
    required this.contingencyPercent,
    this.propertyValue,
    required this.currentSituation,
    this.plannedMoveInDate,
    this.mainPriority,
    this.criticalItems = const [],
    this.propertyType = PropertyType.house, // Padrão: casa
    required this.createdAt,
  });

  ProjectEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? address,
    String? constructorName,
    double? area,
    DateTime? deliveryDate,
    DateTime? contractDate,
    double? totalBudget,
    double? contingencyPercent,
    double? propertyValue,
    String? currentSituation,
    Object? plannedMoveInDate = _undefined,
    String? mainPriority,
    List<String>? criticalItems,
    PropertyType? propertyType,
    DateTime? createdAt,
  }) {
    return ProjectEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      address: address ?? this.address,
      constructorName: constructorName ?? this.constructorName,
      area: area ?? this.area,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      contractDate: contractDate ?? this.contractDate,
      totalBudget: totalBudget ?? this.totalBudget,
      contingencyPercent: contingencyPercent ?? this.contingencyPercent,
      propertyValue: propertyValue ?? this.propertyValue,
      currentSituation: currentSituation ?? this.currentSituation,
      plannedMoveInDate: plannedMoveInDate == _undefined
          ? this.plannedMoveInDate
          : plannedMoveInDate as DateTime?,
      mainPriority: mainPriority ?? this.mainPriority,
      criticalItems: criticalItems ?? this.criticalItems,
      propertyType: propertyType ?? this.propertyType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        address,
        constructorName,
        area,
        deliveryDate,
        contractDate,
        totalBudget,
        contingencyPercent,
        propertyValue,
        currentSituation,
        plannedMoveInDate,
        mainPriority,
        criticalItems,
        propertyType,
        createdAt,
      ];
}

/// Tipo de imóvel
enum PropertyType {
  /// Casa térrea ou sobrado
  house,

  /// Apartamento
  apartment,

  /// Imóvel comercial
  commercial,
}

extension PropertyTypeExtension on PropertyType {
  String get displayName {
    switch (this) {
      case PropertyType.house:
        return 'Casa';
      case PropertyType.apartment:
        return 'Apartamento';
      case PropertyType.commercial:
        return 'Comercial';
    }
  }

  String get description {
    switch (this) {
      case PropertyType.house:
        return 'Casa térrea ou sobrado';
      case PropertyType.apartment:
        return 'Apartamento em condomínio';
      case PropertyType.commercial:
        return 'Imóvel comercial';
    }
  }
}

// Sentinel value para copyWith
const Object _undefined = Object();

// Made with Bob
