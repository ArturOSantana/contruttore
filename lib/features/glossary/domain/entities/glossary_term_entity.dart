import 'package:equatable/equatable.dart';

/// Categorias do glossário
enum GlossaryCategory {
  documentation('Documentação e Legal'),
  structure('Estrutura'),
  installations('Instalações'),
  finishing('Acabamento'),
  financial('Financeiro'),
  condominium('Condomínio');

  final String label;
  const GlossaryCategory(this.label);
}

/// Entidade que representa um termo do glossário
class GlossaryTermEntity extends Equatable {
  final String id;
  final String term;
  final String definition;
  final String whyItMatters;
  final String? commonMistake;
  final int? relatedPhase;
  final GlossaryCategory category;
  final List<String> relatedTerms;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GlossaryTermEntity({
    required this.id,
    required this.term,
    required this.definition,
    required this.whyItMatters,
    this.commonMistake,
    this.relatedPhase,
    required this.category,
    this.relatedTerms = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    term,
    definition,
    whyItMatters,
    commonMistake,
    relatedPhase,
    category,
    relatedTerms,
    createdAt,
    updatedAt,
  ];

  /// Retorna o termo em formato de busca (lowercase, sem acentos)
  String get searchableTerm => term.toLowerCase();

  /// Verifica se o termo contém a query de busca
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return term.toLowerCase().contains(lowerQuery) ||
        definition.toLowerCase().contains(lowerQuery);
  }
}

// Made with Bob
