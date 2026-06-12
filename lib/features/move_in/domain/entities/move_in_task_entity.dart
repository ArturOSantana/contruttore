import 'package:equatable/equatable.dart';

/// Entidade de domínio para tarefas do Modo Mudança
class MoveInTaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final MoveInTaskCategory category;
  final bool isCompleted;
  final bool isCritical;
  final bool isCustom; // true se foi adicionado pelo usuário
  final DateTime? dueDate;
  final DateTime? completedAt;

  const MoveInTaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.isCompleted,
    required this.isCritical,
    this.isCustom = false,
    this.dueDate,
    this.completedAt,
  });

  /// Retorna a prioridade numérica da tarefa (maior = mais prioritário)
  int get priorityScore {
    int score = 0;

    // Crítico = +100
    if (isCritical) score += 100;

    // Por categoria (essenciais e serviços são mais importantes)
    switch (category) {
      case MoveInTaskCategory.essentials:
        score += 50;
        break;
      case MoveInTaskCategory.utilities:
        score += 45;
        break;
      case MoveInTaskCategory.cleaning:
        score += 40;
        break;
      case MoveInTaskCategory.inspection:
        score += 35;
        break;
      case MoveInTaskCategory.documentation:
        score += 30;
        break;
      case MoveInTaskCategory.moving:
        score += 25;
        break;
      case MoveInTaskCategory.decoration:
        score += 20;
        break;
    }

    // Prazo próximo = +pontos (quanto mais próximo, mais pontos)
    if (dueDate != null) {
      final daysUntilDue = dueDate!.difference(DateTime.now()).inDays;
      if (daysUntilDue <= 0) {
        score += 200; // Atrasado!
      } else if (daysUntilDue <= 3) {
        score += 80; // Muito urgente
      } else if (daysUntilDue <= 7) {
        score += 60; // Urgente
      } else if (daysUntilDue <= 14) {
        score += 40; // Próximo
      } else if (daysUntilDue <= 30) {
        score += 20; // Médio prazo
      }
    }

    return score;
  }

  /// Retorna se a tarefa está atrasada
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  /// Retorna se a tarefa é urgente (menos de 7 dias)
  bool get isUrgent {
    if (dueDate == null || isCompleted) return false;
    final daysUntilDue = dueDate!.difference(DateTime.now()).inDays;
    return daysUntilDue <= 7;
  }

  /// Retorna quantos dias faltam até o vencimento
  int get daysUntilDue {
    if (dueDate == null) return 999; // Valor alto para tarefas sem prazo
    return dueDate!.difference(DateTime.now()).inDays;
  }

  /// Cria cópia com alterações
  MoveInTaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    MoveInTaskCategory? category,
    bool? isCompleted,
    bool? isCritical,
    bool? isCustom,
    DateTime? dueDate,
    DateTime? completedAt,
  }) {
    return MoveInTaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      isCritical: isCritical ?? this.isCritical,
      isCustom: isCustom ?? this.isCustom,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        isCompleted,
        isCritical,
        isCustom,
        dueDate,
        completedAt,
      ];
}

/// Categoria de tarefa de mudança
enum MoveInTaskCategory {
  essentials, // Essenciais (cama, geladeira, fogão)
  utilities, // Serviços (água, luz, gás, internet)
  cleaning, // Limpeza
  inspection, // Vistoria
  documentation, // Documentação
  moving, // Mudança
  decoration, // Decoração
}

extension MoveInTaskCategoryExtension on MoveInTaskCategory {
  String get label {
    switch (this) {
      case MoveInTaskCategory.essentials:
        return 'Essenciais';
      case MoveInTaskCategory.utilities:
        return 'Serviços';
      case MoveInTaskCategory.cleaning:
        return 'Limpeza';
      case MoveInTaskCategory.inspection:
        return 'Vistoria';
      case MoveInTaskCategory.documentation:
        return 'Documentação';
      case MoveInTaskCategory.moving:
        return 'Mudança';
      case MoveInTaskCategory.decoration:
        return 'Decoração';
    }
  }

  String get emoji {
    switch (this) {
      case MoveInTaskCategory.essentials:
        return '🛏️';
      case MoveInTaskCategory.utilities:
        return '⚡';
      case MoveInTaskCategory.cleaning:
        return '🧹';
      case MoveInTaskCategory.inspection:
        return '🔍';
      case MoveInTaskCategory.documentation:
        return '📄';
      case MoveInTaskCategory.moving:
        return '📦';
      case MoveInTaskCategory.decoration:
        return '🎨';
    }
  }
}

// Made with Bob
