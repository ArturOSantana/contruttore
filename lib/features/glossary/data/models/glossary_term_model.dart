import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/glossary_term_entity.dart';

/// Modelo de dados para termo do glossário
class GlossaryTermModel extends GlossaryTermEntity {
  const GlossaryTermModel({
    required super.id,
    required super.term,
    required super.definition,
    required super.whyItMatters,
    super.commonMistake,
    super.relatedPhase,
    required super.category,
    super.relatedTerms,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Cria um modelo a partir de um documento do Firestore
  factory GlossaryTermModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return GlossaryTermModel(
      id: doc.id,
      term: data['term'] ?? '',
      definition: data['definition'] ?? '',
      whyItMatters: data['whyItMatters'] ?? '',
      commonMistake: data['commonMistake'],
      relatedPhase: data['relatedPhase'],
      category: _categoryFromString(data['category'] ?? 'documentation'),
      relatedTerms: List<String>.from(data['relatedTerms'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Converte o modelo para um mapa para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'term': term,
      'definition': definition,
      'whyItMatters': whyItMatters,
      'commonMistake': commonMistake,
      'relatedPhase': relatedPhase,
      'category': _categoryToString(category),
      'relatedTerms': relatedTerms,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Converte string para categoria
  static GlossaryCategory _categoryFromString(String category) {
    switch (category.toLowerCase()) {
      case 'documentation':
        return GlossaryCategory.documentation;
      case 'structure':
        return GlossaryCategory.structure;
      case 'installations':
        return GlossaryCategory.installations;
      case 'finishing':
        return GlossaryCategory.finishing;
      case 'financial':
        return GlossaryCategory.financial;
      case 'condominium':
        return GlossaryCategory.condominium;
      default:
        return GlossaryCategory.documentation;
    }
  }

  /// Converte categoria para string
  static String _categoryToString(GlossaryCategory category) {
    switch (category) {
      case GlossaryCategory.documentation:
        return 'documentation';
      case GlossaryCategory.structure:
        return 'structure';
      case GlossaryCategory.installations:
        return 'installations';
      case GlossaryCategory.finishing:
        return 'finishing';
      case GlossaryCategory.financial:
        return 'financial';
      case GlossaryCategory.condominium:
        return 'condominium';
    }
  }

  /// Cria uma cópia do modelo com campos atualizados
  GlossaryTermModel copyWith({
    String? id,
    String? term,
    String? definition,
    String? whyItMatters,
    String? commonMistake,
    int? relatedPhase,
    GlossaryCategory? category,
    List<String>? relatedTerms,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GlossaryTermModel(
      id: id ?? this.id,
      term: term ?? this.term,
      definition: definition ?? this.definition,
      whyItMatters: whyItMatters ?? this.whyItMatters,
      commonMistake: commonMistake ?? this.commonMistake,
      relatedPhase: relatedPhase ?? this.relatedPhase,
      category: category ?? this.category,
      relatedTerms: relatedTerms ?? this.relatedTerms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Made with Bob
