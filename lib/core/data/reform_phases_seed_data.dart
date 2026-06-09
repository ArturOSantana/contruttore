import '../../features/reform_map/domain/entities/checklist_item_entity.dart';

/// Dados seed das 9 etapas padrão da reforma
class ReformPhasesSeedData {
  /// Retorna as 9 etapas padrão da reforma
  static List<PhaseData> get defaultPhases => [
        // ETAPA 1: Planejamento da Reforma
        PhaseData(
          id: 'planejamento',
          order: 1,
          name: 'Planejamento da Reforma',
          description: 'Definir tudo antes de gastar dinheiro',
          whatHappens:
              'Nesta etapa você define o escopo completo da reforma, estabelece o orçamento, contrata profissionais e planeja cada detalhe antes de iniciar as obras.',
          whyImportant:
              'Evita retrabalho, gastos desnecessários e garante que você tenha uma visão clara de todo o processo antes de começar.',
          commonMistakes:
              'Começar sem orçamento definido, comprar materiais antes do projeto, não considerar custos extras, pular a etapa de projeto.',
          checklist: [
            ChecklistItemEntity(
              id: 'definir_orcamento',
              name: 'Definir orçamento',
              description: 'Estabeleça quanto você pode gastar na reforma',
              why:
                  'Evita estourar o orçamento e permite planejar as prioridades',
              tip:
                  'Reserve 20% a mais para imprevistos. Reformas sempre custam mais do que o planejado.',
              mandatory: true,
              order: 1,
            ),
            ChecklistItemEntity(
              id: 'salvar_planta',
              name: 'Salvar planta do imóvel',
              description: 'Tenha a planta baixa do imóvel',
              why: 'Essencial para qualquer projeto e planejamento',
              tip:
                  'Se não tiver, contrate um profissional para fazer o levantamento',
              mandatory: true,
              order: 2,
            ),
            ChecklistItemEntity(
              id: 'definir_estilo',
              name: 'Definir estilo da reforma',
              description: 'Escolha o estilo de decoração e acabamentos',
              why: 'Orienta todas as escolhas de materiais e acabamentos',
              tip: 'Crie um painel de referências no Pinterest ou Instagram',
              mandatory: false,
              order: 3,
            ),
            ChecklistItemEntity(
              id: 'contratar_arquiteto',
              name: 'Contratar arquiteto (opcional)',
              description: 'Contrate um profissional para o projeto',
              why: 'Evita erros e otimiza espaços',
              tip:
                  'Vale a pena para reformas grandes. Economiza dinheiro no longo prazo.',
              mandatory: false,
              order: 4,
            ),
            ChecklistItemEntity(
              id: 'definir_ambientes',
              name: 'Definir ambientes a reformar',
              description: 'Liste todos os cômodos que serão reformados',
              why: 'Ajuda a dimensionar o escopo e o orçamento',
              mandatory: true,
              order: 5,
            ),
          ],
          expectedDocuments: [
            'Projeto arquitetônico',
            'Orçamento detalhado',
            'Cronograma',
            'Planta baixa',
          ],
          recommendedProfessionals: [
            'Arquiteto',
            'Engenheiro',
            'Designer de interiores',
          ],
          suggestedPurchases: [],
        ),

        // ETAPA 2: Aprovações e Preparação
        PhaseData(
          id: 'aprovacoes',
          order: 2,
          name: 'Aprovações e Preparação',
          description: 'Preparar o imóvel para receber a obra',
          whatHappens:
              'Nesta etapa você resolve todas as questões burocráticas com o condomínio, prepara o local e garante que tudo está pronto para o início das obras.',
          whyImportant:
              'Evita multas do condomínio, problemas com vizinhos e garante que a obra possa começar sem interrupções.',
          commonMistakes:
              'Não comunicar o condomínio, esquecer de reservar elevador, não cadastrar prestadores, começar obra sem autorização.',
          checklist: [
            ChecklistItemEntity(
              id: 'comunicar_condominio',
              name: 'Comunicar condomínio',
              description: 'Informe a administração sobre a reforma',
              why: 'Evita multas e problemas legais',
              tip:
                  'Faça isso com pelo menos 15 dias de antecedência. Alguns condomínios exigem aprovação.',
              mandatory: true,
              order: 1,
            ),
            ChecklistItemEntity(
              id: 'reservar_elevador',
              name: 'Reservar elevador',
              description: 'Reserve horários para uso do elevador de serviço',
              why: 'Facilita o transporte de materiais e entulho',
              tip: 'Reserve com antecedência. Alguns condomínios cobram taxa.',
              mandatory: true,
              order: 2,
            ),
            ChecklistItemEntity(
              id: 'cadastrar_prestadores',
              name: 'Cadastrar prestadores',
              description: 'Cadastre todos os profissionais no condomínio',
              why: 'Exigência de segurança e controle de acesso',
              mandatory: true,
              order: 3,
            ),
            ChecklistItemEntity(
              id: 'entregar_documentos',
              name: 'Entregar documentos',
              description: 'Entregue ART, projeto e outros documentos',
              why: 'Cumprimento de normas e regulamentos',
              tip: 'Guarde cópias de todos os documentos entregues',
              mandatory: true,
              order: 4,
            ),
          ],
          expectedDocuments: [
            'Comunicado ao condomínio',
            'ART (Anotação de Responsabilidade Técnica)',
            'Cadastro de prestadores',
            'Seguro de obra (se exigido)',
          ],
          recommendedProfessionals: [
            'Engenheiro (para ART)',
            'Mestre de obras',
          ],
          suggestedPurchases: [],
        ),

        // ETAPA 3: Infraestrutura
        PhaseData(
          id: 'infraestrutura',
          order: 3,
          name: 'Infraestrutura',
          description: 'Tudo que fica escondido',
          whatHappens:
              'Nesta etapa são feitas todas as instalações que ficarão embutidas: elétrica, hidráulica, internet, ar-condicionado e automação. É a etapa mais crítica da reforma.',
          whyImportant:
              'Depois que as paredes forem fechadas, qualquer mudança será muito cara e trabalhosa. É agora que você deve pensar em TUDO.',
          commonMistakes:
              'Poucas tomadas, esquecer internet cabeada, não prever dreno do ar-condicionado, não pensar na lava-louças, esquecer pontos de automação.',
          checklist: [
            ChecklistItemEntity(
              id: 'eletrica',
              name: 'Instalação elétrica',
              description: 'Refazer ou adequar toda a parte elétrica',
              why: 'Segurança e atender demanda de equipamentos modernos',
              tip:
                  'Pense em TODAS as tomadas que você vai precisar. É melhor sobrar do que faltar.',
              mandatory: true,
              order: 1,
            ),
            ChecklistItemEntity(
              id: 'hidraulica',
              name: 'Instalação hidráulica',
              description: 'Refazer ou adequar tubulações de água e esgoto',
              why: 'Evitar vazamentos e problemas futuros',
              tip:
                  'Se for trocar, troque tudo. Tubulação velha sempre dá problema.',
              mandatory: true,
              order: 2,
            ),
            ChecklistItemEntity(
              id: 'internet',
              name: 'Cabeamento de internet',
              description: 'Instale conduítes para cabos de rede',
              why: 'WiFi nem sempre funciona bem. Cabo é mais estável.',
              tip:
                  'Puxe cabos para sala, quartos e home office. Deixe conduítes extras.',
              mandatory: false,
              order: 3,
            ),
            ChecklistItemEntity(
              id: 'ar_condicionado',
              name: 'Infraestrutura ar-condicionado',
              description: 'Defina posições e instale drenos',
              why: 'Evita gambiarras e problemas de vazamento',
              tip:
                  'Mesmo que não vá instalar agora, deixe a infraestrutura pronta.',
              mandatory: false,
              order: 4,
            ),
            ChecklistItemEntity(
              id: 'automacao',
              name: 'Pontos de automação',
              description: 'Preveja pontos para automação residencial',
              why: 'Facilita instalação futura de smart home',
              tip: 'Deixe neutro em todos os interruptores e tomadas extras.',
              mandatory: false,
              order: 5,
            ),
          ],
          expectedDocuments: [
            'ART elétrica',
            'ART hidráulica',
            'Projeto elétrico',
            'Projeto hidráulico',
          ],
          recommendedProfessionals: [
            'Eletricista',
            'Encanador',
            'Técnico de ar-condicionado',
          ],
          suggestedPurchases: [
            'Conduítes',
            'Cabos elétricos',
            'Tubos PVC',
            'Caixas de passagem',
            'Disjuntores',
          ],
        ),

        // ETAPA 4: Pisos e Revestimentos
        PhaseData(
          id: 'revestimentos',
          order: 4,
          name: 'Pisos e Revestimentos',
          description: 'Piso, porcelanato e revestimentos',
          whatHappens:
              'Instalação de pisos, porcelanatos, azulejos e revestimentos em geral.',
          whyImportant:
              'Define a estética e durabilidade dos ambientes. Escolhas erradas são caras de corrigir.',
          commonMistakes:
              'Não comprar material extra, escolher piso escorregadio para banheiro, não verificar nível do piso.',
          checklist: [
            ChecklistItemEntity(
              id: 'piso',
              name: 'Instalação de piso',
              description: 'Instale o piso escolhido',
              why: 'Base de todo o ambiente',
              tip: 'Compre 10% a mais para quebras e reposições futuras',
              mandatory: true,
              order: 1,
            ),
            ChecklistItemEntity(
              id: 'porcelanato',
              name: 'Porcelanato',
              description: 'Instale porcelanato em áreas molhadas',
              why: 'Durabilidade e facilidade de limpeza',
              tip: 'Escolha antiderrapante para banheiros',
              mandatory: false,
              order: 2,
            ),
            ChecklistItemEntity(
              id: 'revestimentos_parede',
              name: 'Revestimentos de parede',
              description: 'Instale azulejos e revestimentos',
              why: 'Proteção e estética',
              tip: 'Compre sempre 10% a mais',
              mandatory: false,
              order: 3,
            ),
            ChecklistItemEntity(
              id: 'rodapes',
              name: 'Rodapés',
              description: 'Instale rodapés',
              why: 'Acabamento e proteção da parede',
              mandatory: true,
              order: 4,
            ),
          ],
          expectedDocuments: [
            'Notas fiscais',
            'Garantias dos materiais',
          ],
          recommendedProfessionals: [
            'Pedreiro',
            'Azulejista',
          ],
          suggestedPurchases: [
            'Piso',
            'Porcelanato',
            'Azulejos',
            'Argamassa',
            'Rejunte',
            'Rodapés',
          ],
        ),

        // ETAPA 5: Forros e Paredes
        PhaseData(
          id: 'forros',
          order: 5,
          name: 'Forros e Paredes',
          description: 'Gesso, drywall e preparação de paredes',
          whatHappens:
              'Instalação de forros de gesso, divisórias de drywall e preparação das paredes para pintura.',
          whyImportant: 'Define o acabamento final e esconde instalações.',
          commonMistakes:
              'Não prever acesso às instalações, gesso mal feito, não deixar tempo de cura.',
          checklist: [
            ChecklistItemEntity(
              id: 'gesso',
              name: 'Forro de gesso',
              description: 'Instale forro de gesso',
              why: 'Acabamento e esconder instalações',
              tip: 'Deixe alçapões para acesso futuro',
              mandatory: false,
              order: 1,
            ),
            ChecklistItemEntity(
              id: 'drywall',
              name: 'Divisórias drywall',
              description: 'Instale divisórias se necessário',
              why: 'Rápido e limpo',
              tip: 'Use drywall verde em áreas molhadas',
              mandatory: false,
              order: 2,
            ),
            ChecklistItemEntity(
              id: 'massa_corrida',
              name: 'Massa corrida',
              description: 'Aplique massa corrida nas paredes',
              why: 'Preparação para pintura',
              mandatory: true,
              order: 3,
            ),
          ],
          expectedDocuments: [],
          recommendedProfessionals: [
            'Gesseiro',
            'Drywall',
          ],
          suggestedPurchases: [
            'Gesso',
            'Perfis metálicos',
            'Massa corrida',
          ],
        ),

        // ETAPA 6: Pintura
        PhaseData(
          id: 'pintura',
          order: 6,
          name: 'Pintura',
          description: 'Pintura de paredes e tetos',
          whatHappens: 'Aplicação de selador, massa fina e pintura final.',
          whyImportant:
              'Define a cor e o acabamento final dos ambientes. Transforma o visual.',
          commonMistakes:
              'Não usar selador, economizar em demãos, não proteger o piso.',
          checklist: [
            ChecklistItemEntity(
              id: 'selador',
              name: 'Aplicar selador',
              description: 'Aplique selador antes da pintura',
              why: 'Uniformiza absorção e economiza tinta',
              mandatory: true,
              order: 1,
            ),
            ChecklistItemEntity(
              id: 'massa_fina',
              name: 'Massa fina',
              description: 'Aplique massa fina para acabamento',
              why: 'Deixa parede lisa',
              mandatory: true,
              order: 2,
            ),
            ChecklistItemEntity(
              id: 'pintura_final',
              name: 'Pintura final',
              description: 'Aplique a tinta escolhida',
              why: 'Acabamento final',
              tip: 'Mínimo 2 demãos. Guarde tinta para retoques.',
              mandatory: true,
              order: 3,
            ),
          ],
          expectedDocuments: [
            'Notas fiscais',
            'Fichas técnicas das tintas',
          ],
          recommendedProfessionals: [
            'Pintor',
          ],
          suggestedPurchases: [
            'Selador',
            'Massa fina',
            'Tinta',
            'Rolos',
            'Pincéis',
            'Fita crepe',
          ],
        ),

        // ETAPA 7: Acabamentos
        PhaseData(
          id: 'acabamentos',
          order: 7,
          name: 'Acabamentos',
          description: 'Tomadas, interruptores, louças e metais',
          whatHappens:
              'Instalação de todos os acabamentos: tomadas, interruptores, luminárias, louças sanitárias, metais e box.',
          whyImportant: 'Finaliza a obra e torna tudo funcional.',
          commonMistakes:
              'Instalar antes da pintura, não conferir voltagem, esquecer vedações.',
          checklist: [
            ChecklistItemEntity(
              id: 'tomadas_interruptores',
              name: 'Tomadas e interruptores',
              description: 'Instale tomadas e interruptores',
              why: 'Funcionalidade elétrica',
              tip: 'Confira voltagem antes de instalar',
              mandatory: true,
              order: 1,
            ),
            ChecklistItemEntity(
              id: 'luminarias',
              name: 'Luminárias',
              description: 'Instale luminárias e lustres',
              why: 'Iluminação',
              mandatory: true,
              order: 2,
            ),
            ChecklistItemEntity(
              id: 'loucas',
              name: 'Louças sanitárias',
              description: 'Instale vasos, pias e cubas',
              why: 'Funcionalidade dos banheiros',
              mandatory: true,
              order: 3,
            ),
            ChecklistItemEntity(
              id: 'metais',
              name: 'Metais',
              description: 'Instale torneiras, chuveiros e registros',
              why: 'Funcionalidade hidráulica',
              mandatory: true,
              order: 4,
            ),
            ChecklistItemEntity(
              id: 'box',
              name: 'Box',
              description: 'Instale box do banheiro',
              why: 'Proteção contra água',
              mandatory: true,
              order: 5,
            ),
          ],
          expectedDocuments: [
            'Notas fiscais',
            'Manuais',
            'Garantias',
          ],
          recommendedProfessionals: [
            'Eletricista',
            'Encanador',
            'Vidraceiro',
          ],
          suggestedPurchases: [
            'Tomadas',
            'Interruptores',
            'Luminárias',
            'Louças',
            'Metais',
            'Box',
          ],
        ),

        // ETAPA 8: Marcenaria
        PhaseData(
          id: 'marcenaria',
          order: 8,
          name: 'Marcenaria',
          description: 'Armários, móveis planejados e portas',
          whatHappens:
              'Medição final, projeto executivo, produção e instalação de todos os móveis planejados.',
          whyImportant:
              'Otimiza espaços e define a funcionalidade dos ambientes.',
          commonMistakes:
              'Medir antes dos acabamentos, não conferir medidas, não prever tomadas dentro dos armários.',
          checklist: [
            ChecklistItemEntity(
              id: 'medicao_final',
              name: 'Medição final',
              description: 'Faça medição após TODOS os acabamentos',
              why: 'Garantir que móveis vão encaixar perfeitamente',
              tip: 'NUNCA meça antes da pintura e piso. Sempre há variações.',
              mandatory: true,
              order: 1,
            ),
            ChecklistItemEntity(
              id: 'projeto_executivo',
              name: 'Projeto executivo',
              description: 'Aprove projeto detalhado',
              why: 'Evitar erros na produção',
              tip: 'Confira cada medida e detalhe',
              mandatory: true,
              order: 2,
            ),
            ChecklistItemEntity(
              id: 'producao',
              name: 'Produção',
              description: 'Acompanhe produção dos móveis',
              why: 'Garantir qualidade',
              tip: 'Prazo médio: 30-45 dias',
              mandatory: true,
              order: 3,
            ),
            ChecklistItemEntity(
              id: 'instalacao',
              name: 'Instalação',
              description: 'Instale móveis planejados',
              why: 'Finalização',
              tip: 'Confira tudo antes de assinar recebimento',
              mandatory: true,
              order: 4,
            ),
          ],
          expectedDocuments: [
            'Projeto executivo',
            'Contrato',
            'Garantia',
            'Manual de uso',
          ],
          recommendedProfessionals: [
            'Marceneiro',
            'Designer de interiores',
          ],
          suggestedPurchases: [],
        ),

        // ETAPA 9: Mudança e Decoração
        PhaseData(
          id: 'mudanca',
          order: 9,
          name: 'Mudança e Decoração',
          description: 'Limpeza, mudança e decoração final',
          whatHappens:
              'Limpeza pós-obra, mudança dos móveis e decoração final do imóvel.',
          whyImportant: 'Finaliza a reforma e torna o imóvel habitável.',
          commonMistakes:
              'Não fazer limpeza profissional, mudar antes da limpeza, não proteger acabamentos novos.',
          checklist: [
            ChecklistItemEntity(
              id: 'limpeza_pos_obra',
              name: 'Limpeza pós-obra',
              description: 'Contrate limpeza profissional',
              why: 'Remove resíduos de obra',
              tip: 'Vale muito a pena contratar profissionais',
              mandatory: true,
              order: 1,
            ),
            ChecklistItemEntity(
              id: 'mudanca',
              name: 'Mudança',
              description: 'Organize a mudança',
              why: 'Transferir pertences',
              tip: 'Proteja pisos e paredes durante a mudança',
              mandatory: true,
              order: 2,
            ),
            ChecklistItemEntity(
              id: 'montagem',
              name: 'Montagem de móveis',
              description: 'Monte móveis e organize',
              why: 'Tornar funcional',
              mandatory: true,
              order: 3,
            ),
            ChecklistItemEntity(
              id: 'decoracao',
              name: 'Decoração',
              description: 'Decore os ambientes',
              why: 'Personalizar e deixar aconchegante',
              tip: 'Vá aos poucos. Não precisa comprar tudo de uma vez.',
              mandatory: false,
              order: 4,
            ),
          ],
          expectedDocuments: [],
          recommendedProfessionals: [
            'Empresa de limpeza',
            'Empresa de mudanças',
          ],
          suggestedPurchases: [
            'Cortinas',
            'Tapetes',
            'Quadros',
            'Plantas',
            'Almofadas',
          ],
        ),
      ];
}

/// Dados de uma fase da reforma
class PhaseData {
  final String id;
  final int order;
  final String name;
  final String description;
  final String whatHappens;
  final String whyImportant;
  final String commonMistakes;
  final List<ChecklistItemEntity> checklist;
  final List<String> expectedDocuments;
  final List<String> recommendedProfessionals;
  final List<String> suggestedPurchases;

  const PhaseData({
    required this.id,
    required this.order,
    required this.name,
    required this.description,
    required this.whatHappens,
    required this.whyImportant,
    required this.commonMistakes,
    required this.checklist,
    required this.expectedDocuments,
    required this.recommendedProfessionals,
    required this.suggestedPurchases,
  });
}

// Made with Bob
