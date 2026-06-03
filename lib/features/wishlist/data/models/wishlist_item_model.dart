import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/wishlist_item_entity.dart';

class WishlistItemModel extends WishlistItemEntity {
  const WishlistItemModel({
    required super.id,
    required super.projectId,
    required super.name,
    required super.url,
    super.imageUrl,
    super.storeName,
    super.price,
    super.notes,
    required super.category,
    super.phaseId,
    required super.isSelected,
    required super.createdAt,
  });

  factory WishlistItemModel.fromMap(Map<String, dynamic> map, String id) {
    return WishlistItemModel(
      id: id,
      projectId: map['projectId'] ?? '',
      name: map['name'] ?? '',
      url: map['url'] ?? '',
      imageUrl: map['imageUrl'],
      storeName: map['storeName'],
      price: map['price']?.toDouble(),
      notes: map['notes'],
      category: WishlistCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => WishlistCategory.other,
      ),
      phaseId: map['phaseId'],
      isSelected: map['isSelected'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'name': name,
      'url': url,
      'imageUrl': imageUrl,
      'storeName': storeName,
      'price': price,
      'notes': notes,
      'category': category.name,
      'phaseId': phaseId,
      'isSelected': isSelected,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

// Made with Bob
