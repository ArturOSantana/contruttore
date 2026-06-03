import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/glossary_term_entity.dart';
import '../../domain/usecases/get_glossary_terms_usecase.dart';
import '../../domain/usecases/search_glossary_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';

part 'glossary_state.dart';

@injectable
class GlossaryCubit extends Cubit<GlossaryState> {
  final GetGlossaryTermsUseCase _getTermsUseCase;
  final SearchGlossaryUseCase _searchUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;

  GlossaryCubit(
    this._getTermsUseCase,
    this._searchUseCase,
    this._toggleFavoriteUseCase,
  ) : super(GlossaryInitial());

  List<GlossaryTermEntity> _allTerms = [];
  String? _selectedCategory;
  String _searchQuery = '';
  bool _showOnlyFavorites = false;

  Future<void> loadTerms() async {
    emit(GlossaryLoading());

    final result = await _getTermsUseCase(NoParams());

    result.fold((failure) => emit(GlossaryError(failure.message)), (terms) {
      _allTerms = terms;
      _applyFilters();
    });
  }

  void searchTerms(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void toggleFavoritesFilter() {
    _showOnlyFavorites = !_showOnlyFavorites;
    _applyFilters();
  }

  Future<void> toggleFavorite(String termId) async {
    final result = await _toggleFavoriteUseCase(
      ToggleFavoriteParams(termId: termId),
    );

    result.fold(
      (failure) => emit(GlossaryError(failure.message)),
      (_) => loadTerms(), // Recarrega para atualizar favoritos
    );
  }

  void _applyFilters() {
    var filtered = _allTerms;

    // Filtro de categoria
    if (_selectedCategory != null) {
      filtered = filtered
          .where((term) => term.category == _selectedCategory)
          .toList();
    }

    // Filtro de busca
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((term) {
        return term.term.toLowerCase().contains(_searchQuery) ||
            term.definition.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Filtro de favoritos - removido pois não temos isFavorite na entidade
    // O filtro de favoritos será implementado quando tivermos o repository completo
    // if (_showOnlyFavorites) {
    //   filtered = filtered.where((term) => term.isFavorite).toList();
    // }

    // Ordena alfabeticamente
    filtered.sort((a, b) => a.term.compareTo(b.term));

    emit(
      GlossaryLoaded(
        terms: filtered,
        selectedCategory: _selectedCategory,
        showOnlyFavorites: _showOnlyFavorites,
      ),
    );
  }
}

// Made with Bob
