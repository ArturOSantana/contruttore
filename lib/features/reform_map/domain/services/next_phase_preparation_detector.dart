import 'package:injectable/injectable.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../entities/next_phase_preparation_entity.dart';
import '../entities/reform_map_entity.dart';

/// Serviço que detecta o que precisa ser feito antes da próxima etapa
///
/// Analisa a fase atual e a próxima para criar um checklist
/// de preparação automático.
///
/// Exemplo de uso:
/// ```dart
/// final detector = NextPhasePreparationDetector();
/// final preparation = detector.detect(reformMap);
/// // Retorna checklist completo
/// ```
@injectable
class NextPhasePreparationDetector {
  /// Detecta preparação necessária para a próxima fase
  NextPhasePreparationEntity? detect(ReformMapEntity reformMap) {
    // Encontra a fase atual
    final currentPhase = reformMap.currentPhase;
    if (currentPhase == null) return null;

    // Encontra a próxima fase
    final currentIndex = reformMap.phases.indexOf(currentPhase);
    if (currentIndex < 0 || currentIndex >= reformMap.phases.length - 1) {
      return null; // Não há próxima fase
    }

    final nextPhase = reformMap.phases[currentIndex + 1];

    // Gera checklist baseado na próxima fase
    final checklist = _generateChecklistForPhase(nextPhase, reformMap);

    // Calcula score de prontidão
    final readinessScore = _calculateReadinessScore(checklist, reformMap);

    // Gera alertas
    final alerts = _generateAlerts(nextPhase, checklist, reformMap);

    // Calcula dias até o início
    final daysUntilStart = _calculateDaysUntilStart(currentPhase, nextPhase);

    return NextPhasePreparationEntity(
      id: 'prep_${nextPhase.id}',
      nextPhaseName: nextPhase.name,
      nextPhaseId: nextPhase.id,
      daysUntilStart: daysUntilStart,
      readinessScore: readinessScore,
      checklist: checklist,
      alerts: alerts,
      isReady: readinessScore >= 80,
    );
  }

  /// Gera checklist baseado na próxima fase
  List<PreparationItemEntity> _generateChecklistForPhase(
    PhaseEntity nextPhase,
    ReformMapEntity reformMap,
  ) {
    switch (nextPhase.name.toLowerCase()) {
      case 'infraestrutura':
      case 'instalações hidráulicas e elétricas':
        return _generateInfrastructureChecklist();

      case 'pisos e revestimentos':
        return _generateFlooringChecklist();

      case 'pintura':
        return _generatePaintingChecklist();

      case 'acabamentos':
        return _generateFinishingChecklist();

      case 'marcenaria':
        return _generateCarpentryChecklist();

      default:
        return [];
    }
  }

  /// Checklist para Infraestrutura
  List<PreparationItemEntity> _generateInfrastructureChecklist() {
    return [
      const PreparationItemEntity(
        id: 'infra_1',
        title: 'Contratar eletricista',
        description: 'Encontrar e contratar profissional qualificado',
        category: PreparationCategory.professional,
        priority: PreparationPriority.critical,
        isDone: false,
        tip: 'Peça referências e verifique trabalhos anteriores',
      ),
      const PreparationItemEntity(
        id: 'infra_2',
        title: 'Contratar encanador',
        description: 'Encontrar e contratar profissional qualificado',
        category: PreparationCategory.professional,
        priority: PreparationPriority.critical,
        isDone: false,
        tip: 'Verifique se tem experiência com reformas',
      ),
      const PreparationItemEntity(
        id: 'infra_3',
        title: 'Definir pontos elétricos',
        description: 'Decidir onde ficarão tomadas, interruptores e luminárias',
        category: PreparationCategory.decision,
        priority: PreparationPriority.high,
        isDone: false,
        tip: 'Pense em todos os aparelhos que vai usar',
      ),
      const PreparationItemEntity(
        id: 'infra_4',
        title: 'Definir pontos hidráulicos',
        description: 'Decidir onde ficarão torneiras, chuveiros e ralos',
        category: PreparationCategory.decision,
        priority: PreparationPriority.high,
        isDone: false,
      ),
      const PreparationItemEntity(
        id: 'infra_5',
        title: 'Comprar materiais elétricos',
        description: 'Cabos, conduítes, caixas de passagem',
        category: PreparationCategory.purchase,
        priority: PreparationPriority.high,
        isDone: false,
        tip: 'Compre 10% a mais para perdas',
      ),
      const PreparationItemEntity(
        id: 'infra_6',
        title: 'Comprar materiais hidráulicos',
        description: 'Tubos, conexões, registros',
        category: PreparationCategory.purchase,
        priority: PreparationPriority.high,
        isDone: false,
      ),
    ];
  }

  /// Checklist para Pisos
  List<PreparationItemEntity> _generateFlooringChecklist() {
    return [
      const PreparationItemEntity(
        id: 'floor_1',
        title: 'Escolher tipo de piso',
        description: 'Decidir entre porcelanato, cerâmica, laminado, etc',
        category: PreparationCategory.decision,
        priority: PreparationPriority.critical,
        isDone: false,
        tip: 'Considere durabilidade e manutenção',
      ),
      const PreparationItemEntity(
        id: 'floor_2',
        title: 'Escolher cor e modelo',
        description: 'Definir a estética do piso',
        category: PreparationCategory.decision,
        priority: PreparationPriority.critical,
        isDone: false,
        tip: 'Cores claras ampliam o ambiente',
      ),
      const PreparationItemEntity(
        id: 'floor_3',
        title: 'Comprar porcelanato',
        description: 'Adquirir o piso escolhido',
        category: PreparationCategory.purchase,
        priority: PreparationPriority.high,
        isDone: false,
        tip: 'Compre 10% a mais e guarde peças extras',
      ),
      const PreparationItemEntity(
        id: 'floor_4',
        title: 'Comprar argamassa e rejunte',
        description: 'Materiais para instalação',
        category: PreparationCategory.purchase,
        priority: PreparationPriority.high,
        isDone: false,
        tip: 'Use argamassa AC3 para porcelanato',
      ),
      const PreparationItemEntity(
        id: 'floor_5',
        title: 'Contratar pedreiro',
        description: 'Profissional para instalar o piso',
        category: PreparationCategory.professional,
        priority: PreparationPriority.high,
        isDone: false,
        tip: 'Peça para ver trabalhos anteriores',
      ),
      const PreparationItemEntity(
        id: 'floor_6',
        title: 'Verificar nivelamento',
        description: 'Garantir que o contrapiso está nivelado',
        category: PreparationCategory.measurement,
        priority: PreparationPriority.medium,
        isDone: false,
      ),
    ];
  }

  /// Checklist para Pintura
  List<PreparationItemEntity> _generatePaintingChecklist() {
    return [
      const PreparationItemEntity(
        id: 'paint_1',
        title: 'Escolher cores das paredes',
        description: 'Definir paleta de cores para cada ambiente',
        category: PreparationCategory.decision,
        priority: PreparationPriority.critical,
        isDone: false,
        tip: 'Teste as cores antes de comprar toda a tinta',
      ),
      const PreparationItemEntity(
        id: 'paint_2',
        title: 'Comprar tinta',
        description: 'Adquirir tinta de qualidade',
        category: PreparationCategory.purchase,
        priority: PreparationPriority.high,
        isDone: false,
        tip: 'Compre toda a tinta do mesmo lote',
      ),
      const PreparationItemEntity(
        id: 'paint_3',
        title: 'Comprar massa corrida',
        description: 'Para preparação das paredes',
        category: PreparationCategory.purchase,
        priority: PreparationPriority.high,
        isDone: false,
      ),
      const PreparationItemEntity(
        id: 'paint_4',
        title: 'Contratar pintor',
        description: 'Profissional para executar a pintura',
        category: PreparationCategory.professional,
        priority: PreparationPriority.high,
        isDone: false,
        tip: 'Verifique se faz massa corrida',
      ),
      const PreparationItemEntity(
        id: 'paint_5',
        title: 'Verificar paredes',
        description: 'Garantir que não há infiltrações ou rachaduras',
        category: PreparationCategory.approval,
        priority: PreparationPriority.medium,
        isDone: false,
      ),
    ];
  }

  /// Checklist para Acabamentos
  List<PreparationItemEntity> _generateFinishingChecklist() {
    return [
      const PreparationItemEntity(
        id: 'finish_1',
        title: 'Escolher metais',
        description: 'Torneiras, chuveiros, registros',
        category: PreparationCategory.decision,
        priority: PreparationPriority.high,
        isDone: false,
        tip: 'Escolha todos da mesma linha',
      ),
      const PreparationItemEntity(
        id: 'finish_2',
        title: 'Escolher louças',
        description: 'Vasos, pias, cubas',
        category: PreparationCategory.decision,
        priority: PreparationPriority.high,
        isDone: false,
        tip: 'Verifique medidas antes de comprar',
      ),
      const PreparationItemEntity(
        id: 'finish_3',
        title: 'Escolher interruptores e tomadas',
        description: 'Definir linha e cor',
        category: PreparationCategory.decision,
        priority: PreparationPriority.high,
        isDone: false,
        tip: 'Escolha linha premium para durabilidade',
      ),
      const PreparationItemEntity(
        id: 'finish_4',
        title: 'Comprar metais',
        description: 'Adquirir torneiras e chuveiros',
        category: PreparationCategory.purchase,
        priority: PreparationPriority.high,
        isDone: false,
      ),
      const PreparationItemEntity(
        id: 'finish_5',
        title: 'Comprar louças',
        description: 'Adquirir vasos e pias',
        category: PreparationCategory.purchase,
        priority: PreparationPriority.high,
        isDone: false,
      ),
      const PreparationItemEntity(
        id: 'finish_6',
        title: 'Comprar interruptores',
        description: 'Adquirir acabamentos elétricos',
        category: PreparationCategory.purchase,
        priority: PreparationPriority.medium,
        isDone: false,
      ),
    ];
  }

  /// Checklist para Marcenaria
  List<PreparationItemEntity> _generateCarpentryChecklist() {
    return [
      const PreparationItemEntity(
        id: 'carp_1',
        title: 'AGUARDAR pintura e piso',
        description: 'NUNCA medir antes da conclusão',
        category: PreparationCategory.approval,
        priority: PreparationPriority.critical,
        isDone: false,
        tip: 'Medição errada = móveis que não encaixam',
      ),
      const PreparationItemEntity(
        id: 'carp_2',
        title: 'Definir projeto de marcenaria',
        description: 'Decidir quais móveis serão planejados',
        category: PreparationCategory.decision,
        priority: PreparationPriority.high,
        isDone: false,
      ),
      const PreparationItemEntity(
        id: 'carp_3',
        title: 'Solicitar orçamentos',
        description: 'Pedir pelo menos 3 orçamentos',
        category: PreparationCategory.professional,
        priority: PreparationPriority.high,
        isDone: false,
        tip: 'Compare qualidade, não só preço',
      ),
      const PreparationItemEntity(
        id: 'carp_4',
        title: 'Escolher marceneiro',
        description: 'Contratar profissional ou empresa',
        category: PreparationCategory.professional,
        priority: PreparationPriority.high,
        isDone: false,
        tip: 'Verifique prazo de entrega (30-60 dias)',
      ),
      const PreparationItemEntity(
        id: 'carp_5',
        title: 'Agendar medição final',
        description: 'Após pintura e piso concluídos',
        category: PreparationCategory.measurement,
        priority: PreparationPriority.high,
        isDone: false,
      ),
      const PreparationItemEntity(
        id: 'carp_6',
        title: 'Aprovar projeto executivo',
        description: 'Revisar desenhos técnicos',
        category: PreparationCategory.approval,
        priority: PreparationPriority.medium,
        isDone: false,
      ),
    ];
  }

  /// Calcula score de prontidão (0-100)
  int _calculateReadinessScore(
    List<PreparationItemEntity> checklist,
    ReformMapEntity reformMap,
  ) {
    if (checklist.isEmpty) return 100;

    // Peso por prioridade
    int totalWeight = 0;
    int completedWeight = 0;

    for (final item in checklist) {
      final weight = _getPriorityWeight(item.priority);
      totalWeight += weight;

      if (item.isDone) {
        completedWeight += weight;
      }
    }

    if (totalWeight == 0) return 100;

    return ((completedWeight / totalWeight) * 100).round();
  }

  /// Retorna peso da prioridade
  int _getPriorityWeight(PreparationPriority priority) {
    switch (priority) {
      case PreparationPriority.critical:
        return 4;
      case PreparationPriority.high:
        return 3;
      case PreparationPriority.medium:
        return 2;
      case PreparationPriority.low:
        return 1;
    }
  }

  /// Gera alertas importantes
  List<String> _generateAlerts(
    PhaseEntity nextPhase,
    List<PreparationItemEntity> checklist,
    ReformMapEntity reformMap,
  ) {
    final alerts = <String>[];

    // Verifica itens críticos pendentes
    final criticalPending = checklist
        .where((item) =>
            !item.isDone && item.priority == PreparationPriority.critical)
        .toList();

    if (criticalPending.isNotEmpty) {
      alerts.add(
        '${criticalPending.length} ${criticalPending.length == 1 ? 'item crítico pendente' : 'itens críticos pendentes'}',
      );
    }

    // Alertas específicos por fase
    switch (nextPhase.name.toLowerCase()) {
      case 'marcenaria':
        alerts.add(' NUNCA medir antes da pintura e piso prontos');
        break;

      case 'pisos e revestimentos':
        alerts.add(' Compre 10% a mais de piso para perdas');
        break;

      case 'infraestrutura':
        alerts.add(' Fase mais crítica - planeje bem os pontos');
        break;
    }

    return alerts;
  }

  /// Calcula dias até o início da próxima fase
  int _calculateDaysUntilStart(
    PhaseEntity currentPhase,
    PhaseEntity nextPhase,
  ) {
    // Estimativa baseada no progresso da fase atual
    // Por enquanto, retorna uma estimativa fixa
    // TODO: Calcular baseado no cronograma real

    if (currentPhase.progressPercentage >= 80) {
      return 7; // 1 semana
    } else if (currentPhase.progressPercentage >= 60) {
      return 14; // 2 semanas
    } else if (currentPhase.progressPercentage >= 40) {
      return 21; // 3 semanas
    } else {
      return 30; // 1 mês
    }
  }
}

// Made with Bob
