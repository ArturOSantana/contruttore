import 'package:injectable/injectable.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../entities/reform_map_entity.dart';
import '../entities/upcoming_purchase_entity.dart';

/// Serviço que detecta automaticamente as próximas compras necessárias
///
/// Analisa a fase atual e próximas fases para identificar:
/// - Materiais que precisam ser comprados
/// - Serviços que precisam ser contratados
/// - Urgência baseada no cronograma
/// - Estimativas de custo
///
/// Exemplo de uso:
/// ```dart
/// final detector = UpcomingPurchasesDetector();
/// final purchases = detector.detect(reformMap);
/// // Retorna lista ordenada por urgência
/// ```
@injectable
class UpcomingPurchasesDetector {
  /// Detecta próximas compras baseado no mapa da reforma
  List<UpcomingPurchaseEntity> detect(ReformMapEntity reformMap) {
    final purchases = <UpcomingPurchaseEntity>[];

    // Encontra a fase atual
    final currentPhase = reformMap.currentPhase;
    if (currentPhase == null) return purchases;

    // Detecta compras da fase atual
    purchases.addAll(_detectForPhase(currentPhase, isCurrentPhase: true));

    // Detecta compras das próximas 2 fases
    final currentIndex = reformMap.phases.indexOf(currentPhase);
    if (currentIndex >= 0 && currentIndex < reformMap.phases.length - 1) {
      final nextPhase = reformMap.phases[currentIndex + 1];
      purchases.addAll(_detectForPhase(nextPhase, isCurrentPhase: false));

      if (currentIndex < reformMap.phases.length - 2) {
        final nextNextPhase = reformMap.phases[currentIndex + 2];
        purchases.addAll(_detectForPhase(nextNextPhase, isCurrentPhase: false));
      }
    }

    // Remove duplicatas e ordena por urgência
    final uniquePurchases = _removeDuplicates(purchases);
    uniquePurchases.sort((a, b) {
      // Primeiro por urgência
      final urgencyCompare =
          _urgencyValue(a.urgency).compareTo(_urgencyValue(b.urgency));
      if (urgencyCompare != 0) return urgencyCompare;

      // Depois por dias até ser necessário
      return a.daysUntilNeeded.compareTo(b.daysUntilNeeded);
    });

    return uniquePurchases;
  }

  /// Detecta compras para uma fase específica
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
