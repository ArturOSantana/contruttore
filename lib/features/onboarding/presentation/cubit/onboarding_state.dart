import 'package:equatable/equatable.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../domain/entities/reform_risk_entity.dart';

abstract class OnboardingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingInProgress extends OnboardingState {
  final int currentStep;
  final Map<String, dynamic> data;

  // Step 1: Tipo de Imóvel
  final String? propertyType;

  // Step 1.1: Nome do Projeto
  final String? projectName;

  // Step 1.2: Endereço
  final String? address;

  // Step 1.3: Construtora
  final String? constructorName;

  // Step 1.4: Área do Imóvel (m²)
  final double? area;

  // Step 1.5: Datas (Entrega e Contrato)
  final DateTime? deliveryDate;
  final DateTime? contractDate;

  // Step 2: Situação Atual
  final String? currentSituation;

  // Step 3: Nível da Reforma
  final String? reformLevel;

  // Step 4: O Que Já Foi Feito
  final List<String> completedItems;

  // Step 5: Tamanho do Imóvel
  final String? propertySize;

  // Step 6: Ambientes
  final List<String> selectedRooms;

  // Step 7: Quem Vai Morar
  final String? residents;

  // Step 8: Home Office
  final bool? hasHomeOffice;

  // Step 9: Pets
  final bool? hasPets;

  // Step 10: Ar-Condicionado
  final String? hasAirConditioning;

  // Step 11: Planejados
  final String? hasCustomFurniture;

  // Step 12: Orçamento
  final String? budgetRange;

  // Step 13: Prioridades
  final List<String> priorities;

  // Step 14: O Que Não Pode Esquecer (CRÍTICO)
  final List<String> criticalInfrastructure;

  // Step 6.5: Ambientes Prioritários
  final List<String> priorityRooms;

  // Step 12.5: Coordenação da Obra (CRÍTICO)
  final String? projectManagementType;

  // Step 13.5: Prazo de Mudança
  final String? moveInGoal;

  // Step 14.5: Itens Já Comprados
  final List<String> alreadyPurchasedItems;

  OnboardingInProgress({
    required this.currentStep,
    required this.data,
    this.propertyType,
    this.projectName,
    this.address,
    this.constructorName,
    this.area,
    this.deliveryDate,
    this.contractDate,
    this.currentSituation,
    this.reformLevel,
    this.completedItems = const [],
    this.propertySize,
    this.selectedRooms = const [],
    this.residents,
    this.hasHomeOffice,
    this.hasPets,
    this.hasAirConditioning,
    this.hasCustomFurniture,
    this.budgetRange,
    this.priorities = const [],
    this.criticalInfrastructure = const [],
    this.priorityRooms = const [],
    this.projectManagementType,
    this.moveInGoal,
    this.alreadyPurchasedItems = const [],
  });

  OnboardingInProgress copyWith({
    int? currentStep,
    Map<String, dynamic>? data,
    String? propertyType,
    String? projectName,
    String? address,
    String? constructorName,
    double? area,
    DateTime? deliveryDate,
    DateTime? contractDate,
    String? currentSituation,
    String? reformLevel,
    List<String>? completedItems,
    String? propertySize,
    List<String>? selectedRooms,
    String? residents,
    bool? hasHomeOffice,
    bool? hasPets,
    String? hasAirConditioning,
    String? hasCustomFurniture,
    String? budgetRange,
    List<String>? priorities,
    List<String>? criticalInfrastructure,
    List<String>? priorityRooms,
    String? projectManagementType,
    String? moveInGoal,
    List<String>? alreadyPurchasedItems,
  }) {
    return OnboardingInProgress(
      currentStep: currentStep ?? this.currentStep,
      data: data ?? this.data,
      propertyType: propertyType ?? this.propertyType,
      projectName: projectName ?? this.projectName,
      address: address ?? this.address,
      constructorName: constructorName ?? this.constructorName,
      area: area ?? this.area,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      contractDate: contractDate ?? this.contractDate,
      currentSituation: currentSituation ?? this.currentSituation,
      reformLevel: reformLevel ?? this.reformLevel,
      completedItems: completedItems ?? this.completedItems,
      propertySize: propertySize ?? this.propertySize,
      selectedRooms: selectedRooms ?? this.selectedRooms,
      residents: residents ?? this.residents,
      hasHomeOffice: hasHomeOffice ?? this.hasHomeOffice,
      hasPets: hasPets ?? this.hasPets,
      hasAirConditioning: hasAirConditioning ?? this.hasAirConditioning,
      hasCustomFurniture: hasCustomFurniture ?? this.hasCustomFurniture,
      budgetRange: budgetRange ?? this.budgetRange,
      priorities: priorities ?? this.priorities,
      criticalInfrastructure:
          criticalInfrastructure ?? this.criticalInfrastructure,
      priorityRooms: priorityRooms ?? this.priorityRooms,
      projectManagementType:
          projectManagementType ?? this.projectManagementType,
      moveInGoal: moveInGoal ?? this.moveInGoal,
      alreadyPurchasedItems:
          alreadyPurchasedItems ?? this.alreadyPurchasedItems,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        data,
        propertyType,
        projectName,
        address,
        constructorName,
        area,
        deliveryDate,
        contractDate,
        currentSituation,
        reformLevel,
        completedItems,
        propertySize,
        selectedRooms,
        residents,
        hasHomeOffice,
        hasPets,
        hasAirConditioning,
        hasCustomFurniture,
        budgetRange,
        priorities,
        criticalInfrastructure,
        priorityRooms,
        projectManagementType,
        moveInGoal,
        alreadyPurchasedItems,
      ];
}

class OnboardingLoading extends OnboardingState {}

class OnboardingResultsReady extends OnboardingState {
  final String nextAction;
  final List<dynamic> criticalAlerts;
  final Map<String, List<dynamic>> checklistsByRoom;
  final int healthScore;
  final int estimatedDuration;
  final List<ReformRiskEntity> reformRisks;

  OnboardingResultsReady({
    required this.nextAction,
    required this.criticalAlerts,
    required this.checklistsByRoom,
    required this.healthScore,
    required this.estimatedDuration,
    this.reformRisks = const [],
  });

  @override
  List<Object?> get props => [
        nextAction,
        criticalAlerts,
        checklistsByRoom,
        healthScore,
        estimatedDuration,
        reformRisks,
      ];
}

class OnboardingCompleted extends OnboardingState {
  final ProjectEntity project;

  OnboardingCompleted(this.project);

  @override
  List<Object?> get props => [project];
}

class OnboardingError extends OnboardingState {
  final String message;

  OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}

// Made with Bob
