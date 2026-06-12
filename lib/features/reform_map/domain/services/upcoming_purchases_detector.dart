import 'package:injectable/injectable.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../../../shopping/domain/entities/shopping_item_entity.dart';
import '../../../shopping/domain/repositories/shopping_repository.dart';
import '../entities/reform_map_entity.dart';
import '../entities/upcoming_purchase_entity.dart';

/// Serviço que detecta automaticamente as próximas compras necessárias
///
/// Analisa a fase atual e próximas fases para identificar:
/// - Itens REAIS da lista de compras do usuário (prioridade)
/// - Materiais que precisam ser comprados (sugestões genéricas como fallback)
/// - Serviços que precisam ser contratados
/// - Urgência baseada no cronograma
/// - Estimativas de custo
///
/// Exemplo de uso:
/// ```dart
/// final detector = UpcomingPurchasesDetector(shoppingRepository);
/// final purchases = await detector.detect(reformMap);
/// // Retorna lista ordenada por urgência, priorizando itens reais
/// ```
@injectable
class UpcomingPurchasesDetector {
  final ShoppingRepository _shoppingRepository;

  UpcomingPurchasesDetector(this._shoppingRepository);

  /// Detecta próximas compras baseado no mapa da reforma
  ///
  /// IMPORTANTE: Este método agora é assíncrono para buscar dados reais
  /// Retorna APENAS itens reais da lista de compras do usuário
  Future<List<UpcomingPurchaseEntity>> detect(ReformMapEntity reformMap) async {
    final purchases = <UpcomingPurchaseEntity>[];

    // Encontra a fase atual
    final currentPhase = reformMap.currentPhase;
    if (currentPhase == null) return purchases;

    // Busca APENAS itens REAIS da lista de compras do usuário
    final realPurchases = await _getRealShoppingItems(
      reformMap.projectId,
      currentPhase,
      reformMap.phases,
    );
    purchases.addAll(realPurchases);

    // NÃO adiciona sugestões genéricas automaticamente
    // O usuário deve adicionar itens manualmente na lista de compras

    // Remove duplicatas e ordena por urgência
    final uniquePurchases = _removeDuplicates(purchases);
    uniquePurchases.sort((a, b) {
      // Primeiro: itens reais têm prioridade (id começa com 'real_')
      final aIsReal = a.id.startsWith('real_');
      final bIsReal = b.id.startsWith('real_');
      if (aIsReal && !bIsReal) return -1;
      if (!aIsReal && bIsReal) return 1;

      // Segundo: por urgência
      final urgencyCompare =
          _urgencyValue(a.urgency).compareTo(_urgencyValue(b.urgency));
      if (urgencyCompare != 0) return urgencyCompare;

      // Terceiro: por dias até ser necessário
      return a.daysUntilNeeded.compareTo(b.daysUntilNeeded);
    });

    return uniquePurchases;
  }

  /// Busca itens REAIS da lista de compras do usuário
  ///
  /// Filtra por:
  /// - Itens não comprados
  /// - Itens da fase atual ou próximas 2 fases
  /// - Converte para UpcomingPurchaseEntity com urgência calculada
  Future<List<UpcomingPurchaseEntity>> _getRealShoppingItems(
    String projectId,
    PhaseEntity currentPhase,
    List<PhaseEntity> allPhases,
  ) async {
    try {
      // Busca todos os itens da lista de compras
      final result = await _shoppingRepository.getShoppingItems(projectId);

      return result.fold(
        (failure) =>
            [], // Em caso de erro, retorna lista vazia (fallback para genéricos)
        (shoppingItems) {
          // Filtra apenas itens não comprados
          final pendingItems =
              shoppingItems.where((item) => !item.isPurchased).toList();

          // Identifica fases relevantes (atual + próximas 2)
          final currentIndex = allPhases.indexOf(currentPhase);
          final relevantPhaseIds = <String>{currentPhase.id};

          if (currentIndex >= 0 && currentIndex < allPhases.length - 1) {
            relevantPhaseIds.add(allPhases[currentIndex + 1].id);
            if (currentIndex < allPhases.length - 2) {
              relevantPhaseIds.add(allPhases[currentIndex + 2].id);
            }
          }

          // Filtra itens das fases relevantes
          final relevantItems = pendingItems.where((item) {
            // Se não tem fase definida, considera relevante
            if (item.phaseId == null) return true;
            return relevantPhaseIds.contains(item.phaseId);
          }).toList();

          // Converte para UpcomingPurchaseEntity
          return relevantItems
              .map((item) => _convertToUpcomingPurchase(
                    item,
                    currentPhase,
                    allPhases,
                  ))
              .toList();
        },
      );
    } catch (e) {
      // Em caso de erro, retorna lista vazia (fallback para genéricos)
      return [];
    }
  }

  /// Converte ShoppingItemEntity para UpcomingPurchaseEntity
  UpcomingPurchaseEntity _convertToUpcomingPurchase(
    ShoppingItemEntity item,
    PhaseEntity currentPhase,
    List<PhaseEntity> allPhases,
  ) {
    // Encontra a fase do item
    final itemPhase = item.phaseId != null
        ? allPhases.firstWhere(
            (phase) => phase.id == item.phaseId,
            orElse: () => currentPhase,
          )
        : currentPhase;

    // Calcula urgência baseada na fase
    final isCurrentPhase = itemPhase.id == currentPhase.id;
    final urgency =
        _calculateUrgency(isCurrentPhase, itemPhase, currentPhase, allPhases);

    // Calcula dias até ser necessário
    final daysUntilNeeded =
        _calculateDaysUntilNeeded(isCurrentPhase, itemPhase, currentPhase);

    // Mapeia categoria de ShoppingCategory para PurchaseCategory
    final purchaseCategory = _mapShoppingToPurchaseCategory(item.category);

    // Gera dicas baseadas na categoria
    final tips = _generateTipsForCategory(purchaseCategory, item.name);

    return UpcomingPurchaseEntity(
      id: 'real_${item.id}', // Prefixo 'real_' identifica itens reais
      name: item.name,
      category: purchaseCategory,
      phaseId: itemPhase.id,
      phaseName: itemPhase.name,
      urgency: urgency,
      estimatedCost: item.estimatedPrice != null
          ? item.estimatedPrice! * item.quantity
          : null,
      quantity: '${item.quantity} ${item.unit}',
      daysUntilNeeded: daysUntilNeeded,
      reason: isCurrentPhase
          ? 'Item da sua lista de compras - Fase atual'
          : 'Item da sua lista de compras - Próxima fase',
      tips: tips,
      isPurchased: false,
    );
  }

  /// Calcula urgência baseada na fase do item
  PurchaseUrgency _calculateUrgency(
    bool isCurrentPhase,
    PhaseEntity itemPhase,
    PhaseEntity currentPhase,
    List<PhaseEntity> allPhases,
  ) {
    if (isCurrentPhase) {
      // Fase atual: urgência alta ou crítica
      if (itemPhase.status == PhaseStatus.active) {
        final progress = itemPhase.progressPercentage;
        if (progress > 50) {
          return PurchaseUrgency.critical; // Fase já avançada, precisa urgente
        }
        return PurchaseUrgency.high;
      }
      return PurchaseUrgency.high;
    }

    // Próximas fases: urgência média ou baixa
    final currentIndex = allPhases.indexOf(currentPhase);
    final itemIndex = allPhases.indexOf(itemPhase);
    final phasesAhead = itemIndex - currentIndex;

    if (phasesAhead == 1) {
      return PurchaseUrgency.medium; // Próxima fase
    }
    return PurchaseUrgency.low; // Fase depois da próxima
  }

  /// Calcula dias até o item ser necessário
  int _calculateDaysUntilNeeded(
    bool isCurrentPhase,
    PhaseEntity itemPhase,
    PhaseEntity currentPhase,
  ) {
    if (isCurrentPhase) {
      // Fase atual: baseado no progresso
      final progress = itemPhase.progressPercentage;
      if (progress > 75) return 2; // Quase no fim, urgente
      if (progress > 50) return 5; // Metade, precisa logo
      if (progress > 25) return 7; // Início, tem tempo
      return 10; // Acabou de começar
    }

    // Próximas fases: estimativa baseada em duração
    if (itemPhase.startDate != null) {
      final daysUntilStart =
          itemPhase.startDate!.difference(DateTime.now()).inDays;
      return daysUntilStart > 0 ? daysUntilStart : 14;
    }

    // Sem data de início: estimativa genérica
    return 21; // 3 semanas
  }

  /// Mapeia ShoppingCategory para PurchaseCategory
  PurchaseCategory _mapShoppingToPurchaseCategory(ShoppingCategory category) {
    switch (category) {
      case ShoppingCategory.electrical:
        return PurchaseCategory.electrical;
      case ShoppingCategory.plumbing:
        return PurchaseCategory.plumbing;
      case ShoppingCategory.coating:
      case ShoppingCategory.flooring:
        return PurchaseCategory.flooring;
      case ShoppingCategory.painting:
        return PurchaseCategory.painting;
      case ShoppingCategory.fixtures:
      case ShoppingCategory.metals:
        return PurchaseCategory.finishing;
      case ShoppingCategory.frames:
        return PurchaseCategory.materials;
      case ShoppingCategory.carpentry:
      case ShoppingCategory.furniture:
        return PurchaseCategory.furniture;
      case ShoppingCategory.decoration:
      case ShoppingCategory.other:
        return PurchaseCategory.materials;
    }
  }

  /// Gera dicas inteligentes baseadas na categoria
  List<String> _generateTipsForCategory(
      PurchaseCategory category, String itemName) {
    final tips = <String>[];

    switch (category) {
      case PurchaseCategory.flooring:
        tips.addAll([
          'Compre 10% a mais para perdas e quebras',
          'Verifique se todo o lote é igual',
          'Guarde algumas peças para reparos futuros',
        ]);
        break;
      case PurchaseCategory.painting:
        tips.addAll([
          'Compre toda a tinta do mesmo lote',
          'Calcule 1 litro para cada 10-12m²',
          'Prefira marcas de qualidade',
        ]);
        break;
      case PurchaseCategory.electrical:
        tips.addAll([
          'Verifique bitola e especificações no projeto',
          'Compre de marcas confiáveis',
          'Guarde extras para manutenção futura',
        ]);
        break;
      case PurchaseCategory.plumbing:
        tips.addAll([
          'Verifique diâmetros no projeto',
          'Compre conexões extras',
          'Prefira materiais de qualidade',
        ]);
        break;
      case PurchaseCategory.finishing:
        tips.addAll([
          'Escolha produtos de qualidade',
          'Verifique garantia do fabricante',
          'Compre todos da mesma linha',
        ]);
        break;
      case PurchaseCategory.furniture:
        tips.addAll([
          'Meça APÓS pintura e piso prontos',
          'Solicite 3 orçamentos',
          'Verifique prazo de entrega',
        ]);
        break;
      case PurchaseCategory.materials:
      case PurchaseCategory.services:
        tips.addAll([
          'Compare preços em diferentes fornecedores',
          'Verifique qualidade antes de comprar',
        ]);
        break;
    }

    return tips;
  }

  /// Detecta compras para uma fase específica (SUGESTÕES GENÉRICAS - FALLBACK)
  List<UpcomingPurchaseEntity> _detectForPhase(
    PhaseEntity phase, {
    required bool isCurrentPhase,
  }) {
    final purchases = <UpcomingPurchaseEntity>[];

    switch (phase.name.toLowerCase()) {
      case 'infraestrutura':
      case 'instalações hidráulicas e elétricas':
        purchases.addAll(_detectInfrastructurePurchases(phase, isCurrentPhase));
        break;

      case 'pisos e revestimentos':
        purchases.addAll(_detectFlooringPurchases(phase, isCurrentPhase));
        break;

      case 'pintura':
        purchases.addAll(_detectPaintingPurchases(phase, isCurrentPhase));
        break;

      case 'acabamentos':
        purchases.addAll(_detectFinishingPurchases(phase, isCurrentPhase));
        break;

      case 'marcenaria':
        purchases.addAll(_detectFurniturePurchases(phase, isCurrentPhase));
        break;
    }

    return purchases;
  }

  /// Detecta compras de infraestrutura
  List<UpcomingPurchaseEntity> _detectInfrastructurePurchases(
    PhaseEntity phase,
    bool isCurrentPhase,
  ) {
    final daysUntil = isCurrentPhase ? 3 : 14;
    final urgency =
        isCurrentPhase ? PurchaseUrgency.high : PurchaseUrgency.medium;

    return [
      UpcomingPurchaseEntity(
        id: 'infra_1',
        name: 'Cabos elétricos e conduítes',
        category: PurchaseCategory.electrical,
        phaseId: phase.id,
        phaseName: phase.name,
        urgency: urgency,
        estimatedCost: 2500.0,
        quantity: 'Conforme projeto',
        daysUntilNeeded: daysUntil,
        reason: 'Necessário para instalação elétrica',
        tips: [
          'Compre cabos de qualidade (Pirelli, Prysmian)',
          'Verifique bitola no projeto',
          'Compre 10% a mais para perdas',
        ],
      ),
      UpcomingPurchaseEntity(
        id: 'infra_2',
        name: 'Tubos e conexões hidráulicas',
        category: PurchaseCategory.plumbing,
        phaseId: phase.id,
        phaseName: phase.name,
        urgency: urgency,
        estimatedCost: 1800.0,
        quantity: 'Conforme projeto',
        daysUntilNeeded: daysUntil,
        reason: 'Necessário para instalação hidráulica',
        tips: [
          'Use PVC de qualidade',
          'Compre conexões extras',
          'Verifique diâmetros no projeto',
        ],
      ),
      UpcomingPurchaseEntity(
        id: 'infra_3',
        name: 'Caixas de passagem e tomadas',
        category: PurchaseCategory.electrical,
        phaseId: phase.id,
        phaseName: phase.name,
        urgency: urgency,
        estimatedCost: 800.0,
        quantity: 'Conforme projeto',
        daysUntilNeeded: daysUntil + 5,
        reason: 'Necessário para finalizar instalação elétrica',
        tips: [
          'Compre caixas 4x4 e 4x2',
          'Verifique quantidade no projeto',
        ],
      ),
    ];
  }

  /// Detecta compras de pisos
  List<UpcomingPurchaseEntity> _detectFlooringPurchases(
    PhaseEntity phase,
    bool isCurrentPhase,
  ) {
    final daysUntil = isCurrentPhase ? 5 : 21;
    final urgency =
        isCurrentPhase ? PurchaseUrgency.high : PurchaseUrgency.medium;

    return [
      UpcomingPurchaseEntity(
        id: 'floor_1',
        name: 'Porcelanato',
        category: PurchaseCategory.flooring,
        phaseId: phase.id,
        phaseName: phase.name,
        urgency: urgency,
        estimatedCost: 8000.0,
        quantity: '80m²',
        daysUntilNeeded: daysUntil,
        reason: 'Material principal do piso',
        tips: [
          'Compre 10% a mais para perdas e quebras',
          'Verifique se todo o lote é igual',
          'Guarde algumas peças para reparos futuros',
          'Escolha PEI 4 ou 5 para áreas de circulação',
        ],
      ),
      UpcomingPurchaseEntity(
        id: 'floor_2',
        name: 'Argamassa e rejunte',
        category: PurchaseCategory.materials,
        phaseId: phase.id,
        phaseName: phase.name,
        urgency: urgency,
        estimatedCost: 1200.0,
        quantity: 'Conforme metragem',
        daysUntilNeeded: daysUntil,
        reason: 'Necessário para instalação do piso',
        tips: [
          'Use argamassa AC3 para porcelanato',
          'Escolha rejunte epóxi para áreas molhadas',
        ],
      ),
      UpcomingPurchaseEntity(
        id: 'floor_3',
        name: 'Rodapés',
        category: PurchaseCategory.finishing,
        phaseId: phase.id,
        phaseName: phase.name,
        urgency: PurchaseUrgency.low,
        estimatedCost: 600.0,
        quantity: '60m lineares',
        daysUntilNeeded: daysUntil + 10,
        reason: 'Acabamento do piso',
        tips: [
          'Compre após definir o piso',
          'Pode ser do mesmo material ou MDF',
        ],
      ),
    ];
  }

  /// Detecta compras de pintura
  List<UpcomingPurchaseEntity> _detectPaintingPurchases(
    PhaseEntity phase,
    bool isCurrentPhase,
  ) {
    final daysUntil = isCurrentPhase ? 3 : 28;
    final urgency = isCurrentPhase ? PurchaseUrgency.high : PurchaseUrgency.low;

    return [
      UpcomingPurchaseEntity(
        id: 'paint_1',
        name: 'Tinta acrílica premium',
        category: PurchaseCategory.painting,
        phaseId: phase.id,
        phaseName: phase.name,
        urgency: urgency,
        estimatedCost: 2000.0,
        quantity: '60 litros',
        daysUntilNeeded: daysUntil,
        reason: 'Pintura das paredes',
        tips: [
          'Compre tinta de qualidade (Suvinil, Coral)',
          'Calcule 1 litro para cada 10-12m²',
          'Compre toda a tinta do mesmo lote',
        ],
      ),
      UpcomingPurchaseEntity(
        id: 'paint_2',
        name: 'Massa corrida e selador',
        category: PurchaseCategory.painting,
        phaseId: phase.id,
        phaseName: phase.name,
        urgency: urgency,
        estimatedCost: 800.0,
        quantity: 'Conforme área',
        daysUntilNeeded: daysUntil - 3,
        reason: 'Preparação das paredes',
        tips: [
          'Massa corrida é essencial para acabamento',
          'Selador ajuda a economizar tinta',
        ],
      ),
    ];
  }

  /// Detecta compras de acabamentos
  List<UpcomingPurchaseEntity> _detectFinishingPurchases(
    PhaseEntity phase,
    bool isCurrentPhase,
  ) {
    final daysUntil = isCurrentPhase ? 5 : 35;
    final urgency =
        isCurrentPhase ? PurchaseUrgency.medium : PurchaseUrgency.low;

    return [
      UpcomingPurchaseEntity(
        id: 'finish_1',
        name: 'Metais (torneiras e chuveiros)',
        category: PurchaseCategory.finishing,
        phaseId: phase.id,
        phaseName: phase.name,
        urgency: urgency,
        estimatedCost: 3500.0,
        quantity: 'Conforme projeto',
        daysUntilNeeded: daysUntil,
        reason: 'Acabamento hidráulico',
        tips: [
          'Escolha metais de qualidade',
          'Verifique garantia',
          'Compre todos da mesma linha',
        ],
      ),
      UpcomingPurchaseEntity(
        id: 'finish_2',
        name: 'Louças sanitárias',
        category: PurchaseCategory.finishing,
        phaseId: phase.id,
        phaseName: phase.name,
        urgency: urgency,
        estimatedCost: 2500.0,
        quantity: 'Conforme projeto',
        daysUntilNeeded: daysUntil,
        reason: 'Instalação de banheiros',
        tips: [
          'Verifique medidas antes de comprar',
          'Escolha vasos com caixa acoplada',
        ],
      ),
      UpcomingPurchaseEntity(
        id: 'finish_3',
        name: 'Interruptores e tomadas',
        category: PurchaseCategory.electrical,
        phaseId: phase.id,
        phaseName: phase.name,
        urgency: urgency,
        estimatedCost: 1200.0,
        quantity: 'Conforme projeto',
        daysUntilNeeded: daysUntil + 5,
        reason: 'Acabamento elétrico',
        tips: [
          'Escolha linha premium (Tramontina, Pial)',
          'Compre todos da mesma linha',
          'Verifique quantidade no projeto',
        ],
      ),
      UpcomingPurchaseEntity(
        id: 'finish_4',
        name: 'Luminárias',
        category: PurchaseCategory.electrical,
        phaseId: phase.id,
        phaseName: phase.name,
        urgency: PurchaseUrgency.low,
        estimatedCost: 2000.0,
        quantity: 'Conforme projeto',
        daysUntilNeeded: daysUntil + 10,
        reason: 'Iluminação',
        tips: [
          'Escolha LED para economia',
          'Verifique temperatura de cor (3000K-4000K)',
        ],
      ),
    ];
  }

  /// Detecta compras de marcenaria
  List<UpcomingPurchaseEntity> _detectFurniturePurchases(
    PhaseEntity phase,
    bool isCurrentPhase,
  ) {
    final daysUntil = isCurrentPhase ? 7 : 45;
    final urgency =
        isCurrentPhase ? PurchaseUrgency.medium : PurchaseUrgency.low;

    return [
      UpcomingPurchaseEntity(
        id: 'furniture_1',
        name: 'Marcenaria planejada',
        category: PurchaseCategory.furniture,
        phaseId: phase.id,
        phaseName: phase.name,
        urgency: urgency,
        estimatedCost: 25000.0,
        quantity: 'Conforme projeto',
        daysUntilNeeded: daysUntil,
        reason: 'Móveis planejados',
        tips: [
          'NUNCA meça antes da pintura e piso prontos',
          'Solicite 3 orçamentos',
          'Verifique prazo de entrega (30-60 dias)',
          'Peça garantia por escrito',
        ],
      ),
      UpcomingPurchaseEntity(
        id: 'furniture_2',
        name: 'Ferragens e puxadores',
        category: PurchaseCategory.furniture,
        phaseId: phase.id,
        phaseName: phase.name,
        urgency: PurchaseUrgency.low,
        estimatedCost: 800.0,
        quantity: 'Conforme projeto',
        daysUntilNeeded: daysUntil + 15,
        reason: 'Acabamento da marcenaria',
        tips: [
          'Escolha ferragens de qualidade',
          'Compre extras para reposição',
        ],
      ),
    ];
  }

  /// Remove compras duplicadas
  List<UpcomingPurchaseEntity> _removeDuplicates(
    List<UpcomingPurchaseEntity> purchases,
  ) {
    final seen = <String>{};
    return purchases.where((purchase) {
      if (seen.contains(purchase.id)) {
        return false;
      }
      seen.add(purchase.id);
      return true;
    }).toList();
  }

  /// Retorna valor numérico da urgência para ordenação
  int _urgencyValue(PurchaseUrgency urgency) {
    switch (urgency) {
      case PurchaseUrgency.critical:
        return 0;
      case PurchaseUrgency.high:
        return 1;
      case PurchaseUrgency.medium:
        return 2;
      case PurchaseUrgency.low:
        return 3;
    }
  }
}

// Made with Bob
