import 'package:equatable/equatable.dart';

/// Representa uma compra que precisa ser feita em breve
///
/// O sistema detecta automaticamente quais materiais/serviços
/// precisam ser comprados baseado na fase atual e próximas fases.
///
/// Exemplo:
/// ```dart
/// UpcomingPurchaseEntity(
///   id: '1',
///   name: 'Porcelanato 60x60',
///   category: PurchaseCategory.flooring,
///   phaseId: 'phase_4',
///   phaseName: 'Pisos e Revestimentos',
///   urgency: PurchaseUrgency.high,
///   estimatedCost: 5000.0,
///   quantity: '80m²',
///   daysUntilNeeded: 7,
///   reason: 'Necessário para iniciar instalação do piso',
///   tips: [
///     'Compre 10% a mais para perdas',
///     'Verifique se o lote é o mesmo',
///   ],
/// )
/// ```
class UpcomingPurchaseEntity extends Equatable {
  /// ID único da compra
  final String id;

  /// Nome do item/serviço
  final String name;

  /// Categoria da compra
  final PurchaseCategory category;

  /// ID da fase relacionada
  final String phaseId;

  /// Nome da fase relacionada
  final String phaseName;

  /// Urgência da compra
  final PurchaseUrgency urgency;

  /// Custo estimado em reais
  final double? estimatedCost;

  /// Quantidade necessária (ex: "80m²", "15 unidades")
  final String? quantity;

  /// Dias até ser necessário
  final int daysUntilNeeded;

  /// Motivo da compra
  final String reason;

  /// Dicas importantes
  final List<String> tips;

  /// Link para fornecedores sugeridos (opcional)
  final List<String>? suggestedSuppliers;

  /// Se já foi comprado
  final bool isPurchased;

  const UpcomingPurchaseEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.phaseId,
    required this.phaseName,
    required this.urgency,
    this.estimatedCost,
    this.quantity,
    required this.daysUntilNeeded,
    required this.reason,
    this.tips = const [],
    this.suggestedSuppliers,
    this.isPurchased = false,
  });

  /// Retorna a cor baseada na urgência
  String get urgencyColor {
    switch (urgency) {
      case PurchaseUrgency.critical:
        return '#EF4444'; // Vermelho
      case PurchaseUrgency.high:
        return '#F97316'; // Laranja
      case PurchaseUrgency.medium:
        return '#EAB308'; // Amarelo
      case PurchaseUrgency.low:
        return '#22C55E'; // Verde
    }
  }

  /// Retorna o texto da urgência
  String get urgencyText {
    switch (urgency) {
      case PurchaseUrgency.critical:
        return 'URGENTE';
      case PurchaseUrgency.high:
        return 'ALTA';
      case PurchaseUrgency.medium:
        return 'MÉDIA';
      case PurchaseUrgency.low:
        return 'BAIXA';
    }
  }

  /// Retorna o ícone baseado na categoria
  String get categoryIcon {
    switch (category) {
      case PurchaseCategory.materials:
        return '';
      case PurchaseCategory.flooring:
        return '';
      case PurchaseCategory.painting:
        return '';
      case PurchaseCategory.electrical:
        return '';
      case PurchaseCategory.plumbing:
        return '';
      case PurchaseCategory.finishing:
        return '';
      case PurchaseCategory.furniture:
        return '';
      case PurchaseCategory.services:
        return '';
    }
  }

  /// Retorna texto amigável do prazo
  String get deadlineText {
    if (daysUntilNeeded == 0) {
      return 'Hoje';
    } else if (daysUntilNeeded == 1) {
      return 'Amanhã';
    } else if (daysUntilNeeded <= 7) {
      return 'Esta semana';
    } else if (daysUntilNeeded <= 14) {
      return 'Próximas 2 semanas';
    } else if (daysUntilNeeded <= 30) {
      return 'Este mês';
    } else {
      return 'Próximo mês';
    }
  }

  /// Copia a entidade com novos valores
  UpcomingPurchaseEntity copyWith({
    String? id,
    String? name,
    PurchaseCategory? category,
    String? phaseId,
    String? phaseName,
    PurchaseUrgency? urgency,
    double? estimatedCost,
    String? quantity,
    int? daysUntilNeeded,
    String? reason,
    List<String>? tips,
    List<String>? suggestedSuppliers,
    bool? isPurchased,
  }) {
    return UpcomingPurchaseEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      phaseId: phaseId ?? this.phaseId,
      phaseName: phaseName ?? this.phaseName,
      urgency: urgency ?? this.urgency,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      quantity: quantity ?? this.quantity,
      daysUntilNeeded: daysUntilNeeded ?? this.daysUntilNeeded,
      reason: reason ?? this.reason,
      tips: tips ?? this.tips,
      suggestedSuppliers: suggestedSuppliers ?? this.suggestedSuppliers,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        phaseId,
        phaseName,
        urgency,
        estimatedCost,
        quantity,
        daysUntilNeeded,
        reason,
        tips,
        suggestedSuppliers,
        isPurchased,
      ];
}

/// Categoria da compra
enum PurchaseCategory {
  /// Materiais de construção gerais
  materials,

  /// Pisos e revestimentos
  flooring,

  /// Tintas e materiais de pintura
  painting,

  /// Materiais elétricos
  electrical,

  /// Materiais hidráulicos
  plumbing,

  /// Acabamentos (metais, louças, etc)
  finishing,

  /// Móveis e marcenaria
  furniture,

  /// Serviços profissionais
  services,
}

/// Urgência da compra
enum PurchaseUrgency {
  /// Crítico - precisa comprar imediatamente
  critical,

  /// Alta - precisa comprar esta semana
  high,

  /// Média - precisa comprar nas próximas 2 semanas
  medium,

  /// Baixa - pode esperar mais de 2 semanas
  low,
}

// Made with Bob
