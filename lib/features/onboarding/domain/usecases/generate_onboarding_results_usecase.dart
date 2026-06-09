import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../entities/onboarding_results_entity.dart';
import '../entities/critical_alert_entity.dart';
import '../entities/checklist_item_entity.dart';
import '../../presentation/cubit/onboarding_state.dart';

/// UseCase que gera todos os resultados do onboarding
/// Baseado nas respostas dos 14 steps
@injectable
class GenerateOnboardingResultsUseCase {
  final _uuid = const Uuid();

  OnboardingResultsEntity call(OnboardingInProgress state) {
    return OnboardingResultsEntity(
      nextAction: _generateNextAction(state),
      nextActionDescription: _generateNextActionDescription(state),
      criticalAlerts: _generateCriticalAlerts(state),
      checklistsByRoom: _generateChecklistsByRoom(state),
      suggestions: _generateSuggestions(state),
      initialHealthScore: _calculateInitialHealth(state),
      estimatedDurationDays: _estimateDuration(state),
      phaseConfiguration: _generatePhaseConfiguration(state),
    );
  }

  /// Gera a próxima ação baseada na situação atual
  String _generateNextAction(OnboardingInProgress state) {
    switch (state.currentSituation) {
      case 'not_received_keys':
        return 'Agendar vistoria pré-entrega';
      case 'just_received':
      case 'planning':
        return 'Contratar arquiteto ou designer';
      case 'hiring':
        return 'Fechar orçamentos e contratos';
      case 'started':
        return 'Acompanhar instalações elétricas e hidráulicas';
      case 'finishing':
        return 'Verificar acabamentos e revestimentos';
      case 'furnishing':
        return 'Coordenar entrega de móveis';
      case 'moving':
        return 'Fazer limpeza final';
      default:
        return 'Definir escopo da reforma';
    }
  }

  String _generateNextActionDescription(OnboardingInProgress state) {
    switch (state.currentSituation) {
      case 'not_received_keys':
        return 'Antes de receber as chaves, faça uma vistoria completa com checklist para identificar problemas de construção.';
      case 'just_received':
      case 'planning':
        return 'Um profissional vai te ajudar a definir o melhor layout e evitar erros caros.';
      case 'hiring':
        return 'Compare pelo menos 3 orçamentos e verifique referências antes de contratar.';
      case 'started':
        return 'Esta é a fase mais crítica. Verifique se tudo está sendo feito conforme o projeto.';
      case 'finishing':
        return 'Confira cada detalhe dos acabamentos antes de aprovar o pagamento.';
      case 'furnishing':
        return 'Organize as entregas para não ter móveis parados esperando instalação.';
      case 'moving':
        return 'Uma boa limpeza faz toda diferença na hora de se mudar.';
      default:
        return 'Vamos te ajudar a organizar tudo passo a passo.';
    }
  }

  /// Gera alertas críticos baseados no Step 14
  List<CriticalAlertEntity> _generateCriticalAlerts(
      OnboardingInProgress state) {
    final alerts = <CriticalAlertEntity>[];

    for (final item in state.criticalInfrastructure) {
      switch (item) {
        case 'air_conditioning':
          alerts.add(CriticalAlertEntity(
            id: _uuid.v4(),
            title: '⚠️ CRÍTICO: Ar-Condicionado',
            message: 'Infraestrutura deve ser feita AGORA, antes da pintura',
            phase: 'Instalações hidráulicas e elétricas',
            priority: AlertPriority.critical,
            tasks: [
              'Definir localização das unidades',
              'Prever dreno',
              'Instalar ponto elétrico específico (220V)',
              'Deixar tubulação pronta',
            ],
            estimatedCost: 'R\$ 500-1.500 por ponto',
            reworkCost: 'R\$ 2.000-5.000 (quebrar e refazer)',
          ));
          break;

        case 'dishwasher':
          alerts.add(CriticalAlertEntity(
            id: _uuid.v4(),
            title: '⚠️ CRÍTICO: Lava-Louças',
            message: 'Ponto de água e elétrica devem ser feitos AGORA',
            phase: 'Instalações hidráulicas e elétricas',
            priority: AlertPriority.critical,
            tasks: [
              'Ponto de água quente/fria',
              'Ponto elétrico 220V',
              'Espaço no armário (60cm)',
              'Ponto de esgoto',
            ],
            estimatedCost: 'R\$ 300-800',
            reworkCost: 'R\$ 1.500-3.000',
          ));
          break;

        case 'water_heater':
          alerts.add(CriticalAlertEntity(
            id: _uuid.v4(),
            title: '⚠️ CRÍTICO: Aquecedor',
            message: 'Tubulação de água quente deve ser feita AGORA',
            phase: 'Instalações hidráulicas e elétricas',
            priority: AlertPriority.critical,
            tasks: [
              'Definir tipo (elétrico/gás/solar)',
              'Tubulação de água quente',
              'Ponto elétrico ou gás',
              'Espaço para instalação',
            ],
            estimatedCost: 'R\$ 800-2.000',
            reworkCost: 'R\$ 3.000-8.000',
          ));
          break;

        case 'home_automation':
          alerts.add(CriticalAlertEntity(
            id: _uuid.v4(),
            title: '⚠️ CRÍTICO: Automação Residencial',
            message: 'Infraestrutura deve ser feita AGORA',
            phase: 'Instalações hidráulicas e elétricas',
            priority: AlertPriority.critical,
            tasks: [
              'Definir sistema (Alexa/Google/Apple)',
              'Prever neutro em todos os interruptores',
              'Eletrodutos extras para sensores',
              'Ponto de internet em cada ambiente',
            ],
            estimatedCost: 'R\$ 1.500-5.000',
            reworkCost: 'R\$ 5.000-15.000',
          ));
          break;

        case 'solar_energy':
          alerts.add(CriticalAlertEntity(
            id: _uuid.v4(),
            title: '⚠️ CRÍTICO: Energia Solar',
            message: 'Infraestrutura elétrica deve ser preparada AGORA',
            phase: 'Instalações hidráulicas e elétricas',
            priority: AlertPriority.critical,
            tasks: [
              'Quadro elétrico preparado',
              'Eletroduto do telhado ao quadro',
              'Espaço para inversor',
              'Estrutura no telhado',
            ],
            estimatedCost: 'R\$ 2.000-5.000',
            reworkCost: 'R\$ 8.000-20.000',
          ));
          break;

        case 'wired_internet':
          alerts.add(CriticalAlertEntity(
            id: _uuid.v4(),
            title: '⚠️ CRÍTICO: Internet Cabeada',
            message: 'Eletrodutos devem ser instalados AGORA',
            phase: 'Instalações hidráulicas e elétricas',
            priority: AlertPriority.critical,
            tasks: [
              'Eletroduto em todos os ambientes',
              'Rack de rede centralizado',
              'Pontos de internet em cada cômodo',
              'Prever TV a cabo',
            ],
            estimatedCost: 'R\$ 800-2.500',
            reworkCost: 'R\$ 3.000-8.000',
          ));
          break;

        case 'smart_lock':
          alerts.add(CriticalAlertEntity(
            id: _uuid.v4(),
            title: '⚠️ IMPORTANTE: Fechadura Eletrônica',
            message: 'Ponto elétrico na porta deve ser previsto',
            phase: 'Instalações hidráulicas e elétricas',
            priority: AlertPriority.high,
            tasks: [
              'Ponto elétrico próximo à porta',
              'Verificar compatibilidade da porta',
              'Prever internet se for smart',
            ],
            estimatedCost: 'R\$ 200-500',
            reworkCost: 'R\$ 800-1.500',
          ));
          break;

        case 'cameras':
          alerts.add(CriticalAlertEntity(
            id: _uuid.v4(),
            title: '⚠️ IMPORTANTE: Câmeras de Segurança',
            message: 'Infraestrutura deve ser feita AGORA',
            phase: 'Instalações hidráulicas e elétricas',
            priority: AlertPriority.high,
            tasks: [
              'Eletrodutos para câmeras externas',
              'Pontos de energia',
              'Rede cabeada ou WiFi forte',
              'DVR/NVR centralizado',
            ],
            estimatedCost: 'R\$ 500-1.500',
            reworkCost: 'R\$ 2.000-5.000',
          ));
          break;

        case 'ambient_sound':
          alerts.add(CriticalAlertEntity(
            id: _uuid.v4(),
            title: '⚠️ IMPORTANTE: Som Ambiente',
            message: 'Fiação deve ser embutida AGORA',
            phase: 'Instalações hidráulicas e elétricas',
            priority: AlertPriority.high,
            tasks: [
              'Eletrodutos para caixas de som',
              'Fiação de áudio',
              'Ponto central para amplificador',
              'Prever tomadas',
            ],
            estimatedCost: 'R\$ 400-1.200',
            reworkCost: 'R\$ 1.500-4.000',
          ));
          break;
      }
    }

    // NOVOS ALERTAS PREVENTIVOS (baseados nos steps do onboarding)

    // Alerta de Móveis Planejados (Step 11)
    if (state.hasCustomFurniture == 'yes' ||
        state.hasCustomFurniture == 'some') {
      alerts.add(CriticalAlertEntity(
        id: _uuid.v4(),
        title: '⏰ ATENÇÃO: Móveis Planejados',
        message: 'Prazo de 60-90 dias. Faça medições APÓS acabamentos prontos',
        phase: 'Acabamentos e revestimentos',
        priority: AlertPriority.high,
        tasks: [
          'Aguardar piso e rodapés instalados',
          'Medir com precisão milimétrica',
          'Confirmar prazo de entrega (60-90 dias)',
          'Agendar instalação com antecedência',
          'Verificar se portas e janelas estão no lugar',
        ],
        estimatedCost: 'Varia por projeto',
        reworkCost: 'R\$ 5.000-20.000 (refazer móveis)',
      ));
    }

    // Alerta de Piso (baseado em reforma parcial ou completa)
    if (state.reformLevel == 'partial' || state.reformLevel == 'complete') {
      alerts.add(CriticalAlertEntity(
        id: _uuid.v4(),
        title: '⚠️ CRÍTICO: Instalação de Piso',
        message: 'Nivelamento e tempo de cura são ESSENCIAIS',
        phase: 'Acabamentos e revestimentos',
        priority: AlertPriority.critical,
        tasks: [
          'Verificar nivelamento do contrapiso',
          'Aguardar cura do contrapiso (7-14 dias)',
          'Usar argamassa de qualidade',
          'Prever juntas de dilatação',
          'Aguardar 72h antes de pisar',
          'Instalar rodapés após o piso',
        ],
        estimatedCost: 'R\$ 50-200/m²',
        reworkCost: 'R\$ 10.000-30.000 (refazer tudo)',
      ));
    }

    // Alerta de Tomadas Insuficientes (sempre importante)
    final roomCount = state.selectedRooms.length;
    if (roomCount > 0) {
      alerts.add(CriticalAlertEntity(
        id: _uuid.v4(),
        title: '⚡ IMPORTANTE: Tomadas Elétricas',
        message: 'Preveja mais tomadas do que acha necessário',
        phase: 'Instalações hidráulicas e elétricas',
        priority: AlertPriority.high,
        tasks: [
          'Mínimo 2 tomadas por parede em salas/quartos',
          'Tomadas USB em quartos e sala',
          'Tomadas altas para TVs e quadros',
          'Tomadas extras para aspirador',
          'Circuitos separados para ar-condicionado',
          'Prever tomadas para móveis planejados',
        ],
        estimatedCost: 'R\$ 50-100 por tomada',
        reworkCost: 'R\$ 200-500 por tomada (quebrar parede)',
      ));
    }

    // Alerta de Wi-Fi (se não marcou internet cabeada)
    if (!state.criticalInfrastructure.contains('wired_internet')) {
      alerts.add(CriticalAlertEntity(
        id: _uuid.v4(),
        title: '📶 ATENÇÃO: Cobertura Wi-Fi',
        message: 'Paredes de concreto bloqueiam sinal. Planeje a rede',
        phase: 'Instalações hidráulicas e elétricas',
        priority: AlertPriority.medium,
        tasks: [
          'Posicionar roteador em local central',
          'Considerar repetidores ou mesh',
          'Prever eletrodutos se quiser cabeamento futuro',
          'Testar cobertura antes de fechar paredes',
          'Evitar colocar roteador em armários fechados',
        ],
        estimatedCost: 'R\$ 300-1.500 (repetidores/mesh)',
        reworkCost: 'R\$ 2.000-5.000 (cabear depois)',
      ));
    }

    return alerts;
  }

  /// Gera checklists por ambiente baseado no Step 6
  Map<String, List<ChecklistItemEntity>> _generateChecklistsByRoom(
    OnboardingInProgress state,
  ) {
    final checklists = <String, List<ChecklistItemEntity>>{};

    for (final room in state.selectedRooms) {
      switch (room) {
        case 'living_room':
          checklists['Sala'] = _generateLivingRoomChecklist(state);
          break;
        case 'kitchen':
          checklists['Cozinha'] = _generateKitchenChecklist(state);
          break;
        case 'laundry':
          checklists['Lavanderia'] = _generateLaundryChecklist(state);
          break;
        case 'bathroom':
          checklists['Banheiro'] = _generateBathroomChecklist(state);
          break;
        case 'bedroom':
          checklists['Quarto'] = _generateBedroomChecklist(state);
          break;
        case 'office':
          checklists['Escritório'] = _generateOfficeChecklist(state);
          break;
        case 'balcony':
          checklists['Varanda'] = _generateBalconyChecklist(state);
          break;
      }
    }

    return checklists;
  }

  List<ChecklistItemEntity> _generateLivingRoomChecklist(
      OnboardingInProgress state) {
    return [
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Sofá',
        category: 'Móveis',
        room: 'Sala',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Rack/Estante TV',
        category: 'Móveis',
        room: 'Sala',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Mesa de centro',
        category: 'Móveis',
        room: 'Sala',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Cortina/Persiana',
        category: 'Acabamentos',
        room: 'Sala',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Luminária',
        category: 'Iluminação',
        room: 'Sala',
      ),
      if (state.criticalInfrastructure.contains('air_conditioning'))
        ChecklistItemEntity(
          id: _uuid.v4(),
          name: 'Ar-condicionado',
          category: 'Equipamentos',
          room: 'Sala',
          isCritical: true,
        ),
    ];
  }

  List<ChecklistItemEntity> _generateKitchenChecklist(
      OnboardingInProgress state) {
    return [
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Geladeira',
        category: 'Eletrodomésticos',
        room: 'Cozinha',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Fogão/Cooktop',
        category: 'Eletrodomésticos',
        room: 'Cozinha',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Micro-ondas',
        category: 'Eletrodomésticos',
        room: 'Cozinha',
      ),
      if (state.criticalInfrastructure.contains('dishwasher'))
        ChecklistItemEntity(
          id: _uuid.v4(),
          name: 'Lava-louças',
          category: 'Eletrodomésticos',
          room: 'Cozinha',
          isCritical: true,
        ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Armários',
        category: 'Móveis',
        room: 'Cozinha',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Bancada',
        category: 'Móveis',
        room: 'Cozinha',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Cuba',
        category: 'Acabamentos',
        room: 'Cozinha',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Torneira',
        category: 'Acabamentos',
        room: 'Cozinha',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Revestimento',
        category: 'Acabamentos',
        room: 'Cozinha',
      ),
    ];
  }

  List<ChecklistItemEntity> _generateLaundryChecklist(
      OnboardingInProgress state) {
    return [
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Máquina de lavar',
        category: 'Eletrodomésticos',
        room: 'Lavanderia',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Tanque',
        category: 'Louças',
        room: 'Lavanderia',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Armário',
        category: 'Móveis',
        room: 'Lavanderia',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Varal/Secadora',
        category: 'Equipamentos',
        room: 'Lavanderia',
      ),
    ];
  }

  List<ChecklistItemEntity> _generateBathroomChecklist(
      OnboardingInProgress state) {
    return [
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Chuveiro',
        category: 'Metais',
        room: 'Banheiro',
      ),
      if (state.criticalInfrastructure.contains('water_heater'))
        ChecklistItemEntity(
          id: _uuid.v4(),
          name: 'Aquecedor',
          category: 'Equipamentos',
          room: 'Banheiro',
          isCritical: true,
        ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Torneira',
        category: 'Metais',
        room: 'Banheiro',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Vaso sanitário',
        category: 'Louças',
        room: 'Banheiro',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Pia',
        category: 'Louças',
        room: 'Banheiro',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Espelho',
        category: 'Acabamentos',
        room: 'Banheiro',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Nicho',
        category: 'Acabamentos',
        room: 'Banheiro',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Revestimento',
        category: 'Acabamentos',
        room: 'Banheiro',
      ),
    ];
  }

  List<ChecklistItemEntity> _generateBedroomChecklist(
      OnboardingInProgress state) {
    return [
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Cama',
        category: 'Móveis',
        room: 'Quarto',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Guarda-roupa',
        category: 'Móveis',
        room: 'Quarto',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Criado-mudo',
        category: 'Móveis',
        room: 'Quarto',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Cortina/Persiana',
        category: 'Acabamentos',
        room: 'Quarto',
      ),
      if (state.criticalInfrastructure.contains('air_conditioning'))
        ChecklistItemEntity(
          id: _uuid.v4(),
          name: 'Ar-condicionado',
          category: 'Equipamentos',
          room: 'Quarto',
          isCritical: true,
        ),
    ];
  }

  List<ChecklistItemEntity> _generateOfficeChecklist(
      OnboardingInProgress state) {
    return [
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Mesa',
        category: 'Móveis',
        room: 'Escritório',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Cadeira ergonômica',
        category: 'Móveis',
        room: 'Escritório',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Estante/Armário',
        category: 'Móveis',
        room: 'Escritório',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Iluminação adequada',
        category: 'Iluminação',
        room: 'Escritório',
      ),
      if (state.criticalInfrastructure.contains('wired_internet'))
        ChecklistItemEntity(
          id: _uuid.v4(),
          name: 'Pontos de internet',
          category: 'Infraestrutura',
          room: 'Escritório',
          isCritical: true,
        ),
    ];
  }

  List<ChecklistItemEntity> _generateBalconyChecklist(
      OnboardingInProgress state) {
    return [
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Mesa/Cadeiras',
        category: 'Móveis',
        room: 'Varanda',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Churrasqueira',
        category: 'Equipamentos',
        room: 'Varanda',
      ),
      ChecklistItemEntity(
        id: _uuid.v4(),
        name: 'Iluminação',
        category: 'Iluminação',
        room: 'Varanda',
      ),
      if (state.hasPets == true)
        ChecklistItemEntity(
          id: _uuid.v4(),
          name: 'Tela de proteção',
          category: 'Segurança',
          room: 'Varanda',
          isCritical: true,
        ),
    ];
  }

  List<String> _generateSuggestions(OnboardingInProgress state) {
    final suggestions = <String>[];

    // Baseado em prioridades
    if (state.priorities.contains('save_money')) {
      suggestions.add('Compare preços em pelo menos 3 lojas diferentes');
      suggestions.add('Considere materiais alternativos de boa qualidade');
    }

    if (state.priorities.contains('finish_faster')) {
      suggestions.add('Tenha todos os materiais antes de começar');
      suggestions.add('Contrate profissionais com disponibilidade imediata');
    }

    if (state.priorities.contains('better_finish')) {
      suggestions.add('Invista em bons profissionais');
      suggestions.add('Não economize em materiais de acabamento');
    }

    // Baseado em pets
    if (state.hasPets == true) {
      suggestions.add('Escolha pisos resistentes a arranhões');
      suggestions.add('Instale telas de proteção nas janelas');
    }

    // Baseado em home office
    if (state.hasHomeOffice == true) {
      suggestions.add('Preveja pontos de internet extras');
      suggestions.add('Invista em boa iluminação no escritório');
    }

    return suggestions;
  }

  double _calculateInitialHealth(OnboardingInProgress state) {
    double score = 50.0; // Base

    // Situação atual
    switch (state.currentSituation) {
      case 'not_received_keys':
        score += 20; // Começando cedo é bom
        break;
      case 'just_received':
      case 'planning':
        score += 15;
        break;
      case 'started':
        score += 5;
        break;
      default:
        score += 0;
    }

    // Tem orçamento definido
    if (state.budgetRange != null && state.budgetRange != 'unknown') {
      score += 10;
    }

    // Marcou itens críticos
    if (state.criticalInfrastructure.isNotEmpty) {
      score += 15; // Prevenir é melhor que remediar
    }

    // Selecionou ambientes
    if (state.selectedRooms.isNotEmpty) {
      score += 5;
    }

    return score.clamp(0, 100);
  }

  int _estimateDuration(OnboardingInProgress state) {
    int days = 0;

    switch (state.reformLevel) {
      case 'just_furnish':
        days = 30;
        break;
      case 'small_improvements':
        days = 60;
        break;
      case 'partial':
        days = 90;
        break;
      case 'complete':
        days = 120;
        break;
      default:
        days = 90;
    }

    // Ajustar por tamanho
    switch (state.propertySize) {
      case 'up_to_40':
        days = (days * 0.8).round();
        break;
      case 'above_120':
        days = (days * 1.3).round();
        break;
    }

    return days;
  }

  Map<String, dynamic> _generatePhaseConfiguration(OnboardingInProgress state) {
    return {
      'skipPhases': state.reformLevel == 'just_furnish' ? [6, 7, 8, 9] : [],
      'currentPhase': _mapSituationToPhase(state.currentSituation ?? ''),
      'completedPhases': state.completedItems,
    };
  }

  int _mapSituationToPhase(String situation) {
    switch (situation) {
      case 'not_received_keys':
        return 4;
      case 'just_received':
      case 'planning':
        return 6;
      case 'hiring':
        return 7;
      case 'started':
        return 8;
      case 'finishing':
        return 9;
      case 'furnishing':
        return 10;
      case 'moving':
        return 12;
      default:
        return 6;
    }
  }
}

// Made with Bob
