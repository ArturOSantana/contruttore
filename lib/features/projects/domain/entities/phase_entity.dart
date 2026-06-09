import 'package:equatable/equatable.dart';

class PhaseEntity extends Equatable {
  final String id;
  final String projectId;
  final int number;
  final String name;
  final String description;
  final PhaseStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final int estimatedDurationDays;
  final List<SubtaskEntity> subtasks;
  final String? notes;
  final List<String> glossaryTerms; // IDs dos termos do glossário relacionados
  final String? commonMistake; // "O que pode dar errado aqui"
  final bool
      isRetroactive; // Fase marcada como concluída no onboarding retroativo
  final DateTime?
      retroactiveMarkedAt; // Data em que foi marcada como retroativa

  // Campos financeiros
  final double estimatedBudget; // Orçamento previsto para esta fase
  final double totalSpent; // Total gasto até agora
  final double totalPending; // Total de parcelas pendentes

  // Dependências entre fases
  final List<String> dependsOn; // IDs das fases que devem ser concluídas antes
  final List<String> blockedBy; // IDs das fases que estão bloqueando esta

  // Profissionais esperados
  final List<String>
      expectedSupplierTypes; // Tipos de fornecedores necessários (ex: "Pedreiro", "Eletricista")

  // Compras esperadas
  final List<String>
      expectedPurchaseCategories; // Categorias de compras esperadas (ex: "Materiais", "Acabamentos")

  // Documentos esperados
  final List<String>
      expectedDocumentTypes; // Tipos de documentos necessários (ex: "ART", "Contrato")

  const PhaseEntity({
    required this.id,
    required this.projectId,
    required this.number,
    required this.name,
    required this.description,
    required this.status,
    this.startDate,
    this.endDate,
    required this.estimatedDurationDays,
    required this.subtasks,
    this.notes,
    this.glossaryTerms = const [],
    this.commonMistake,
    this.isRetroactive = false,
    this.retroactiveMarkedAt,
    this.estimatedBudget = 0.0,
    this.totalSpent = 0.0,
    this.totalPending = 0.0,
    this.dependsOn = const [],
    this.blockedBy = const [],
    this.expectedSupplierTypes = const [],
    this.expectedPurchaseCategories = const [],
    this.expectedDocumentTypes = const [],
  });

  bool get canComplete {
    // Fases retroativas não exigem subtarefas
    if (isRetroactive) return true;
    final requiredSubtasks = subtasks.where((s) => s.isRequired);
    return requiredSubtasks.every((s) => s.isDone);
  }

  bool get hasRecord =>
      status == PhaseStatus.done || subtasks.any((s) => s.isDone);

  int get completedSubtasksCount {
    return subtasks.where((s) => s.isDone).length;
  }

  double get progressPercentage {
    if (subtasks.isEmpty) return 0;
    return (completedSubtasksCount / subtasks.length) * 100;
  }

  // Novos getters financeiros
  double get budgetUsedPercentage {
    if (estimatedBudget == 0) return 0;
    return (totalSpent / estimatedBudget) * 100;
  }

  double get remainingBudget {
    return estimatedBudget - totalSpent - totalPending;
  }

  bool get isOverBudget {
    return totalSpent > estimatedBudget;
  }

  bool get isBlocked {
    return blockedBy.isNotEmpty;
  }

  PhaseEntity copyWith({
    String? id,
    String? projectId,
    int? number,
    String? name,
    String? description,
    PhaseStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int? estimatedDurationDays,
    List<SubtaskEntity>? subtasks,
    String? notes,
    List<String>? glossaryTerms,
    String? commonMistake,
    bool? isRetroactive,
    DateTime? retroactiveMarkedAt,
    double? estimatedBudget,
    double? totalSpent,
    double? totalPending,
    List<String>? dependsOn,
    List<String>? blockedBy,
    List<String>? expectedSupplierTypes,
    List<String>? expectedPurchaseCategories,
    List<String>? expectedDocumentTypes,
  }) {
    return PhaseEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      number: number ?? this.number,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      estimatedDurationDays:
          estimatedDurationDays ?? this.estimatedDurationDays,
      subtasks: subtasks ?? this.subtasks,
      notes: notes ?? this.notes,
      glossaryTerms: glossaryTerms ?? this.glossaryTerms,
      commonMistake: commonMistake ?? this.commonMistake,
      isRetroactive: isRetroactive ?? this.isRetroactive,
      retroactiveMarkedAt: retroactiveMarkedAt ?? this.retroactiveMarkedAt,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      totalSpent: totalSpent ?? this.totalSpent,
      totalPending: totalPending ?? this.totalPending,
      dependsOn: dependsOn ?? this.dependsOn,
      blockedBy: blockedBy ?? this.blockedBy,
      expectedSupplierTypes:
          expectedSupplierTypes ?? this.expectedSupplierTypes,
      expectedPurchaseCategories:
          expectedPurchaseCategories ?? this.expectedPurchaseCategories,
      expectedDocumentTypes:
          expectedDocumentTypes ?? this.expectedDocumentTypes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        number,
        name,
        description,
        status,
        startDate,
        endDate,
        estimatedDurationDays,
        subtasks,
        notes,
        glossaryTerms,
        commonMistake,
        isRetroactive,
        retroactiveMarkedAt,
        estimatedBudget,
        totalSpent,
        totalPending,
        dependsOn,
        blockedBy,
        expectedSupplierTypes,
        expectedPurchaseCategories,
        expectedDocumentTypes,
      ];
}

enum PhaseStatus {
  locked, // Fase futura, não pode ser iniciada ainda
  active, // Fase atual, em andamento
  done, // Fase concluída com registro
  doneNoRecord, // Fase concluída sem registro (entrada retroativa)
}

class SubtaskEntity extends Equatable {
  final String id;
  final String name;
  final bool isRequired;
  final bool isDone;
  final DateTime? completedAt;
  final String? notes;

  const SubtaskEntity({
    required this.id,
    required this.name,
    required this.isRequired,
    required this.isDone,
    this.completedAt,
    this.notes,
  });

  SubtaskEntity copyWith({
    String? id,
    String? name,
    bool? isRequired,
    bool? isDone,
    DateTime? completedAt,
    String? notes,
  }) {
    return SubtaskEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      isRequired: isRequired ?? this.isRequired,
      isDone: isDone ?? this.isDone,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, name, isRequired, isDone, completedAt, notes];
}

// Made with Bob
