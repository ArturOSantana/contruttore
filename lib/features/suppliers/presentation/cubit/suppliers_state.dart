import 'package:equatable/equatable.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/entities/quote_entity.dart';
import '../../domain/usecases/compare_quotes_usecase.dart';

abstract class SuppliersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SuppliersInitial extends SuppliersState {}

class SuppliersLoading extends SuppliersState {}

class SuppliersLoaded extends SuppliersState {
  final List<SupplierEntity> suppliers;
  final List<QuoteEntity> quotes;

  SuppliersLoaded({required this.suppliers, this.quotes = const []});

  @override
  List<Object?> get props => [suppliers, quotes];
}

class SupplierDetailLoaded extends SuppliersState {
  final SupplierEntity supplier;
  final List<QuoteEntity> quotes;

  SupplierDetailLoaded({required this.supplier, required this.quotes});

  @override
  List<Object?> get props => [supplier, quotes];
}

class SuppliersError extends SuppliersState {
  final String message;

  SuppliersError(this.message);

  @override
  List<Object?> get props => [message];
}

class SupplierOperationSuccess extends SuppliersState {
  final String message;

  SupplierOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class QuotesLoaded extends SuppliersState {
  final List<QuoteEntity> quotes;

  QuotesLoaded(this.quotes);

  @override
  List<Object?> get props => [quotes];
}

class QuotesCompared extends SuppliersState {
  final QuoteComparison comparison;

  QuotesCompared(this.comparison);

  @override
  List<Object?> get props => [comparison];
}

// Made with Bob
