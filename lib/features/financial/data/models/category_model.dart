import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.budgetAmount,
    required super.type,
    required super.order,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      budgetAmount: (map['budgetAmount'] ?? 0).toDouble(),
      type: CategoryType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => CategoryType.renovation,
      ),
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'budgetAmount': budgetAmount,
      'type': type.name,
      'order': order,
    };
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      budgetAmount: entity.budgetAmount,
      type: entity.type,
      order: entity.order,
    );
  }
}

// Made with Bob
