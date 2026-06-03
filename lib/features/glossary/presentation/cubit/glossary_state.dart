part of 'glossary_cubit.dart';

abstract class GlossaryState extends Equatable {
  const GlossaryState();

  @override
  List<Object?> get props => [];
}

class GlossaryInitial extends GlossaryState {}

class GlossaryLoading extends GlossaryState {}

class GlossaryLoaded extends GlossaryState {
  final List<GlossaryTermEntity> terms;
  final String? selectedCategory;
  final bool showOnlyFavorites;

  const GlossaryLoaded({
    required this.terms,
    this.selectedCategory,
    this.showOnlyFavorites = false,
  });

  @override
  List<Object?> get props => [terms, selectedCategory, showOnlyFavorites];
}

class GlossaryError extends GlossaryState {
  final String message;

  const GlossaryError(this.message);

  @override
  List<Object> get props => [message];
}

// Made with Bob
