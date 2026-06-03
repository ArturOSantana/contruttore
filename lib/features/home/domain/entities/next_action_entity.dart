import 'package:equatable/equatable.dart';

/// Representa a próxima ação prioritária que o usuário deve realizar
class NextActionEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? deadline;
  final String? phaseName;
  final String route; // Rota para navegar ao clicar
  final ActionPriority priority;

  const NextActionEntity({
    required this.id,
    required this.title,
    required this.description,
    this.deadline,
    this.phaseName,
    required this.route,
    required this.priority,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    deadline,
    phaseName,
    route,
    priority,
  ];
}

/// Prioridade da ação conforme documento:
/// 1. Alertas críticos
/// 2. Parcelas vencendo
/// 3. Subtarefas atrasadas
/// 4. Próxima fase sem fornecedor
/// 5. Decisão de personalização pendente
enum ActionPriority {
  critical, // Alertas críticos
  high, // Parcelas vencendo
  medium, // Subtarefas atrasadas
  low, // Próxima fase sem fornecedor
}

// Made with Bob
