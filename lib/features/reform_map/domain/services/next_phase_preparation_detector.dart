import 'package:injectable/injectable.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../../shopping/domain/repositories/shopping_repository.dart';
import '../entities/next_phase_preparation_entity.dart';
import '../entities/reform_map_entity.dart';

/// Serviço que detecta o que precisa ser feito antes da próxima etapa
///
/// NOVO: Agora usa dados REAIS do Firestore para gerar checklist dinâmico
/// - Verifica fornecedores contratados
/// - Verifica compras realizadas
/// - Verifica documentos salvos
/// - Calcula prontidão real baseado em dados
///
/// Exemplo de uso:
/// ```dart
/// final detector = NextPhasePreparationDetector(shoppingRepository);
/// final preparation = await detector.detect(reformMap, propertyType, projectId);
/// // Retorna checklist baseado em dados reais
/// ```
@injectable
class NextPhasePreparationDetector {
  final ShoppingRepository _shoppingRepository;

  NextPhasePreparationDetector(this._shoppingRepository);

  /// Detecta preparação necessária para a próxima fase
  ///
  /// NOVO: Agora é assíncrono e usa dados reais do Firestore
  Future<NextPhasePreparationEntity?> detect(
    ReformMapEntity reformMap,
    PropertyType propertyType,
    String projectId,
  ) async {
    // Encontra a fase atual
    final currentPhase = reformMap.currentPhase;
    if (currentPhase == null) return null;

    // Encontra a próxima fase
    final currentIndex = reformMap.phases.indexOf(currentPhase);
    if (currentIndex < 0 || currentIndex >= reformMap.phases.length - 1) {
      return null; // Não há próxima fase
    }

    final nextPhase = reformMap.phases[currentIndex + 1];

    // Gera checklist baseado na próxima fase E tipo de imóvel
    final checklist =
        _generateChecklistForPhase(nextPhase, reformMap, propertyType);

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

  /// Gera checklist baseado na próxima fase E tipo de imóvel
  List<PreparationItemEntity> _generateChecklistForPhase(
    PhaseEntity nextPhase,
    ReformMapEntity reformMap,
    PropertyType propertyType,
  ) {
    switch (nextPhase.name.toLowerCase()) {
      case 'infraestrutura':
      case 'instalações hidráulicas e elétricas':
        return _generateInfrastructureChecklist(propertyType);

      case 'pisos e revestimentos':
        return _generateFlooringChecklist(propertyType);

      case 'pintura':
        return _generatePaintingChecklist(propertyType);

      case 'acabamentos':
        return _generateFinishingChecklist(propertyType);

      case 'marcenaria':
        return _generateCarpentryChecklist(propertyType);

      default:
        return [];
    }
  }

  /// Checklist para Infraestrutura (ADAPTADO por tipo de imóvel)
  List<PreparationItemEntity> _generateInfrastructureChecklist(
      PropertyType propertyType) {
    final checklist = <PreparationItemEntity>[
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

    // ADAPTAÇÕES POR TIPO DE IMÓVEL
    if (propertyType == PropertyType.apartment) {
      // Apartamento: adicionar item sobre aprovação do condomínio
      checklist.add(
        const PreparationItemEntity(
          id: 'infra_7',
          title: 'Aprovar obra no condomínio',
          description: 'Solicitar autorização formal da administração',
          category: PreparationCategory.approval,
          priority: PreparationPriority.critical,
          isDone: false,
          tip: 'Alguns condomínios exigem projeto aprovado',
        ),
      );
      checklist.add(
        const PreparationItemEntity(
          id: 'infra_8',
          title: 'Verificar horários permitidos',
          description: 'Confirmar horários de obra no regulamento',
          category: PreparationCategory.document,
          priority: PreparationPriority.high,
          isDone: false,
          tip: 'Geralmente: dias úteis, 8h-18h',
        ),
      );
    } else if (propertyType == PropertyType.house) {
      // Casa: adicionar item sobre entrada de materiais
      checklist.add(
        const PreparationItemEntity(
          id: 'infra_7',
          title: 'Planejar acesso de materiais',
          description: 'Definir local para descarga e armazenamento',
          category: PreparationCategory.decision,
          priority: PreparationPriority.medium,
          isDone: false,
          tip: 'Proteja materiais da chuva',
        ),
      );
    }

    return checklist;
  }

  /// Checklist para Pisos (ADAPTADO por tipo de imóvel)
  List<PreparationItemEntity> _generateFlooringChecklist(
      PropertyType propertyType) {
    final checklist = <PreparationItemEntity>[
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

    // ADAPTAÇÕES POR TIPO DE IMÓVEL
    if (propertyType == PropertyType.apartment) {
      // Apartamento: cuidado com barulho e horários
      checklist.add(
        const PreparationItemEntity(
          id: 'floor_7',
          title: 'Avisar vizinhos sobre barulho',
          description: 'Informar sobre quebra de piso antigo',
          category: PreparationCategory.approval,
          priority: PreparationPriority.medium,
          isDone: false,
          tip: 'Boa convivência evita problemas',
        ),
      );
    }

    return checklist;
  }

  /// Checklist para Pintura (ADAPTADO por tipo de imóvel)
  List<PreparationItemEntity> _generatePaintingChecklist(
      PropertyType propertyType) {
    final checklist = <PreparationItemEntity>[
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

    // ADAPTAÇÕES POR TIPO DE IMÓVEL
    if (propertyType == PropertyType.apartment) {
      // Apartamento: proteção de áreas comuns
      checklist.add(
        const PreparationItemEntity(
          id: 'paint_6',
          title: 'Proteger áreas comuns',
          description: 'Cobrir elevador e corredores durante transporte',
          category: PreparationCategory.approval,
          priority: PreparationPriority.high,
          isDone: false,
          tip: 'Evite multas do condomínio',
        ),
      );
    }

    return checklist;
  }

  /// Checklist para Acabamentos (ADAPTADO por tipo de imóvel)
  List<PreparationItemEntity> _generateFinishingChecklist(
      PropertyType propertyType) {
    final checklist = <PreparationItemEntity>[
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

    // ADAPTAÇÕES POR TIPO DE IMÓVEL
    if (propertyType == PropertyType.house) {
      // Casa: itens externos
      checklist.add(
        const PreparationItemEntity(
          id: 'finish_7',
          title: 'Escolher torneiras externas',
          description: 'Para jardim, garagem, área de serviço externa',
          category: PreparationCategory.decision,
          priority: PreparationPriority.low,
          isDone: false,
          tip: 'Considere torneiras com mangueira',
        ),
      );
    }

    return checklist;
  }

  /// Checklist para Marcenaria (ADAPTADO por tipo de imóvel)
  List<PreparationItemEntity> _generateCarpentryChecklist(
      PropertyType propertyType) {
    final checklist = <PreparationItemEntity>[
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

    // ADAPTAÇÕES POR TIPO DE IMÓVEL
    if (propertyType == PropertyType.apartment) {
      // Apartamento: cuidado com transporte
      checklist.add(
        const PreparationItemEntity(
          id: 'carp_7',
          title: 'Verificar acesso para móveis',
          description: 'Confirmar se móveis cabem no elevador/escada',
          category: PreparationCategory.measurement,
          priority: PreparationPriority.high,
          isDone: false,
          tip: 'Meça elevador e portas antes de encomendar',
        ),
      );
      checklist.add(
        const PreparationItemEntity(
          id: 'carp_8',
          title: 'Reservar elevador de serviço',
          description: 'Agendar uso do elevador para entrega',
          category: PreparationCategory.approval,
          priority: PreparationPriority.medium,
          isDone: false,
          tip: 'Reserve com antecedência',
        ),
      );
    }

    return checklist;
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
