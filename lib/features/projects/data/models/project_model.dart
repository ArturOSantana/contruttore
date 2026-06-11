import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.address,
    required super.constructorName,
    required super.area,
    required super.deliveryDate,
    required super.contractDate,
    super.totalBudget,
    required super.contingencyPercent,
    super.propertyValue,
    required super.currentSituation,
    super.plannedMoveInDate,
    super.mainPriority,
    super.criticalItems,
    required super.createdAt,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      constructorName: map['constructorName'] as String,
      area: (map['area'] as num).toDouble(),
      deliveryDate: (map['deliveryDate'] as Timestamp).toDate(),
      contractDate: (map['contractDate'] as Timestamp).toDate(),
      totalBudget: map['totalBudget'] != null
          ? (map['totalBudget'] as num).toDouble()
          : null,
      contingencyPercent: (map['contingencyPercent'] as num).toDouble(),
      propertyValue: map['propertyValue'] != null
          ? (map['propertyValue'] as num).toDouble()
          : null,
      currentSituation: map['currentSituation'] as String,
      plannedMoveInDate: map['plannedMoveInDate'] != null
          ? (map['plannedMoveInDate'] as Timestamp).toDate()
          : null,
      mainPriority: map['mainPriority'] as String?,
      criticalItems: map['criticalItems'] != null
          ? List<String>.from(map['criticalItems'] as List)
          : const [],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'address': address,
      'constructorName': constructorName,
      'area': area,
      'deliveryDate': Timestamp.fromDate(deliveryDate),
      'contractDate': Timestamp.fromDate(contractDate),
      'totalBudget': totalBudget,
      'contingencyPercent': contingencyPercent,
      'propertyValue': propertyValue,
      'currentSituation': currentSituation,
      'plannedMoveInDate': plannedMoveInDate != null
          ? Timestamp.fromDate(plannedMoveInDate!)
          : null,
      'mainPriority': mainPriority,
      'criticalItems': criticalItems,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ProjectModel.fromEntity(ProjectEntity entity) {
    return ProjectModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      address: entity.address,
      constructorName: entity.constructorName,
      area: entity.area,
      deliveryDate: entity.deliveryDate,
      contractDate: entity.contractDate,
      totalBudget: entity.totalBudget,
      contingencyPercent: entity.contingencyPercent,
      propertyValue: entity.propertyValue,
      currentSituation: entity.currentSituation,
      plannedMoveInDate: entity.plannedMoveInDate,
      mainPriority: entity.mainPriority,
      criticalItems: entity.criticalItems,
      createdAt: entity.createdAt,
    );
  }
}

// Made with Bob
