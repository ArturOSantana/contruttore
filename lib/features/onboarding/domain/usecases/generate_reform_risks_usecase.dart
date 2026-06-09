import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../entities/reform_risk_entity.dart';
import '../../presentation/cubit/onboarding_state.dart';

/// UseCase que identifica riscos da reforma baseado nas respostas do onboarding
@injectable
class GenerateReformRisksUseCase {
  final _uuid = const Uuid();

  List<ReformRiskEntity> call(OnboardingInProgress state) {
    final risks = <ReformRiskEntity>[];

    // 1. Riscos de infraestrutura crítica (Alto risco)
    risks.addAll(_generateInfrastructureRisks(state));

    // 2. Riscos de planejados (Médio risco)
    risks.addAll(_generateCustomFurnitureRisks(state));

    // 3. Riscos de piso e revestimento (Médio risco)
    risks.addAll(_generateFlooringRisks(state));

    // 4. Riscos de tomadas e elétrica (Médio risco)
    risks.addAll(_generateElectricalRisks(state));

    // 5. Riscos de Wi-Fi (Baixo risco)
    risks.addAll(_generateWiFiRisks(state));

    // 6. Riscos de coordenação (variável)
    risks.addAll(_generateManagementRisks(state));

    // 7. Riscos de prazo (variável)
    risks.addAll(_generateDeadlineRisks(state));

    return risks;
  }

  /// Gera riscos de infraestrutura crítica
  List<ReformRiskEntity> _generateInfrastructureRisks(
      OnboardingInProgress state) {
    final risks = <ReformRiskEntity>[];

    for (final item in state.criticalInfrastructure) {
      switch (item) {
        case 'air_conditioning':
          risks.add(ReformRiskEntity(
            id: _uuid.v4(),
            title: 'Infraestrutura do ar-condicionado',
            description:
                'Pontos elétricos, drenos e tubulação devem ser instalados ANTES da pintura. Fazer depois custa 3-5x mais.',
            severity: RiskSeverity.high,
            relatedPhaseId: 'phase_8', // Instalações
            preventionActions: [
              'Definir localização das unidades agora',
              'Instalar dreno durante a fase de instalações',
              'Prever ponto elétrico 220V específico',
              'Deixar tubulação pronta antes da pintura',
            ],
          ));
          break;

        case 'dishwasher':
          risks.add(ReformRiskEntity(
            id: _uuid.v4(),
            title: 'Lava-louças',
            description:
                'Ponto de água quente/fria e elétrica 220V devem ser instalados na fase de instalações.',
            severity: RiskSeverity.high,
            relatedPhaseId: 'phase_8',
            preventionActions: [
              'Prever ponto de água quente e fria',
              'Instalar ponto elétrico 220V',
              'Reservar espaço de 60cm no armário',
              'Prever ponto de esgoto',
            ],
          ));
          break;

        case 'water_heater':
          risks.add(ReformRiskEntity(
            id: _uuid.v4(),
            title: 'Aquecedor de água',
            description:
                'Tubulação de água quente deve ser instalada durante as instalações hidráulicas.',
            severity: RiskSeverity.high,
            relatedPhaseId: 'phase_8',
            preventionActions: [
              'Definir tipo (elétrico/gás/solar)',
              'Instalar tubulação de água quente',
              'Prever ponto elétrico ou gás',
              'Reservar espaço para instalação',
            ],
          ));
          break;

        case 'home_automation':
          risks.add(ReformRiskEntity(
            id: _uuid.v4(),
            title: 'Automação residencial',
            description:
                'Infraestrutura elétrica específica deve ser instalada antes dos acabamentos.',
            severity: RiskSeverity.high,
            relatedPhaseId: 'phase_8',
            preventionActions: [
              'Definir sistema (Alexa/Google/Apple)',
              'Prever neutro em todos os interruptores',
              'Instalar eletrodutos extras para sensores',
              'Garantir ponto de internet em cada ambiente',
            ],
          ));
          break;

        case 'solar_energy':
          risks.add(ReformRiskEntity(
            id: _uuid.v4(),
            title: 'Energia solar',
            description:
                'Quadro elétrico e infraestrutura devem ser preparados durante as instalações elétricas.',
            severity: RiskSeverity.high,
            relatedPhaseId: 'phase_8',
            preventionActions: [
              'Preparar quadro elétrico adequado',
              'Instalar eletroduto do telhado ao quadro',
              'Reservar espaço para inversor',
              'Verificar estrutura do telhado',
            ],
          ));
          break;

        case 'wired_internet':
          risks.add(ReformRiskEntity(
            id: _uuid.v4(),
            title: 'Internet cabeada',
            description:
                'Eletrodutos para rede devem ser instalados antes do fechamento das paredes.',
            severity: RiskSeverity.high,
            relatedPhaseId: 'phase_8',
            preventionActions: [
              'Instalar eletroduto em todos os ambientes',
              'Prever rack de rede centralizado',
              'Garantir pontos de internet em cada cômodo',
              'Considerar TV a cabo',
            ],
          ));
          break;

        case 'smart_lock':
          risks.add(ReformRiskEntity(
            id: _uuid.v4(),
            title: 'Fechadura eletrônica',
            description:
                'Ponto elétrico próximo à porta deve ser previsto durante as instalações.',
            severity: RiskSeverity.high,
            relatedPhaseId: 'phase_8',
            preventionActions: [
              'Instalar ponto elétrico próximo à porta',
              'Verificar compatibilidade da porta',
              'Prever internet se for smart lock',
            ],
          ));
          break;

        case 'cameras':
          risks.add(ReformRiskEntity(
            id: _uuid.v4(),
            title: 'Câmeras de segurança',
            description:
                'Eletrodutos e pontos de energia devem ser instalados antes dos acabamentos.',
            severity: RiskSeverity.high,
            relatedPhaseId: 'phase_8',
            preventionActions: [
              'Instalar eletrodutos para câmeras externas',
              'Prever pontos de energia',
              'Garantir rede cabeada ou WiFi forte',
              'Reservar espaço para DVR/NVR',
            ],
          ));
          break;

        case 'ambient_sound':
          risks.add(ReformRiskEntity(
            id: _uuid.v4(),
            title: 'Som ambiente',
            description:
                'Fiação de áudio deve ser embutida antes do fechamento das paredes.',
            severity: RiskSeverity.high,
            relatedPhaseId: 'phase_8',
            preventionActions: [
              'Instalar eletrodutos para caixas de som',
              'Passar fiação de áudio',
              'Prever ponto central para amplificador',
              'Garantir tomadas adequadas',
            ],
          ));
          break;
      }
    }

    return risks;
  }

  /// Gera riscos relacionados a móveis planejados
  List<ReformRiskEntity> _generateCustomFurnitureRisks(
      OnboardingInProgress state) {
    final risks = <ReformRiskEntity>[];

    if (state.hasCustomFurniture == 'yes' ||
        state.hasCustomFurniture == 'some') {
      risks.add(ReformRiskEntity(
        id: _uuid.v4(),
        title: 'Planejados sem medição final',
        description:
            'NUNCA aprove a fabricação dos planejados antes da medição final. Paredes podem ter variações de até 5cm.',
        severity: RiskSeverity.medium,
        relatedPhaseId: 'phase_10', // Marcenaria
        preventionActions: [
          'Aguardar conclusão de alvenaria e reboco',
          'Fazer medição final após pintura',
          'Conferir medidas em 3 pontos diferentes',
          'Só aprovar fabricação após medição final',
        ],
      ));
    }

    return risks;
  }

  /// Gera riscos relacionados a piso e revestimento
  List<ReformRiskEntity> _generateFlooringRisks(OnboardingInProgress state) {
    final risks = <ReformRiskEntity>[];

    if (state.selectedRooms.isNotEmpty) {
      risks.add(ReformRiskEntity(
        id: _uuid.v4(),
        title: 'Compra insuficiente de revestimento',
        description:
            'Recomendamos comprar 10% a mais de piso e revestimento para futuras reposições e quebras.',
        severity: RiskSeverity.low,
        relatedPhaseId: 'phase_9', // Revestimentos
        preventionActions: [
          'Calcular área total com precisão',
          'Adicionar 10% para quebras e reposição',
          'Guardar peças extras para o futuro',
          'Anotar lote e referência do produto',
        ],
      ));
    }

    return risks;
  }

  /// Gera riscos relacionados a instalações elétricas
  List<ReformRiskEntity> _generateElectricalRisks(OnboardingInProgress state) {
    final risks = <ReformRiskEntity>[];

    // Se tem home office ou muitos eletrônicos
    if (state.hasHomeOffice == true) {
      risks.add(ReformRiskEntity(
        id: _uuid.v4(),
        title: 'Poucas tomadas no escritório',
        description:
            'Home office requer mais tomadas do que o padrão. Preveja tomadas extras e pontos USB.',
        severity: RiskSeverity.medium,
        relatedPhaseId: 'phase_8',
        preventionActions: [
          'Prever pelo menos 6 tomadas no escritório',
          'Instalar tomadas USB',
          'Considerar pontos de rede cabeada',
          'Prever circuito dedicado para equipamentos',
        ],
      ));
    }

    return risks;
  }

  /// Gera riscos relacionados a Wi-Fi
  List<ReformRiskEntity> _generateWiFiRisks(OnboardingInProgress state) {
    final risks = <ReformRiskEntity>[];

    // Se o imóvel é grande (>80m²)
    final size = state.propertySize;
    if (size == 'medium' || size == 'large' || size == 'very_large') {
      risks.add(ReformRiskEntity(
        id: _uuid.v4(),
        title: 'Cobertura Wi-Fi insuficiente',
        description:
            'Apartamentos maiores costumam precisar de mais de um ponto Wi-Fi para cobertura adequada.',
        severity: RiskSeverity.low,
        relatedPhaseId: 'phase_8',
        preventionActions: [
          'Considerar sistema mesh ou access points',
          'Prever pontos de rede em locais estratégicos',
          'Testar cobertura antes de fechar paredes',
          'Considerar repetidores ou roteadores adicionais',
        ],
      ));
    }

    return risks;
  }

  /// Gera riscos relacionados à coordenação da obra
  List<ReformRiskEntity> _generateManagementRisks(OnboardingInProgress state) {
    final risks = <ReformRiskEntity>[];

    if (state.projectManagementType == 'self') {
      risks.add(ReformRiskEntity(
        id: _uuid.v4(),
        title: 'Coordenação sem experiência',
        description:
            'Coordenar uma reforma sem experiência aumenta o risco de erros e retrabalho.',
        severity: RiskSeverity.medium,
        relatedPhaseId: 'phase_1', // Planejamento
        preventionActions: [
          'Estudar cada fase antes de começar',
          'Consultar profissionais para dúvidas',
          'Seguir rigorosamente os alertas do app',
          'Não pular etapas de verificação',
        ],
      ));
    }

    return risks;
  }

  /// Gera riscos relacionados a prazos
  List<ReformRiskEntity> _generateDeadlineRisks(OnboardingInProgress state) {
    final risks = <ReformRiskEntity>[];

    if (state.moveInGoal == 'asap' || state.moveInGoal == '3_months') {
      risks.add(ReformRiskEntity(
        id: _uuid.v4(),
        title: 'Prazo apertado',
        description:
            'Prazos muito curtos aumentam o risco de erros e podem comprometer a qualidade.',
        severity: RiskSeverity.medium,
        relatedPhaseId: 'phase_1',
        preventionActions: [
          'Revisar se o prazo é realista',
          'Priorizar ambientes essenciais',
          'Ter fornecedores de backup',
          'Considerar estender o prazo se necessário',
        ],
      ));
    }

    return risks;
  }
}

// Made with Bob
