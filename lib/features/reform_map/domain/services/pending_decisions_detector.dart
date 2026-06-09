import 'package:injectable/injectable.dart';
import '../entities/pending_decision_entity.dart';
import '../entities/reform_map_entity.dart';
import '../../../projects/domain/entities/phase_entity.dart';

/// Service que detecta automaticamente decisões pendentes
///
/// Analisa o estado da reforma e identifica decisões que o usuário precisa tomar
@injectable
class PendingDecisionsDetector {
  /// Detecta todas as decisões pendentes baseado no mapa da reforma
  List<PendingDecisionEntity> detect(ReformMapEntity reformMap) {
    final decisions = <PendingDecisionEntity>[];

    // 1. Detectar decisões da fase atual
    if (reformMap.currentPhase != null) {
      decisions.addAll(_detectPhaseDecisions(reformMap.currentPhase!));
    }

    // 2. Detectar decisões financeiras
    decisions.addAll(_detectFinancialDecisions(reformMap));

    // 3. Detectar decisões de fornecedores
    decisions.addAll(_detectSupplierDecisions(reformMap));

    // 4. Detectar decisões de materiais
    decisions.addAll(_detectMaterialDecisions(reformMap));

    // 5. Detectar decisões de prazo
    decisions.addAll(_detectTimelineDecisions(reformMap));

    // Ordenar por urgência (críticas primeiro)
    decisions.sort((a, b) {
      final urgencyOrder = {
        DecisionUrgency.critical: 0,
        DecisionUrgency.high: 1,
        DecisionUrgency.medium: 2,
        DecisionUrgency.low: 3,
      };
      return urgencyOrder[a.urgency]!.compareTo(urgencyOrder[b.urgency]!);
    });

    return decisions;
  }

  /// Detecta decisões específicas da fase atual
  List<PendingDecisionEntity> _detectPhaseDecisions(PhaseEntity phase) {
    final decisions = <PendingDecisionEntity>[];

    switch (phase.name.toLowerCase()) {
      case 'infraestrutura':
      case 'instalações hidráulicas e elétricas':
        decisions.addAll(_detectInfrastructureDecisions(phase));
        break;

      case 'pisos e revestimentos':
        decisions.addAll(_detectFlooringDecisions(phase));
        break;

      case 'pintura':
        decisions.addAll(_detectPaintingDecisions(phase));
        break;

      case 'acabamentos':
        decisions.addAll(_detectFinishingDecisions(phase));
        break;

      case 'marcenaria':
        decisions.addAll(_detectCarpentryDecisions(phase));
        break;
    }

    return decisions;
  }

  /// Decisões de infraestrutura
  List<PendingDecisionEntity> _detectInfrastructureDecisions(
      PhaseEntity phase) {
    return [
      PendingDecisionEntity(
        id: 'infra_ac_points',
        title: 'Definir pontos de ar-condicionado',
        description:
            'Onde serão instalados os aparelhos de ar-condicionado? Precisa definir antes de fechar as paredes.',
        category: DecisionCategory.technical,
        urgency: DecisionUrgency.critical,
        phaseId: phase.id,
        phaseName: phase.name,
        deadline: DateTime.now().add(const Duration(days: 3)),
        options: [
          'Sala e quartos',
          'Apenas quartos',
          'Todos os ambientes',
          'Não instalar',
        ],
        recommendedOption: 'Sala e quartos',
        reasonForRecommendation: 'Mais comum e oferece melhor custo-benefício',
        blocksProgress: true,
        createdAt: DateTime.now(),
      ),
      PendingDecisionEntity(
        id: 'infra_outlets',
        title: 'Revisar quantidade de tomadas',
        description:
            'Verifique se a quantidade de tomadas planejada é suficiente para todos os aparelhos.',
        category: DecisionCategory.technical,
        urgency: DecisionUrgency.high,
        phaseId: phase.id,
        phaseName: phase.name,
        deadline: DateTime.now().add(const Duration(days: 5)),
        options: [
          'Quantidade atual está boa',
          'Adicionar mais tomadas',
          'Preciso revisar o projeto',
        ],
        blocksProgress: false,
        createdAt: DateTime.now(),
      ),
      PendingDecisionEntity(
        id: 'infra_internet',
        title: 'Definir pontos de internet cabeada',
        description:
            'Onde você quer pontos de internet cabeada? Instalar agora evita gambiarras depois.',
        category: DecisionCategory.technical,
        urgency: DecisionUrgency.medium,
        phaseId: phase.id,
        phaseName: phase.name,
        options: [
          'Home office e sala',
          'Apenas home office',
          'Todos os quartos',
          'Não preciso',
        ],
        recommendedOption: 'Home office e sala',
        reasonForRecommendation: 'Garante conexão estável onde mais importa',
        blocksProgress: false,
        createdAt: DateTime.now(),
      ),
    ];
  }

  /// Decisões de pisos e revestimentos
  List<PendingDecisionEntity> _detectFlooringDecisions(PhaseEntity phase) {
    return [
      PendingDecisionEntity(
        id: 'floor_type',
        title: 'Escolher tipo de piso',
        description:
            'Qual tipo de piso você quer? Porcelanato, laminado, vinílico?',
        category: DecisionCategory.material,
        urgency: DecisionUrgency.critical,
        phaseId: phase.id,
        phaseName: phase.name,
        deadline: DateTime.now().add(const Duration(days: 2)),
        options: [
          'Porcelanato',
          'Laminado',
          'Vinílico',
          'Madeira',
        ],
        recommendedOption: 'Porcelanato',
        reasonForRecommendation: 'Mais durável e fácil de limpar',
        blocksProgress: true,
        createdAt: DateTime.now(),
      ),
      PendingDecisionEntity(
        id: 'floor_color',
        title: 'Definir cor do piso',
        description: 'Escolha a cor/modelo do piso antes de comprar.',
        category: DecisionCategory.design,
        urgency: DecisionUrgency.high,
        phaseId: phase.id,
        phaseName: phase.name,
        deadline: DateTime.now().add(const Duration(days: 3)),
        options: [
          'Claro (bege, cinza claro)',
          'Médio (cinza, madeira)',
          'Escuro (preto, madeira escura)',
        ],
        blocksProgress: true,
        createdAt: DateTime.now(),
      ),
    ];
  }

  /// Decisões de pintura
  List<PendingDecisionEntity> _detectPaintingDecisions(PhaseEntity phase) {
    return [
      PendingDecisionEntity(
        id: 'paint_colors',
        title: 'Escolher cores das paredes',
        description:
            'Defina as cores de cada ambiente. Dica: teste antes de pintar tudo!',
        category: DecisionCategory.design,
        urgency: DecisionUrgency.high,
        phaseId: phase.id,
        phaseName: phase.name,
        deadline: DateTime.now().add(const Duration(days: 2)),
        options: [
          'Branco em todos os ambientes',
          'Cores diferentes por ambiente',
          'Parede destaque em alguns ambientes',
        ],
        recommendedOption: 'Branco com parede destaque',
        reasonForRecommendation: 'Versátil e permite mudanças futuras',
        blocksProgress: true,
        createdAt: DateTime.now(),
      ),
    ];
  }

  /// Decisões de acabamentos
  List<PendingDecisionEntity> _detectFinishingDecisions(PhaseEntity phase) {
    return [
      PendingDecisionEntity(
        id: 'finish_faucets',
        title: 'Escolher torneiras e metais',
        description: 'Defina o modelo e acabamento dos metais.',
        category: DecisionCategory.material,
        urgency: DecisionUrgency.high,
        phaseId: phase.id,
        phaseName: phase.name,
        deadline: DateTime.now().add(const Duration(days: 5)),
        options: [
          'Cromado',
          'Preto fosco',
          'Dourado',
          'Inox escovado',
        ],
        recommendedOption: 'Cromado ou preto fosco',
        reasonForRecommendation: 'Mais modernos e fáceis de encontrar',
        blocksProgress: false,
        createdAt: DateTime.now(),
      ),
      PendingDecisionEntity(
        id: 'finish_switches',
        title: 'Escolher tomadas e interruptores',
        description: 'Defina o modelo e cor das tomadas/interruptores.',
        category: DecisionCategory.design,
        urgency: DecisionUrgency.medium,
        phaseId: phase.id,
        phaseName: phase.name,
        options: [
          'Branco',
          'Preto',
          'Cinza',
          'Inox',
        ],
        recommendedOption: 'Branco ou preto',
        reasonForRecommendation: 'Combinam com qualquer decoração',
        blocksProgress: false,
        createdAt: DateTime.now(),
      ),
    ];
  }

  /// Decisões de marcenaria
  List<PendingDecisionEntity> _detectCarpentryDecisions(PhaseEntity phase) {
    return [
      PendingDecisionEntity(
        id: 'carpentry_measurement',
        title: 'Agendar medição final da marcenaria',
        description:
            'IMPORTANTE: Só meça após pintura e piso prontos! Caso contrário, os móveis não vão encaixar.',
        category: DecisionCategory.timeline,
        urgency: DecisionUrgency.critical,
        phaseId: phase.id,
        phaseName: phase.name,
        deadline: DateTime.now().add(const Duration(days: 1)),
        options: [
          'Pintura e piso já estão prontos',
          'Ainda falta finalizar',
        ],
        blocksProgress: true,
        createdAt: DateTime.now(),
      ),
    ];
  }

  /// Detecta decisões financeiras
  List<PendingDecisionEntity> _detectFinancialDecisions(
      ReformMapEntity reformMap) {
    final decisions = <PendingDecisionEntity>[];

    // Se está acima de 90% do orçamento
    if (reformMap.financial.percentageSpent > 90) {
      decisions.add(
        PendingDecisionEntity(
          id: 'budget_exceeded',
          title: 'Orçamento quase esgotado',
          description:
              'Você já gastou ${reformMap.financial.percentageSpent.toStringAsFixed(0)}% do orçamento. Precisa revisar os gastos ou aumentar o orçamento.',
          category: DecisionCategory.budget,
          urgency: DecisionUrgency.critical,
          deadline: DateTime.now().add(const Duration(days: 1)),
          options: [
            'Aumentar orçamento',
            'Cortar gastos futuros',
            'Revisar prioridades',
          ],
          blocksProgress: true,
          createdAt: DateTime.now(),
        ),
      );
    }

    // Se tem parcelas vencidas
    if (reformMap.financial.pendingPayments > 0) {
      decisions.add(
        PendingDecisionEntity(
          id: 'pending_payments',
          title: 'Parcelas pendentes',
          description:
              'Você tem ${reformMap.financial.pendingPayments} parcela(s) pendente(s). Regularize para não atrasar a obra.',
          category: DecisionCategory.budget,
          urgency: DecisionUrgency.high,
          deadline: reformMap.financial.nextPaymentDate,
          options: [
            'Pagar agora',
            'Negociar prazo',
          ],
          blocksProgress: false,
          createdAt: DateTime.now(),
        ),
      );
    }

    return decisions;
  }

  /// Detecta decisões de fornecedores
  List<PendingDecisionEntity> _detectSupplierDecisions(
      ReformMapEntity reformMap) {
    final decisions = <PendingDecisionEntity>[];

    // Lógica para detectar fornecedores pendentes
    // Por enquanto, retorna vazio (será implementado quando tivermos dados de fornecedores)

    return decisions;
  }

  /// Detecta decisões de materiais
  List<PendingDecisionEntity> _detectMaterialDecisions(
      ReformMapEntity reformMap) {
    final decisions = <PendingDecisionEntity>[];

    // Lógica para detectar materiais pendentes
    // Por enquanto, retorna vazio (será implementado quando tivermos dados de compras)

    return decisions;
  }

  /// Detecta decisões de prazo
  List<PendingDecisionEntity> _detectTimelineDecisions(
      ReformMapEntity reformMap) {
    final decisions = <PendingDecisionEntity>[];

    // Se está atrasado
    if (reformMap.progress.daysDelayed > 0) {
      decisions.add(
        PendingDecisionEntity(
          id: 'timeline_delayed',
          title: 'Obra atrasada',
          description:
              'A obra está ${reformMap.progress.daysDelayed} dia(s) atrasada. Precisa tomar ação para recuperar o prazo.',
          category: DecisionCategory.timeline,
          urgency: DecisionUrgency.high,
          options: [
            'Contratar mais pessoas',
            'Ajustar cronograma',
            'Simplificar escopo',
          ],
          blocksProgress: false,
          createdAt: DateTime.now(),
        ),
      );
    }

    return decisions;
  }
}

// Made with Bob
