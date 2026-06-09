import 'package:equatable/equatable.dart';

/// Item de checklist de uma etapa da reforma
class ChecklistItemEntity extends Equatable {
  /// ID único do item
  final String id;

  /// Nome/título do item
  final String name;

  /// Descrição detalhada
  final String description;

  /// Por que este item é importante
  final String why;

  /// Dica para executar este item
  final String? tip;

  /// Se é obrigatório para concluir a etapa
  final bool mandatory;

  /// Status de conclusão
  final bool isDone;

  /// Data de conclusão
  final DateTime? completedAt;

  /// Ordem de exibição
  final int order;

  const ChecklistItemEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.why,
    this.tip,
    this.mandatory = false,
    this.isDone = false,
    this.completedAt,
    this.order = 0,
  });

  /// Cria uma cópia com campos atualizados
  ChecklistItemEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? why,
    String? tip,
    bool? mandatory,
    bool? isDone,
    DateTime? completedAt,
    int? order,
  }) {
    return ChecklistItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      why: why ?? this.why,
      tip: tip ?? this.tip,
      mandatory: mandatory ?? this.mandatory,
      isDone: isDone ?? this.isDone,
      completedAt: completedAt ?? this.completedAt,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        why,
        tip,
        mandatory,
        isDone,
        completedAt,
        order,
      ];
}

// Made with Bob
