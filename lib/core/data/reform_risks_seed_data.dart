import '../../features/reform_map/domain/entities/reform_risk_entity.dart';

/// Dados seed dos riscos por etapa da reforma
class ReformRisksSeedData {
  /// Retorna os riscos padrão por etapa
  static List<ReformRiskEntity> getRisksForPhase(
      String phaseId, String phaseName) {
    final now = DateTime.now();

    switch (phaseId) {
      case 'planejamento':
        return [
          ReformRiskEntity(
            id: 'risk_planejamento_1',
            title: 'Começar sem orçamento definido',
            description:
                'Iniciar a reforma sem ter um orçamento claro pode levar a gastos descontrolados e obra inacabada.',
            severity: RiskSeverity.high,
            phaseId: phaseId,
            phaseName: phaseName,
            preventionActions: [
              'Defina um valor máximo que pode gastar',
              'Reserve 20% para imprevistos',
              'Liste todas as despesas previstas',
              'Priorize o que é essencial',
            ],
            consequences:
                'Obra parada por falta de dinheiro, endividamento, necessidade de empréstimos.',
            estimatedCost: 10000,
            estimatedDelay: 60,
            createdAt: now,
          ),
          ReformRiskEntity(
            id: 'risk_planejamento_2',
            title: 'Comprar materiais antes do projeto',
            description:
                'Comprar materiais sem ter o projeto definido pode resultar em desperdício e retrabalho.',
            severity: RiskSeverity.medium,
            phaseId: phaseId,
            phaseName: phaseName,
            preventionActions: [
              'Aguarde o projeto ficar pronto',
              'Faça lista de compras baseada no projeto',
              'Compre apenas após medições finais',
            ],
            consequences:
                'Materiais errados, desperdício de dinheiro, necessidade de trocar produtos.',
            estimatedCost: 3000,
            createdAt: now,
          ),
        ];

      case 'aprovacoes':
        return [
          ReformRiskEntity(
            id: 'risk_aprovacoes_1',
            title: 'Multas do condomínio',
            description:
                'Não comunicar o condomínio ou descumprir regras pode gerar multas pesadas.',
            severity: RiskSeverity.high,
            phaseId: phaseId,
            phaseName: phaseName,
            preventionActions: [
              'Comunique com 15 dias de antecedência',
              'Leia o regulamento interno',
              'Reserve elevador nos horários permitidos',
              'Cadastre todos os prestadores',
            ],
            consequences:
                'Multas de R\$ 500 a R\$ 5.000, embargo da obra, problemas com vizinhos.',
            estimatedCost: 2000,
            estimatedDelay: 15,
            createdAt: now,
          ),
        ];

      case 'infraestrutura':
        return [
          ReformRiskEntity(
            id: 'risk_infra_1',
            title: 'Ar-condicionado sem infraestrutura',
            description:
                'Não prever dreno e ponto elétrico para ar-condicionado antes de fechar as paredes.',
            severity: RiskSeverity.high,
            phaseId: phaseId,
            phaseName: phaseName,
            preventionActions: [
              'Defina posição dos aparelhos AGORA',
              'Instale dreno embutido',
              'Crie ponto elétrico dedicado',
              'Deixe conduíte para cabo de comunicação',
            ],
            consequences:
                'Gambiarras visíveis, vazamentos, necessidade de quebrar parede novamente.',
            estimatedCost: 2000,
            estimatedDelay: 7,
            createdAt: now,
          ),
          ReformRiskEntity(
            id: 'risk_infra_2',
            title: 'Poucas tomadas',
            description:
                'Não prever tomadas suficientes leva a uso excessivo de extensões e benjamins.',
            severity: RiskSeverity.medium,
            phaseId: phaseId,
            phaseName: phaseName,
            preventionActions: [
              'Pense em TODOS os equipamentos',
              'Coloque tomadas extras',
              'Preveja tomadas USB',
              'Considere automação futura',
            ],
            consequences:
                'Casa cheia de extensões, risco de sobrecarga, visual ruim.',
            estimatedCost: 1500,
            createdAt: now,
          ),
          ReformRiskEntity(
            id: 'risk_infra_3',
            title: 'Sem internet cabeada',
            description:
                'Não instalar conduítes para cabos de rede limita velocidade e estabilidade.',
            severity: RiskSeverity.medium,
            phaseId: phaseId,
            phaseName: phaseName,
            preventionActions: [
              'Puxe cabos para sala, quartos e home office',
              'Deixe conduítes extras',
              'Preveja ponto central para roteador',
            ],
            consequences:
                'WiFi instável, velocidade reduzida, cabos aparentes.',
            estimatedCost: 800,
            createdAt: now,
          ),
          ReformRiskEntity(
            id: 'risk_infra_4',
            title: 'Lava-louças sem pontos',
            description:
                'Esquecer de prever água, esgoto e energia para lava-louças.',
            severity: RiskSeverity.medium,
            phaseId: phaseId,
            phaseName: phaseName,
            preventionActions: [
              'Defina posição da lava-louças',
              'Instale ponto de água',
              'Instale ponto de esgoto',
              'Crie tomada dedicada',
            ],
            consequences:
                'Impossível instalar lava-louças, necessidade de quebrar tudo novamente.',
            estimatedCost: 1200,
            estimatedDelay: 5,
            createdAt: now,
          ),
          ReformRiskEntity(
            id: 'risk_infra_5',
            title: 'Sem automação residencial',
            description:
                'Não prever infraestrutura para smart home dificulta instalação futura.',
            severity: RiskSeverity.low,
            phaseId: phaseId,
            phaseName: phaseName,
            preventionActions: [
              'Deixe neutro em todos os interruptores',
              'Preveja tomadas extras',
              'Instale conduítes para sensores',
            ],
            consequences:
                'Impossível automatizar sem quebrar paredes, custo alto futuro.',
            estimatedCost: 3000,
            createdAt: now,
          ),
        ];

      case 'revestimentos':
        return [
          ReformRiskEntity(
            id: 'risk_revestimentos_1',
            title: 'Não comprar material extra',
            description:
                'Não comprar 10% a mais de piso e revestimentos para quebras e reposições.',
            severity: RiskSeverity.medium,
            phaseId: phaseId,
            phaseName: phaseName,
            preventionActions: [
              'Compre SEMPRE 10% a mais',
              'Guarde sobras para reparos futuros',
              'Anote lote e referência',
            ],
            consequences:
                'Impossível encontrar mesmo lote, remendos visíveis, necessidade de trocar tudo.',
            estimatedCost: 2000,
            estimatedDelay: 15,
            createdAt: now,
          ),
          ReformRiskEntity(
            id: 'risk_revestimentos_2',
            title: 'Piso escorregadio em área molhada',
            description:
                'Escolher piso liso para banheiro aumenta risco de quedas.',
            severity: RiskSeverity.high,
            phaseId: phaseId,
            phaseName: phaseName,
            preventionActions: [
              'Escolha piso antiderrapante',
              'Verifique classificação de aderência',
              'Teste antes de comprar',
            ],
            consequences: 'Risco de acidentes, necessidade de trocar piso.',
            estimatedCost: 3000,
            estimatedDelay: 10,
            createdAt: now,
          ),
        ];

      case 'forros':
        return [
          ReformRiskEntity(
            id: 'risk_forros_1',
            title: 'Gesso sem acesso às instalações',
            description:
                'Fechar gesso sem deixar alçapões impede manutenção futura.',
            severity: RiskSeverity.medium,
            phaseId: phaseId,
            phaseName: phaseName,
            preventionActions: [
              'Deixe alçapões em pontos estratégicos',
              'Marque posição de caixas elétricas',
              'Documente instalações',
            ],
            consequences: 'Necessidade de quebrar gesso para manutenção.',
            estimatedCost: 1500,
            createdAt: now,
          ),
        ];

      case 'pintura':
        return [
          ReformRiskEntity(
            id: 'risk_pintura_1',
            title: 'Não usar selador',
            description:
                'Pular o selador aumenta consumo de tinta e deixa acabamento irregular.',
            severity: RiskSeverity.low,
            phaseId: phaseId,
            phaseName: phaseName,
            preventionActions: [
              'Sempre use selador',
              'Aguarde secar completamente',
              'Não economize nesta etapa',
            ],
            consequences: 'Maior consumo de tinta, acabamento ruim, manchas.',
            estimatedCost: 800,
            createdAt: now,
          ),
        ];

      case 'acabamentos':
        return [
          ReformRiskEntity(
            id: 'risk_acabamentos_1',
            title: 'Instalar antes da pintura',
            description:
                'Instalar acabamentos antes da pintura pode danificá-los.',
            severity: RiskSeverity.medium,
            phaseId: phaseId,
            phaseName: phaseName,
            preventionActions: [
              'Sempre pinte primeiro',
              'Instale acabamentos por último',
              'Proteja o que já foi instalado',
            ],
            consequences:
                'Acabamentos sujos ou danificados, necessidade de trocar.',
            estimatedCost: 1000,
            createdAt: now,
          ),
        ];

      case 'marcenaria':
        return [
          ReformRiskEntity(
            id: 'risk_marcenaria_1',
            title: 'Medir antes dos acabamentos',
            description:
                'Fazer medição antes de concluir piso e pintura resulta em móveis que não encaixam.',
            severity: RiskSeverity.high,
            phaseId: phaseId,
            phaseName: phaseName,
            preventionActions: [
              'NUNCA meça antes da pintura',
              'NUNCA meça antes do piso',
              'Aguarde TODOS os acabamentos',
              'Sempre há variações de medida',
            ],
            consequences:
                'Móveis não encaixam, frestas, necessidade de refazer, prejuízo total.',
            estimatedCost: 15000,
            estimatedDelay: 45,
            createdAt: now,
          ),
          ReformRiskEntity(
            id: 'risk_marcenaria_2',
            title: 'Não prever tomadas nos armários',
            description:
                'Esquecer tomadas dentro de armários dificulta uso de eletrodomésticos.',
            severity: RiskSeverity.medium,
            phaseId: phaseId,
            phaseName: phaseName,
            preventionActions: [
              'Preveja tomadas em armários de cozinha',
              'Deixe tomadas em closets',
              'Pense em carregadores',
            ],
            consequences: 'Necessidade de extensões, visual ruim.',
            estimatedCost: 500,
            createdAt: now,
          ),
        ];

      case 'mudanca':
        return [
          ReformRiskEntity(
            id: 'risk_mudanca_1',
            title: 'Não fazer limpeza profissional',
            description:
                'Tentar limpar sozinho após obra raramente remove todos os resíduos.',
            severity: RiskSeverity.low,
            phaseId: phaseId,
            phaseName: phaseName,
            preventionActions: [
              'Contrate empresa especializada',
              'Vale muito a pena',
              'Economiza tempo e esforço',
            ],
            consequences: 'Casa suja, resíduos em acabamentos, mais trabalho.',
            estimatedCost: 800,
            createdAt: now,
          ),
          ReformRiskEntity(
            id: 'risk_mudanca_2',
            title: 'Não proteger acabamentos na mudança',
            description:
                'Mudar sem proteger pisos e paredes pode danificar acabamentos novos.',
            severity: RiskSeverity.medium,
            phaseId: phaseId,
            phaseName: phaseName,
            preventionActions: [
              'Use papelão no piso',
              'Proteja quinas e batentes',
              'Contrate empresa profissional',
            ],
            consequences: 'Arranhões, amassados, necessidade de reparos.',
            estimatedCost: 1500,
            createdAt: now,
          ),
        ];

      default:
        return [];
    }
  }

  /// Retorna todos os riscos de todas as etapas
  static List<ReformRiskEntity> getAllRisks() {
    final phases = [
      {'id': 'planejamento', 'name': 'Planejamento da Reforma'},
      {'id': 'aprovacoes', 'name': 'Aprovações e Preparação'},
      {'id': 'infraestrutura', 'name': 'Infraestrutura'},
      {'id': 'revestimentos', 'name': 'Pisos e Revestimentos'},
      {'id': 'forros', 'name': 'Forros e Paredes'},
      {'id': 'pintura', 'name': 'Pintura'},
      {'id': 'acabamentos', 'name': 'Acabamentos'},
      {'id': 'marcenaria', 'name': 'Marcenaria'},
      {'id': 'mudanca', 'name': 'Mudança e Decoração'},
    ];

    final allRisks = <ReformRiskEntity>[];
    for (final phase in phases) {
      allRisks.addAll(getRisksForPhase(phase['id']!, phase['name']!));
    }
    return allRisks;
  }

  /// Retorna estatísticas dos riscos
  static Map<String, int> getRiskStatistics() {
    final allRisks = getAllRisks();
    return {
      'total': allRisks.length,
      'high': allRisks.where((r) => r.severity == RiskSeverity.high).length,
      'medium': allRisks.where((r) => r.severity == RiskSeverity.medium).length,
      'low': allRisks.where((r) => r.severity == RiskSeverity.low).length,
    };
  }
}

// Made with Bob
