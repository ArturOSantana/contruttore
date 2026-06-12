import 'package:equatable/equatable.dart';

/// Entidade que representa o Modo Mudança
///
/// Aparece quando a reforma está próxima da conclusão
/// e ajuda o usuário a se preparar para a mudança
class MoveInModeEntity extends Equatable {
  /// Se o modo mudança está ativo
  final bool isActive;

  /// Dias restantes até a mudança planejada
  final int daysUntilMoveIn;

  /// Data planejada da mudança
  final DateTime? moveInDate;

  /// Progresso geral da reforma (0-100)
  final double overallProgress;

  /// Checklist de preparação para mudança
  final List<MoveInTaskEntity> tasks;

  /// Itens críticos pendentes
  final List<String> criticalPendingItems;

  /// Recomendações para a mudança
  final List<String> recommendations;

  /// Status do modo mudança
  final MoveInStatus status;

  const MoveInModeEntity({
    required this.isActive,
    required this.daysUntilMoveIn,
    this.moveInDate,
    required this.overallProgress,
    required this.tasks,
    required this.criticalPendingItems,
    required this.recommendations,
    required this.status,
  });

  /// Retorna o número de tarefas concluídas
  int get completedTasksCount => tasks.where((t) => t.isCompleted).length;

  /// Retorna o número total de tarefas
  int get totalTasksCount => tasks.length;

  /// Retorna o progresso das tarefas (0-100)
  double get tasksProgress {
    if (totalTasksCount == 0) return 0;
    return (completedTasksCount / totalTasksCount) * 100;
  }

  /// Retorna se está pronto para mudar
  bool get isReadyToMoveIn {
    return overallProgress >= 95 &&
        criticalPendingItems.isEmpty &&
        completedTasksCount == totalTasksCount;
  }

  /// Retorna a próxima tarefa pendente
  MoveInTaskEntity? get nextTask {
    return tasks.firstWhere(
      (t) => !t.isCompleted,
      orElse: () => tasks.first,
    );
  }

  @override
  List<Object?> get props => [
        isActive,
        daysUntilMoveIn,
        moveInDate,
        overallProgress,
        tasks,
        criticalPendingItems,
        recommendations,
        status,
      ];
}

/// Tarefa de preparação para mudança
class MoveInTaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final MoveInTaskCategory category;
  final bool isCompleted;
  final bool isCritical;
  final DateTime? dueDate;

  const MoveInTaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.isCompleted,
    required this.isCritical,
    this.dueDate,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        isCompleted,
        isCritical,
        dueDate,
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

/// Status do modo mudança
enum MoveInStatus {
  notReady, // Não está pronto
  almostReady, // Quase pronto
  ready, // Pronto para mudar
  delayed, // Atrasado
}

extension MoveInStatusExtension on MoveInStatus {
  String get label {
    switch (this) {
      case MoveInStatus.notReady:
        return 'Ainda não está pronto';
      case MoveInStatus.almostReady:
        return 'Quase pronto';
      case MoveInStatus.ready:
        return 'Pronto para mudar';
      case MoveInStatus.delayed:
        return 'Mudança pode atrasar';
    }
  }

  String get description {
    switch (this) {
      case MoveInStatus.notReady:
        return 'Ainda há itens importantes pendentes';
      case MoveInStatus.almostReady:
        return 'Faltam apenas alguns detalhes';
      case MoveInStatus.ready:
        return 'Tudo pronto para a mudança';
      case MoveInStatus.delayed:
        return 'Alguns itens críticos estão atrasados';
    }
  }

  String get emoji {
    switch (this) {
      case MoveInStatus.notReady:
        return '⏳';
      case MoveInStatus.almostReady:
        return '';
      case MoveInStatus.ready:
        return '';
      case MoveInStatus.delayed:
        return '';
    }
  }
}

// Made with Bob
