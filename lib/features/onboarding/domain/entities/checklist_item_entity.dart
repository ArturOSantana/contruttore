import 'package:equatable/equatable.dart';

/// Item de checklist gerado no onboarding
class ChecklistItemEntity extends Equatable {
  final String id;
  final String name;
  final String category; // 'Eletrodomésticos', 'Móveis', 'Acabamentos', etc
  final String? room; // 'Cozinha', 'Banheiro', etc
  final bool isCritical; // Se foi marcado no Step 14
  final bool isCompleted;
  final String? estimatedCost;
  final String? notes;

  const ChecklistItemEntity({
    required this.id,
    required this.name,
    required this.category,
    this.room,
    this.isCritical = false,
    this.isCompleted = false,
    this.estimatedCost,
    this.notes,
  });

  ChecklistItemEntity copyWith({
    String? id,
    String? name,
    String? category,
    String? room,
    bool? isCritical,
    bool? isCompleted,
    String? estimatedCost,
    String? notes,
  }) {
    return ChecklistItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      room: room ?? this.room,
      isCritical: isCritical ?? this.isCritical,
      isCompleted: isCompleted ?? this.isCompleted,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        room,
        isCritical,
        isCompleted,
        estimatedCost,
        notes,
      ];
}

// Made with Bob
