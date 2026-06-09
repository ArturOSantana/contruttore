import 'package:equatable/equatable.dart';

/// Representa a preparação necessária para a próxima etapa
///
/// O sistema detecta automaticamente o que precisa ser feito
/// ANTES de iniciar a próxima fase da reforma.
///
/// Exemplo:
/// ```dart
/// NextPhasePreparationEntity(
///   id: '1',
///   nextPhaseName: 'Pisos e Revestimentos',
///   daysUntilStart: 7,
///   readinessScore: 65,
///   checklist: [
///     PreparationItem(
///       id: '1',
///       title: 'Comprar porcelanato',
///       description: 'Escolher e comprar o piso',
///       category: PreparationCategory.purchase,
///       priority: PreparationPriority.high,
///       isDone: false,
///     ),
///   ],
/// )
/// ```
class NextPhasePreparationEntity extends Equatable {
  /// ID único da preparação
  final String id;

  /// Nome da próxima fase
  final String nextPhaseName;

  /// ID da próxima fase
  final String nextPhaseId;

  /// Dias até o início previsto
  final int daysUntilStart;

  /// Score de prontidão (0-100)
  final int readinessScore;

  /// Checklist de preparação
  final List<PreparationItemEntity> checklist;

  /// Alertas importantes
  final List<String> alerts;

  /// Se está pronto para começar
  final bool isReady;

  const NextPhasePreparationEntity({
    required this.id,
    required this.nextPhaseName,
    required this.nextPhaseId,
    required this.daysUntilStart,
    required this.readinessScore,
    required this.checklist,
    this.alerts = const [],
    required this.isReady,
  });

  /// Retorna a cor do score
  String get scoreColor {
    if (readinessScore >= 80) return '#22C55E'; // Verde
    if (readinessScore >= 60) return '#EAB308'; // Amarelo
    if (readinessScore >= 40) return '#F97316'; // Laranja
    return '#EF4444'; // Vermelho
  }

  /// Retorna o texto do status
  String get statusText {
    if (readinessScore >= 80) return 'Pronto para começar';
    if (readinessScore >= 60) return 'Quase pronto';
    if (readinessScore >= 40) return 'Precisa de atenção';
    return 'Não está pronto';
  }

  /// Retorna o ícone do status
  String get statusIcon {
    if (readinessScore >= 80) return '';
    if (readinessScore >= 60) return '';
    if (readinessScore >= 40) return '';
    return '';
  }

  /// Retorna texto amigável do prazo
  String get timelineText {
    if (daysUntilStart == 0) {
      return 'Começa hoje';
    } else if (daysUntilStart == 1) {
      return 'Começa amanhã';
    } else if (daysUntilStart <= 7) {
      return 'Começa em $daysUntilStart dias';
    } else if (daysUntilStart <= 14) {
      return 'Começa em 2 semanas';
    } else if (daysUntilStart <= 30) {
      return 'Começa em ${(daysUntilStart / 7).ceil()} semanas';
    } else {
      return 'Começa em ${(daysUntilStart / 30).ceil()} meses';
    }
  }

  /// Retorna itens pendentes
  List<PreparationItemEntity> get pendingItems {
    return checklist.where((item) => !item.isDone).toList();
  }

  /// Retorna itens concluídos
  List<PreparationItemEntity> get completedItems {
    return checklist.where((item) => item.isDone).toList();
  }

  /// Retorna progresso em porcentagem
  int get progressPercentage {
    if (checklist.isEmpty) return 100;
    return ((completedItems.length / checklist.length) * 100).round();
  }

  @override
  List<Object?> get props => [
        id,
        nextPhaseName,
        nextPhaseId,
        daysUntilStart,
        readinessScore,
        checklist,
        alerts,
        isReady,
      ];
}

/// Item do checklist de preparação
class PreparationItemEntity extends Equatable {
  /// ID único do item
  final String id;

  /// Título do item
  final String title;

  /// Descrição detalhada
  final String description;

  /// Categoria do item
  final PreparationCategory category;

  /// Prioridade
  final PreparationPriority priority;

  /// Se está concluído
  final bool isDone;

  /// Dica importante
  final String? tip;

  /// Link relacionado (opcional)
  final String? relatedLink;

  const PreparationItemEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.isDone,
    this.tip,
    this.relatedLink,
  });

  /// Retorna o ícone da categoria
  String get categoryIcon {
    switch (category) {
      case PreparationCategory.purchase:
        return '';
      case PreparationCategory.decision:
        return '';
      case PreparationCategory.professional:
        return '';
      case PreparationCategory.document:
        return '';
      case PreparationCategory.measurement:
        return '';
      case PreparationCategory.approval:
        return '';
    }
  }

  /// Retorna a cor da prioridade
  String get priorityColor {
    switch (priority) {
      case PreparationPriority.critical:
        return '#EF4444'; // Vermelho
      case PreparationPriority.high:
        return '#F97316'; // Laranja
      case PreparationPriority.medium:
        return '#EAB308'; // Amarelo
      case PreparationPriority.low:
        return '#22C55E'; // Verde
    }
  }

  /// Copia o item com novos valores
  PreparationItemEntity copyWith({
    String? id,
    String? title,
    String? description,
    PreparationCategory? category,
    PreparationPriority? priority,
    bool? isDone,
    String? tip,
    String? relatedLink,
  }) {
    return PreparationItemEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
      tip: tip ?? this.tip,
      relatedLink: relatedLink ?? this.relatedLink,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        priority,
        isDone,
        tip,
        relatedLink,
      ];
}

/// Categoria do item de preparação
enum PreparationCategory {
  /// Compra necessária
  purchase,

  /// Decisão a tomar
  decision,

  /// Contratar profissional
  professional,

  /// Documento necessário
  document,

  /// Medição necessária
  measurement,

  /// Aprovação necessária
  approval,
}

/// Prioridade do item
enum PreparationPriority {
  /// Crítico - bloqueia o início
  critical,

  /// Alta - muito importante
  high,

  /// Média - importante
  medium,

  /// Baixa - pode esperar
  low,
}

// Made with Bob
