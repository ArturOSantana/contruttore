import 'package:equatable/equatable.dart';

class WishlistItemEntity extends Equatable {
  final String id;
  final String projectId;
  final String name;
  final String url;
  final String? imageUrl;
  final String? storeName;
  final double? price;
  final String? notes;
  final WishlistCategory category;
  final String? phaseId;
  final bool isSelected;
  final DateTime createdAt;

  const WishlistItemEntity({
    required this.id,
    required this.projectId,
    required this.name,
    required this.url,
    this.imageUrl,
    this.storeName,
    this.price,
    this.notes,
    required this.category,
    this.phaseId,
    required this.isSelected,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    projectId,
    name,
    url,
    imageUrl,
    storeName,
    price,
    notes,
    category,
    phaseId,
    isSelected,
    createdAt,
  ];
}

enum WishlistCategory {
  flooring,
  furniture,
  lighting,
  fixtures,
  appliances,
  decoration,
  textiles,
  carpentry,
  other,
}

extension WishlistCategoryExtension on WishlistCategory {
  String get displayName {
    switch (this) {
      case WishlistCategory.flooring:
        return 'Pisos e revestimentos';
      case WishlistCategory.furniture:
        return 'Móveis';
      case WishlistCategory.lighting:
        return 'Iluminação';
      case WishlistCategory.fixtures:
        return 'Metais e louças';
      case WishlistCategory.appliances:
        return 'Eletrodomésticos';
      case WishlistCategory.decoration:
        return 'Decoração';
      case WishlistCategory.textiles:
        return 'Têxteis';
      case WishlistCategory.carpentry:
        return 'Marcenaria';
      case WishlistCategory.other:
        return 'Outros';
    }
  }
}

// Made with Bob
