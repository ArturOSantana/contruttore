import 'package:equatable/equatable.dart';
import '../../domain/entities/shopping_item_entity.dart';

abstract class ShoppingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ShoppingInitial extends ShoppingState {}

class ShoppingLoading extends ShoppingState {}

class ShoppingLoaded extends ShoppingState {
  final List<ShoppingItemEntity> items;
  final double totalEstimated;
  final double totalPaid;
  final int pendingCount;
  final int purchasedCount;

  ShoppingLoaded({
    required this.items,
    required this.totalEstimated,
    required this.totalPaid,
    required this.pendingCount,
    required this.purchasedCount,
  });

  @override
  List<Object?> get props => [
    items,
    totalEstimated,
    totalPaid,
    pendingCount,
    purchasedCount,
  ];
}

class ShoppingError extends ShoppingState {
  final String message;

  ShoppingError(this.message);

  @override
  List<Object?> get props => [message];
}

class ShoppingOperationSuccess extends ShoppingState {
  final String message;

  ShoppingOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Made with Bob
