import 'package:equatable/equatable.dart';
import '../../domain/entities/wishlist_item_entity.dart';

abstract class WishlistState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WishlistInitial extends WishlistState {}

class WishlistLoading extends WishlistState {}

class WishlistLoaded extends WishlistState {
  final List<WishlistItemEntity> items;
  final int selectedCount;
  final int totalCount;

  WishlistLoaded({
    required this.items,
    required this.selectedCount,
    required this.totalCount,
  });

  @override
  List<Object?> get props => [items, selectedCount, totalCount];
}

class WishlistError extends WishlistState {
  final String message;

  WishlistError(this.message);

  @override
  List<Object?> get props => [message];
}

class WishlistOperationSuccess extends WishlistState {
  final String message;

  WishlistOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Made with Bob
