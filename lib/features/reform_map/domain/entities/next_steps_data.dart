import 'package:equatable/equatable.dart';

/// Dados completos dos próximos passos da reforma
class NextStepsData extends Equatable {
  final String nextAction;
  final List<PendingTask> pendingTasks;
  final List<Deadline> upcomingDeadlines;
  final List<String> nextSteps;

  const NextStepsData({
    required this.nextAction,
    required this.pendingTasks,
    required this.upcomingDeadlines,
    required this.nextSteps,
  });

  @override
  List<Object?> get props => [
        nextAction,
        pendingTasks,
        upcomingDeadlines,
        nextSteps,
      ];
}

/// Tarefa pendente
class PendingTask extends Equatable {
  final String id;
  final String name;
  final String phaseName;
  final bool isRequired;
  final String priority;

  const PendingTask({
    required this.id,
    required this.name,
    required this.phaseName,
    required this.isRequired,
    required this.priority,
  });

  @override
  List<Object?> get props => [id, name, phaseName, isRequired, priority];
}

/// Prazo/Deadline
class Deadline extends Equatable {
  final String title;
  final DateTime date;
  final int daysRemaining;
  final bool isOverdue;
  final double? amount;

  const Deadline({
    required this.title,
    required this.date,
    required this.daysRemaining,
    required this.isOverdue,
    this.amount,
  });

  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String get urgencyLevel {
    if (isOverdue) return 'Vencido';
    if (daysRemaining <= 3) return 'Urgente';
    if (daysRemaining <= 7) return 'Próximo';
    return 'Futuro';
  }

  @override
  List<Object?> get props => [title, date, daysRemaining, isOverdue, amount];
}

// Made with Bob
