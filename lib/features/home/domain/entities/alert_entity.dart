import 'package:equatable/equatable.dart';

/// Representa um alerta ativo no sistema
class AlertEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final AlertType type;
  final AlertPriority priority;
  final DateTime createdAt;
  final String? actionRoute; // Rota para navegar ao clicar

  const AlertEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.actionRoute,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    type,
    priority,
    createdAt,
    actionRoute,
  ];
}

enum AlertType {
  payment, // Parcela vencendo
  task, // Tarefa atrasada
  phase, // Fase sem fornecedor
  weather, // Alerta climático
  document, // Documento pendente
  other, // Outros
}

enum AlertPriority { critical, high, medium, low }

// Made with Bob
