import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final double budgetAmount;
  final CategoryType type;
  final int order;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.budgetAmount,
    required this.type,
    required this.order,
  });

  @override
  List<Object?> get props => [id, name, budgetAmount, type, order];
}

enum CategoryType {
  buyer, // Jornada comprador
  renovation, // Jornada reforma
}

// Made with Bob
