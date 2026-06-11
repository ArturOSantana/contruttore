import 'package:equatable/equatable.dart';

/// Representa o progresso do onboarding conversacional
/// Salvo automaticamente a cada resposta para permitir retomada
class ConversationalOnboardingProgress extends Equatable {
  // Identificação
  final String? userId;
  final DateTime lastUpdated;
  final int currentStepIndex;

  // MOMENTO ATUAL (Pergunta mais importante)
  final String?
      currentMoment; // not_received_keys, just_received, planning, work_started, finishing, living

  // CAMINHO A: Ainda não recebi as chaves
  final DateTime? keyDeliveryDate; // Quando recebe as chaves
  final String?
      reformIntention; // just_furnish, small_changes, complete_reform, dont_know
  final List<String> wantedItems; // Itens que já sabe que quer

  // CAMINHO B: Recebi as chaves
  final bool? apartmentEmpty;
  final bool? hasHiredSomeone;
  final bool? hasProject;

  // CAMINHO C: Obra já começou
  final List<String>
      completedPhases; // project, demolition, electrical, plumbing, flooring, painting, carpentry
  final String? currentPhase; // O que está acontecendo hoje

  // SOBRE O IMÓVEL
  final String?
      propertyType; // apartment_plant, apartment_new, apartment_used, house
  final String? propertySize; // up_to_40, 40_60, 60_80, 80_120, over_120
  final int? bedrooms; // 1, 2, 3, 4+
  final bool? hasBalcony;
  final bool? hasSuite;

  // SOBRE QUEM VAI MORAR
  final String?
      residents; // alone, couple, couple_with_kids, family, investment
  final bool? hasPets;
  final bool? hasHomeOffice;

  // PERGUNTA MAIS VALIOSA: O que não quer esquecer
  final List<String>
      criticalItems; // air_conditioning, wired_internet, dishwasher, water_heater, automation, smart_lock, cameras, sound_system, ev_charger, central_vacuum, other

  // PRIORIDADES
  final String?
      mainPriority; // save_money, finish_fast, avoid_problems, best_finish, control_costs, organize_everything

  // DADOS BÁSICOS DO PROJETO (coletados no final)
  final String? projectName;
  final String? address;
  final String? constructorName;
  final double? area;
  final DateTime? deliveryDate;
  final DateTime? contractDate;
  final String? budgetRange;

  const ConversationalOnboardingProgress({
    this.userId,
    required this.lastUpdated,
    this.currentStepIndex = 0,
    this.currentMoment,
    this.keyDeliveryDate,
    this.reformIntention,
    this.wantedItems = const [],
    this.apartmentEmpty,
    this.hasHiredSomeone,
    this.hasProject,
    this.completedPhases = const [],
    this.currentPhase,
    this.propertyType,
    this.propertySize,
    this.bedrooms,
    this.hasBalcony,
    this.hasSuite,
    this.residents,
    this.hasPets,
    this.hasHomeOffice,
    this.criticalItems = const [],
    this.mainPriority,
    this.projectName,
    this.address,
    this.constructorName,
    this.area,
    this.deliveryDate,
    this.contractDate,
    this.budgetRange,
  });

  ConversationalOnboardingProgress copyWith({
    String? userId,
    DateTime? lastUpdated,
    int? currentStepIndex,
    String? currentMoment,
    DateTime? keyDeliveryDate,
    String? reformIntention,
    List<String>? wantedItems,
    bool? apartmentEmpty,
    bool? hasHiredSomeone,
    bool? hasProject,
    List<String>? completedPhases,
    String? currentPhase,
    String? propertyType,
    String? propertySize,
    int? bedrooms,
    bool? hasBalcony,
    bool? hasSuite,
    String? residents,
    bool? hasPets,
    bool? hasHomeOffice,
    List<String>? criticalItems,
    String? mainPriority,
    String? projectName,
    String? address,
    String? constructorName,
    double? area,
    DateTime? deliveryDate,
    DateTime? contractDate,
    String? budgetRange,
  }) {
    return ConversationalOnboardingProgress(
      userId: userId ?? this.userId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      currentMoment: currentMoment ?? this.currentMoment,
      keyDeliveryDate: keyDeliveryDate ?? this.keyDeliveryDate,
      reformIntention: reformIntention ?? this.reformIntention,
      wantedItems: wantedItems ?? this.wantedItems,
      apartmentEmpty: apartmentEmpty ?? this.apartmentEmpty,
      hasHiredSomeone: hasHiredSomeone ?? this.hasHiredSomeone,
      hasProject: hasProject ?? this.hasProject,
      completedPhases: completedPhases ?? this.completedPhases,
      currentPhase: currentPhase ?? this.currentPhase,
      propertyType: propertyType ?? this.propertyType,
      propertySize: propertySize ?? this.propertySize,
      bedrooms: bedrooms ?? this.bedrooms,
      hasBalcony: hasBalcony ?? this.hasBalcony,
      hasSuite: hasSuite ?? this.hasSuite,
      residents: residents ?? this.residents,
      hasPets: hasPets ?? this.hasPets,
      hasHomeOffice: hasHomeOffice ?? this.hasHomeOffice,
      criticalItems: criticalItems ?? this.criticalItems,
      mainPriority: mainPriority ?? this.mainPriority,
      projectName: projectName ?? this.projectName,
      address: address ?? this.address,
      constructorName: constructorName ?? this.constructorName,
      area: area ?? this.area,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      contractDate: contractDate ?? this.contractDate,
      budgetRange: budgetRange ?? this.budgetRange,
    );
  }

  /// Converte para JSON para salvar no SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'lastUpdated': lastUpdated.toIso8601String(),
      'currentStepIndex': currentStepIndex,
      'currentMoment': currentMoment,
      'keyDeliveryDate': keyDeliveryDate?.toIso8601String(),
      'reformIntention': reformIntention,
      'wantedItems': wantedItems,
      'apartmentEmpty': apartmentEmpty,
      'hasHiredSomeone': hasHiredSomeone,
      'hasProject': hasProject,
      'completedPhases': completedPhases,
      'currentPhase': currentPhase,
      'propertyType': propertyType,
      'propertySize': propertySize,
      'bedrooms': bedrooms,
      'hasBalcony': hasBalcony,
      'hasSuite': hasSuite,
      'residents': residents,
      'hasPets': hasPets,
      'hasHomeOffice': hasHomeOffice,
      'criticalItems': criticalItems,
      'mainPriority': mainPriority,
      'projectName': projectName,
      'address': address,
      'constructorName': constructorName,
      'area': area,
      'deliveryDate': deliveryDate?.toIso8601String(),
      'contractDate': contractDate?.toIso8601String(),
      'budgetRange': budgetRange,
    };
  }

  /// Cria a partir do JSON salvo
  factory ConversationalOnboardingProgress.fromJson(Map<String, dynamic> json) {
    return ConversationalOnboardingProgress(
      userId: json['userId'] as String?,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      currentStepIndex: json['currentStepIndex'] as int? ?? 0,
      currentMoment: json['currentMoment'] as String?,
      keyDeliveryDate: json['keyDeliveryDate'] != null
          ? DateTime.parse(json['keyDeliveryDate'] as String)
          : null,
      reformIntention: json['reformIntention'] as String?,
      wantedItems: (json['wantedItems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      apartmentEmpty: json['apartmentEmpty'] as bool?,
      hasHiredSomeone: json['hasHiredSomeone'] as bool?,
      hasProject: json['hasProject'] as bool?,
      completedPhases: (json['completedPhases'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      currentPhase: json['currentPhase'] as String?,
      propertyType: json['propertyType'] as String?,
      propertySize: json['propertySize'] as String?,
      bedrooms: json['bedrooms'] as int?,
      hasBalcony: json['hasBalcony'] as bool?,
      hasSuite: json['hasSuite'] as bool?,
      residents: json['residents'] as String?,
      hasPets: json['hasPets'] as bool?,
      hasHomeOffice: json['hasHomeOffice'] as bool?,
      criticalItems: (json['criticalItems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      mainPriority: json['mainPriority'] as String?,
      projectName: json['projectName'] as String?,
      address: json['address'] as String?,
      constructorName: json['constructorName'] as String?,
      area: json['area'] as double?,
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'] as String)
          : null,
      contractDate: json['contractDate'] != null
          ? DateTime.parse(json['contractDate'] as String)
          : null,
      budgetRange: json['budgetRange'] as String?,
    );
  }

  /// Verifica se o onboarding está completo
  bool get isComplete {
    return currentMoment != null &&
        propertyType != null &&
        residents != null &&
        criticalItems.isNotEmpty &&
        mainPriority != null;
  }

  /// Retorna o próximo passo baseado no momento atual
  String get nextStepHint {
    if (currentMoment == null) return 'Defina em que momento você está';
    if (propertyType == null) return 'Conte sobre seu imóvel';
    if (residents == null) return 'Quem vai morar?';
    if (criticalItems.isEmpty) return 'O que não pode esquecer?';
    if (mainPriority == null) return 'Qual sua prioridade?';
    return 'Finalize o cadastro';
  }

  @override
  List<Object?> get props => [
        userId,
        lastUpdated,
        currentStepIndex,
        currentMoment,
        keyDeliveryDate,
        reformIntention,
        wantedItems,
        apartmentEmpty,
        hasHiredSomeone,
        hasProject,
        completedPhases,
        currentPhase,
        propertyType,
        propertySize,
        bedrooms,
        hasBalcony,
        hasSuite,
        residents,
        hasPets,
        hasHomeOffice,
        criticalItems,
        mainPriority,
        projectName,
        address,
        constructorName,
        area,
        deliveryDate,
        contractDate,
        budgetRange,
      ];
}

// Made with ❤️ by Bob

// Made with Bob
