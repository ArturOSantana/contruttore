/// Seed data para o glossário de construção civil
/// Contém 50+ termos técnicos organizados por categoria
final List<Map<String, dynamic>> glossarySeedData = [
  // ========== DOCUMENTAÇÃO E LEGAL (15 termos) ==========
  {
    'term': 'ART',
    'definition':
        'Anotação de Responsabilidade Técnica é o documento que registra no CREA a responsabilidade técnica de um profissional sobre uma obra ou serviço de engenharia.',
    'whyItMatters':
        'Sem ART válida, você não tem garantia legal de que um profissional habilitado está responsável pela obra. Em caso de problemas, não há como acionar o seguro ou o profissional.',
    'commonMistake':
        'Aceitar início de obra sem ART registrada ou com ART de valor muito baixo que não cobre todo o escopo.',
    'relatedPhase': 1,
    'category': 'documentation',
    'relatedTerms': ['RRT', 'CREA'],
  },
  {
    'term': 'RRT',
    'definition':
        'Registro de Responsabilidade Técnica é o equivalente à ART, mas emitido pelo CAU (Conselho de Arquitetura e Urbanismo) para arquitetos.',
    'whyItMatters':
        'Garante que o projeto arquitetônico foi elaborado por profissional habilitado e registrado, essencial para aprovação na prefeitura.',
    'commonMistake':
        'Confundir RRT com ART ou não exigir RRT do arquiteto responsável pelo projeto.',
    'relatedPhase': 1,
    'category': 'documentation',
    'relatedTerms': ['ART', 'Projeto Arquitetônico'],
  },
  {
    'term': 'Alvará de Construção',
    'definition':
        'Documento emitido pela prefeitura que autoriza o início da construção, reforma ou demolição de uma edificação.',
    'whyItMatters':
        'Construir sem alvará é ilegal e pode resultar em multas pesadas, embargo da obra e até demolição. Também impede a obtenção do Habite-se.',
    'commonMistake':
        'Iniciar a obra antes da aprovação do alvará ou deixar o alvará vencer durante a construção.',
    'relatedPhase': 1,
    'category': 'documentation',
    'relatedTerms': ['Habite-se', 'Projeto Aprovado'],
  },
  {
    'term': 'Habite-se',
    'definition':
        'Certificado de Conclusão de Obra emitido pela prefeitura que atesta que a construção foi concluída conforme o projeto aprovado e está apta para ser habitada.',
    'whyItMatters':
        'Sem o Habite-se, você não pode registrar o imóvel, vender, financiar ou ligar serviços definitivos de água e luz. É essencial para regularização.',
    'commonMistake':
        'Deixar para solicitar o Habite-se muito tempo depois da conclusão, quando já há modificações não aprovadas.',
    'relatedPhase': 15,
    'category': 'documentation',
    'relatedTerms': ['Alvará de Construção', 'Vistoria'],
  },
  {
    'term': 'Matrícula do Imóvel',
    'definition':
        'Documento do Cartório de Registro de Imóveis que identifica o terreno, seus proprietários, dimensões e eventuais ônus (hipotecas, penhoras).',
    'whyItMatters':
        'É a "certidão de nascimento" do terreno. Sem verificar a matrícula, você pode comprar um terreno com problemas jurídicos, dívidas ou até invasão.',
    'commonMistake':
        'Comprar terreno sem verificar a matrícula atualizada ou não conferir se as dimensões reais batem com o documento.',
    'relatedPhase': 1,
    'category': 'documentation',
    'relatedTerms': ['Escritura', 'Certidões'],
  },
  {
    'term': 'Projeto Arquitetônico',
    'definition':
        'Conjunto de plantas, cortes e fachadas que definem a distribuição dos ambientes, dimensões e características estéticas da construção.',
    'whyItMatters':
        'É o documento base para aprovação na prefeitura e execução da obra. Um bom projeto evita retrabalho, desperdício e problemas futuros.',
    'commonMistake':
        'Economizar no projeto e contratar profissional sem experiência, resultando em erros que custam muito mais para corrigir na obra.',
    'relatedPhase': 1,
    'category': 'documentation',
    'relatedTerms': ['RRT', 'Projeto Estrutural'],
  },
  {
    'term': 'Projeto Estrutural',
    'definition':
        'Projeto técnico que define o dimensionamento de vigas, pilares, lajes e fundações, garantindo a segurança estrutural da edificação.',
    'whyItMatters':
        'É obrigatório por lei e essencial para segurança. Erros estruturais podem causar rachaduras, infiltrações e até desabamento.',
    'commonMistake':
        'Tentar economizar não fazendo projeto estrutural ou usando "projetos padrão" sem cálculo específico para o terreno.',
    'relatedPhase': 2,
    'category': 'documentation',
    'relatedTerms': ['ART', 'Fundação'],
  },
  {
    'term': 'Projeto Hidrossanitário',
    'definition':
        'Projeto que define o caminho das tubulações de água, esgoto e águas pluviais, incluindo dimensionamento e especificações técnicas.',
    'whyItMatters':
        'Evita problemas como falta de pressão, entupimentos, vazamentos e infiltrações. Facilita manutenções futuras.',
    'commonMistake':
        'Executar instalações hidráulicas sem projeto, "no olho", resultando em problemas crônicos de pressão e vazamentos.',
    'relatedPhase': 9,
    'category': 'documentation',
    'relatedTerms': ['Projeto Elétrico', 'Instalações'],
  },
  {
    'term': 'Projeto Elétrico',
    'definition':
        'Projeto que define pontos de luz, tomadas, circuitos, quadro de distribuição e dimensionamento de fiação elétrica.',
    'whyItMatters':
        'Garante segurança elétrica, evita sobrecargas, curtos-circuitos e facilita futuras ampliações. É exigido pela concessionária de energia.',
    'commonMistake':
        'Subdimensionar circuitos ou não prever pontos suficientes, tendo que fazer gambiarras depois.',
    'relatedPhase': 9,
    'category': 'documentation',
    'relatedTerms': ['Projeto Hidrossanitário', 'Quadro de Distribuição'],
  },
  {
    'term': 'Memorial Descritivo',
    'definition':
        'Documento que descreve detalhadamente todos os materiais, acabamentos e especificações técnicas que serão utilizados na obra.',
    'whyItMatters':
        'Evita divergências entre o que foi orçado e o que será executado. É essencial para comparar orçamentos de forma justa.',
    'commonMistake':
        'Aceitar orçamentos sem memorial descritivo detalhado, permitindo que o construtor use materiais de qualidade inferior.',
    'relatedPhase': 1,
    'category': 'documentation',
    'relatedTerms': ['Orçamento', 'Especificações'],
  },
  {
    'term': 'Cronograma Físico-Financeiro',
    'definition':
        'Planejamento que relaciona as etapas da obra com os prazos de execução e os valores a serem pagos em cada fase.',
    'whyItMatters':
        'Permite controlar o andamento da obra e o fluxo de caixa, evitando surpresas financeiras e atrasos.',
    'commonMistake':
        'Não ter cronograma ou não atualizá-lo conforme a obra avança, perdendo o controle de prazos e custos.',
    'relatedPhase': 1,
    'category': 'documentation',
    'relatedTerms': ['Orçamento', 'Medição'],
  },
  {
    'term': 'Diário de Obra',
    'definition':
        'Registro diário das atividades executadas, materiais recebidos, condições climáticas e ocorrências relevantes da obra.',
    'whyItMatters':
        'Serve como prova em caso de disputas, ajuda a controlar o andamento e identifica problemas recorrentes.',
    'commonMistake':
        'Não manter diário de obra ou fazer registros superficiais sem fotos e detalhes.',
    'relatedPhase': null,
    'category': 'documentation',
    'relatedTerms': ['Cronograma', 'Fiscalização'],
  },
  {
    'term': 'Certidão Negativa de Débitos',
    'definition':
        'Documento que comprova que o imóvel não possui dívidas de IPTU, taxas municipais ou outras pendências.',
    'whyItMatters':
        'Essencial para compra de terreno e obtenção de financiamento. Dívidas antigas podem ser transferidas para o novo proprietário.',
    'commonMistake':
        'Não solicitar certidões atualizadas antes de fechar negócio, assumindo dívidas desconhecidas.',
    'relatedPhase': 1,
    'category': 'documentation',
    'relatedTerms': ['Matrícula do Imóvel', 'IPTU'],
  },
  {
    'term': 'Laudo de Sondagem',
    'definition':
        'Estudo geotécnico que analisa o solo do terreno, identificando tipo, resistência e nível do lençol freático.',
    'whyItMatters':
        'Define o tipo de fundação necessária. Sem sondagem, você pode gastar muito mais com fundação inadequada ou ter problemas estruturais.',
    'commonMistake':
        'Não fazer sondagem para economizar, descobrindo solo ruim só depois de iniciar a fundação.',
    'relatedPhase': 2,
    'category': 'documentation',
    'relatedTerms': ['Fundação', 'Projeto Estrutural'],
  },
  {
    'term': 'Averbação',
    'definition':
        'Registro da construção na matrícula do imóvel no Cartório de Registro de Imóveis, atualizando o valor venal.',
    'whyItMatters':
        'Regulariza a construção legalmente, permite venda, financiamento e herança sem problemas. Aumenta o valor do imóvel.',
    'commonMistake':
        'Deixar para averbar anos depois, quando já há modificações não aprovadas ou documentos perdidos.',
    'relatedPhase': 15,
    'category': 'documentation',
    'relatedTerms': ['Habite-se', 'Matrícula do Imóvel'],
  },

  // ========== ESTRUTURA (10 termos) ==========
  {
    'term': 'Fundação',
    'definition':
        'Elemento estrutural que transmite as cargas da construção para o solo. Pode ser rasa (sapata, radier) ou profunda (estaca, tubulão).',
    'whyItMatters':
        'É a base de tudo. Fundação mal executada causa rachaduras, desníveis e pode comprometer toda a estrutura.',
    'commonMistake':
        'Escolher tipo de fundação sem sondagem do solo ou economizar na profundidade/dimensionamento.',
    'relatedPhase': 3,
    'category': 'structure',
    'relatedTerms': ['Laudo de Sondagem', 'Sapata', 'Radier'],
  },
  {
    'term': 'Sapata',
    'definition':
        'Tipo de fundação rasa em formato de bloco de concreto armado que distribui a carga dos pilares no solo.',
    'whyItMatters':
        'Adequada para solos resistentes e cargas moderadas. Mais econômica que fundações profundas quando o solo permite.',
    'commonMistake':
        'Usar sapata em solo fraco ou com lençol freático alto, causando recalques (afundamentos).',
    'relatedPhase': 3,
    'category': 'structure',
    'relatedTerms': ['Fundação', 'Baldrame'],
  },
  {
    'term': 'Radier',
    'definition':
        'Laje de concreto armado que cobre toda a área da construção, servindo como fundação e piso térreo simultaneamente.',
    'whyItMatters':
        'Economiza tempo e material em terrenos com boa capacidade de carga. Distribui uniformemente as cargas.',
    'commonMistake':
        'Executar radier sem impermeabilização adequada, causando umidade ascendente.',
    'relatedPhase': 3,
    'category': 'structure',
    'relatedTerms': ['Fundação', 'Impermeabilização'],
  },
  {
    'term': 'Baldrame',
    'definition':
        'Viga de concreto armado que liga as sapatas e serve de apoio para as paredes do térreo.',
    'whyItMatters':
        'Distribui cargas, evita trincas nas paredes e impede entrada de umidade do solo.',
    'commonMistake':
        'Não fazer baldrame ou executar com altura insuficiente, permitindo umidade nas paredes.',
    'relatedPhase': 4,
    'category': 'structure',
    'relatedTerms': ['Sapata', 'Impermeabilização'],
  },
  {
    'term': 'Pilar',
    'definition':
        'Elemento estrutural vertical de concreto armado que transmite as cargas das lajes e vigas para a fundação.',
    'whyItMatters':
        'Sustenta toda a estrutura. Erro no pilar pode causar colapso. Deve seguir rigorosamente o projeto estrutural.',
    'commonMistake':
        'Alterar posição ou dimensão de pilares sem consultar o engenheiro estrutural.',
    'relatedPhase': 5,
    'category': 'structure',
    'relatedTerms': ['Viga', 'Fundação'],
  },
  {
    'term': 'Viga',
    'definition':
        'Elemento estrutural horizontal de concreto armado que recebe cargas das lajes e as transmite para os pilares.',
    'whyItMatters':
        'Distribui cargas e evita flechas (deformações) nas lajes. Dimensionamento incorreto causa rachaduras.',
    'commonMistake':
        'Fazer furos ou cortes em vigas para passar tubulações, comprometendo a estrutura.',
    'relatedPhase': 6,
    'category': 'structure',
    'relatedTerms': ['Pilar', 'Laje'],
  },
  {
    'term': 'Laje',
    'definition':
        'Elemento estrutural horizontal de concreto que serve como piso de um pavimento e teto do pavimento inferior.',
    'whyItMatters':
        'Suporta cargas de pessoas, móveis e divisórias. Laje mal executada pode apresentar flechas, trincas e até desabar.',
    'commonMistake':
        'Retirar escoras (formas) antes do tempo de cura do concreto ou sobrecarregar durante a execução.',
    'relatedPhase': 6,
    'category': 'structure',
    'relatedTerms': ['Viga', 'Concreto'],
  },
  {
    'term': 'Concreto Usinado',
    'definition':
        'Concreto produzido em central e entregue pronto na obra por caminhão betoneira, com controle de qualidade.',
    'whyItMatters':
        'Garante resistência e qualidade uniformes. Mais rápido e confiável que concreto feito na obra.',
    'commonMistake':
        'Usar concreto virado na obra para estrutura, sem controle de traço e resistência.',
    'relatedPhase': 6,
    'category': 'structure',
    'relatedTerms': ['Laje', 'Slump Test'],
  },
  {
    'term': 'Armadura',
    'definition':
        'Conjunto de barras de aço (ferragem) posicionadas dentro do concreto para resistir aos esforços de tração.',
    'whyItMatters':
        'O concreto sozinho é fraco à tração. A armadura é essencial para a resistência estrutural.',
    'commonMistake':
        'Usar bitola de ferro menor que a especificada ou não respeitar o cobrimento mínimo, causando corrosão.',
    'relatedPhase': 5,
    'category': 'structure',
    'relatedTerms': ['Concreto', 'Pilar', 'Viga'],
  },
  {
    'term': 'Cinta de Amarração',
    'definition':
        'Viga de concreto armado que percorre o topo das paredes, amarrando-as e distribuindo cargas da cobertura.',
    'whyItMatters':
        'Evita trincas nas paredes, especialmente nos cantos de portas e janelas. Essencial em regiões com ventos fortes.',
    'commonMistake':
        'Não executar cinta ou fazer com altura/armadura insuficiente.',
    'relatedPhase': 7,
    'category': 'structure',
    'relatedTerms': ['Alvenaria', 'Cobertura'],
  },

  // ========== INSTALAÇÕES (10 termos) ==========
  {
    'term': 'Quadro de Distribuição',
    'definition':
        'Caixa que abriga disjuntores e dispositivos de proteção elétrica, distribuindo energia para os circuitos da casa.',
    'whyItMatters':
        'Protege contra sobrecargas e curtos-circuitos. Deve ser dimensionado para a carga total da residência.',
    'commonMistake':
        'Subdimensionar o quadro ou usar disjuntores inadequados, causando desligamentos frequentes.',
    'relatedPhase': 9,
    'category': 'installations',
    'relatedTerms': ['Projeto Elétrico', 'Disjuntor'],
  },
  {
    'term': 'Aterramento',
    'definition':
        'Sistema que conecta a instalação elétrica ao solo, desviando correntes de fuga e protegendo contra choques.',
    'whyItMatters':
        'Essencial para segurança. Sem aterramento adequado, há risco de choque elétrico fatal.',
    'commonMistake':
        'Não fazer aterramento ou usar conexões inadequadas, deixando a instalação perigosa.',
    'relatedPhase': 9,
    'category': 'installations',
    'relatedTerms': ['Quadro de Distribuição', 'DPS'],
  },
  {
    'term': 'DPS',
    'definition':
        'Dispositivo de Proteção contra Surtos elétricos causados por raios ou variações na rede, protegendo equipamentos.',
    'whyItMatters':
        'Evita queima de eletrodomésticos e eletrônicos durante tempestades. Obrigatório em novas instalações.',
    'commonMistake':
        'Não instalar DPS ou instalar modelo inadequado para a região.',
    'relatedPhase': 9,
    'category': 'installations',
    'relatedTerms': ['Aterramento', 'Quadro de Distribuição'],
  },
  {
    'term': 'Caixa d\'Água',
    'definition':
        'Reservatório que armazena água para consumo, garantindo abastecimento mesmo em falta de água da rua.',
    'whyItMatters':
        'Deve ter capacidade para 2 dias de consumo. Posicionamento correto garante pressão adequada.',
    'commonMistake':
        'Subdimensionar a caixa d\'água ou posicioná-la muito baixa, causando falta de pressão.',
    'relatedPhase': 9,
    'category': 'installations',
    'relatedTerms': ['Projeto Hidrossanitário', 'Bomba d\'Água'],
  },
  {
    'term': 'Fossa Séptica',
    'definition':
        'Sistema de tratamento primário de esgoto para locais sem rede pública, onde bactérias decompõem a matéria orgânica.',
    'whyItMatters':
        'Essencial para saúde e meio ambiente em áreas sem esgoto. Deve ser dimensionada corretamente e ter manutenção.',
    'commonMistake':
        'Fazer fossa muito pequena ou sem sumidouro, causando transbordamentos e contaminação.',
    'relatedPhase': 9,
    'category': 'installations',
    'relatedTerms': ['Sumidouro', 'Esgoto'],
  },
  {
    'term': 'Sumidouro',
    'definition':
        'Poço que recebe o efluente tratado da fossa séptica e o infiltra no solo.',
    'whyItMatters':
        'Completa o tratamento do esgoto. Sem sumidouro adequado, há risco de contaminação do lençol freático.',
    'commonMistake':
        'Fazer sumidouro muito próximo de poços ou nascentes, contaminando a água.',
    'relatedPhase': 9,
    'category': 'installations',
    'relatedTerms': ['Fossa Séptica', 'Esgoto'],
  },
  {
    'term': 'Caixa de Gordura',
    'definition':
        'Dispositivo que retém gorduras da cozinha antes que cheguem ao esgoto, evitando entupimentos.',
    'whyItMatters':
        'Previne entupimentos crônicos e mau cheiro. Deve ser limpa periodicamente.',
    'commonMistake':
        'Não instalar caixa de gordura ou instalá-la em local de difícil acesso para limpeza.',
    'relatedPhase': 9,
    'category': 'installations',
    'relatedTerms': ['Esgoto', 'Fossa Séptica'],
  },
  {
    'term': 'Calha',
    'definition':
        'Canal instalado no beiral do telhado que coleta água da chuva e a direciona para os condutores verticais.',
    'whyItMatters':
        'Evita que água da chuva escorra pelas paredes, causando infiltração, mofo e deterioração da pintura.',
    'commonMistake':
        'Não instalar calhas ou dimensioná-las incorretamente, causando transbordamento.',
    'relatedPhase': 8,
    'category': 'installations',
    'relatedTerms': ['Rufos', 'Cobertura'],
  },
  {
    'term': 'Rufos',
    'definition':
        'Peças metálicas que protegem encontros entre telhado e paredes, chaminés ou outras superfícies verticais.',
    'whyItMatters':
        'Impedem infiltração de água nesses pontos críticos. Rufos mal instalados são causa comum de goteiras.',
    'commonMistake':
        'Não instalar rufos ou usar material inadequado que oxida rapidamente.',
    'relatedPhase': 8,
    'category': 'installations',
    'relatedTerms': ['Calha', 'Cobertura'],
  },
  {
    'term': 'Registro de Gaveta',
    'definition':
        'Válvula que permite interromper o fluxo de água em um ponto específico da tubulação.',
    'whyItMatters':
        'Facilita manutenções e reparos sem precisar fechar toda a água da casa. Deve haver registros setorizados.',
    'commonMistake':
        'Instalar poucos registros ou em locais de difícil acesso, dificultando manutenções.',
    'relatedPhase': 9,
    'category': 'installations',
    'relatedTerms': ['Projeto Hidrossanitário', 'Caixa d\'Água'],
  },

  // ========== ACABAMENTO (10 termos) ==========
  {
    'term': 'Reboco',
    'definition':
        'Camada de argamassa aplicada sobre a alvenaria para regularizar a superfície e prepará-la para o acabamento final.',
    'whyItMatters':
        'Protege a alvenaria, corrige imperfeições e serve de base para pintura ou revestimento. Reboco mal feito causa problemas futuros.',
    'commonMistake':
        'Aplicar reboco muito espesso de uma vez ou sobre parede suja, causando descolamento.',
    'relatedPhase': 10,
    'category': 'finishing',
    'relatedTerms': ['Chapisco', 'Emboço'],
  },
  {
    'term': 'Chapisco',
    'definition':
        'Camada áspera de argamassa aplicada sobre a alvenaria para melhorar a aderência do reboco.',
    'whyItMatters':
        'Essencial para evitar descolamento do reboco. Não fazer chapisco é economia que sai cara.',
    'commonMistake':
        'Pular o chapisco para economizar tempo, resultando em reboco que descola.',
    'relatedPhase': 10,
    'category': 'finishing',
    'relatedTerms': ['Reboco', 'Alvenaria'],
  },
  {
    'term': 'Massa Corrida',
    'definition':
        'Produto à base de PVA ou acrílico aplicado sobre reboco para deixar a parede lisa e pronta para pintura.',
    'whyItMatters':
        'Corrige pequenas imperfeições e garante acabamento liso. Essencial para pintura de qualidade.',
    'commonMistake':
        'Aplicar massa corrida sobre reboco úmido ou mal curado, causando bolhas e descascamento.',
    'relatedPhase': 13,
    'category': 'finishing',
    'relatedTerms': ['Reboco', 'Pintura'],
  },
  {
    'term': 'Gesso',
    'definition':
        'Revestimento de acabamento interno feito com pasta de gesso, mais liso e rápido que reboco + massa corrida.',
    'whyItMatters':
        'Economiza tempo e dá acabamento liso. Porém, não pode ser usado em áreas molhadas.',
    'commonMistake':
        'Usar gesso em banheiros ou áreas externas, onde ele se deteriora com umidade.',
    'relatedPhase': 10,
    'category': 'finishing',
    'relatedTerms': ['Reboco', 'Drywall'],
  },
  {
    'term': 'Cerâmica',
    'definition':
        'Revestimento de piso ou parede feito com placas de argila queimada, esmaltadas ou não.',
    'whyItMatters':
        'Durável, fácil de limpar e resistente à umidade. Ideal para banheiros, cozinhas e áreas externas.',
    'commonMistake':
        'Usar cerâmica de parede no piso ou não fazer rejunte adequado, causando infiltrações.',
    'relatedPhase': 11,
    'category': 'finishing',
    'relatedTerms': ['Porcelanato', 'Rejunte'],
  },
  {
    'term': 'Porcelanato',
    'definition':
        'Revestimento cerâmico de alta qualidade, mais resistente e menos poroso que cerâmica comum.',
    'whyItMatters':
        'Mais durável, absorve menos água e tem acabamento superior. Ideal para áreas de alto tráfego.',
    'commonMistake':
        'Instalar porcelanato polido em áreas molhadas, onde fica escorregadio.',
    'relatedPhase': 11,
    'category': 'finishing',
    'relatedTerms': ['Cerâmica', 'Rejunte'],
  },
  {
    'term': 'Rejunte',
    'definition':
        'Massa aplicada entre as peças de revestimento cerâmico para vedar juntas e dar acabamento.',
    'whyItMatters':
        'Impede infiltração de água e sujeira entre as peças. Rejunte de qualidade evita mofo e manchas.',
    'commonMistake':
        'Usar rejunte comum em áreas molhadas ou não aplicar impermeabilizante no rejunte.',
    'relatedPhase': 11,
    'category': 'finishing',
    'relatedTerms': ['Cerâmica', 'Porcelanato'],
  },
  {
    'term': 'Rodapé',
    'definition':
        'Acabamento instalado na base das paredes para proteger contra impactos e esconder o encontro piso-parede.',
    'whyItMatters':
        'Protege a parede, facilita limpeza e dá acabamento estético. Deve combinar com piso ou parede.',
    'commonMistake':
        'Não instalar rodapé ou usar material de baixa qualidade que descola facilmente.',
    'relatedPhase': 12,
    'category': 'finishing',
    'relatedTerms': ['Piso', 'Acabamento'],
  },
  {
    'term': 'Forro',
    'definition':
        'Revestimento do teto que esconde a laje, instalações e melhora o acabamento e conforto térmico/acústico.',
    'whyItMatters':
        'Melhora estética, esconde imperfeições da laje e instalações. Pode melhorar isolamento térmico.',
    'commonMistake':
        'Instalar forro sem deixar acesso para manutenção de instalações no entre-forro.',
    'relatedPhase': 12,
    'category': 'finishing',
    'relatedTerms': ['Gesso', 'PVC'],
  },
  {
    'term': 'Pintura',
    'definition':
        'Acabamento final das paredes e tetos com tinta, protegendo e decorando as superfícies.',
    'whyItMatters':
        'Protege contra umidade, facilita limpeza e define a estética dos ambientes. Tinta de qualidade dura mais.',
    'commonMistake':
        'Pintar sobre superfície úmida ou mal preparada, causando bolhas e descascamento.',
    'relatedPhase': 13,
    'category': 'finishing',
    'relatedTerms': ['Massa Corrida', 'Selador'],
  },

  // ========== FINANCEIRO (8 termos) ==========
  {
    'term': 'Orçamento',
    'definition':
        'Estimativa detalhada de todos os custos da obra, incluindo materiais, mão de obra, equipamentos e despesas indiretas.',
    'whyItMatters':
        'Permite planejar financeiramente e comparar propostas. Orçamento mal feito causa estouro de custos.',
    'commonMistake':
        'Aceitar orçamento genérico sem detalhamento ou não incluir margem de segurança de 10-15%.',
    'relatedPhase': 1,
    'category': 'financial',
    'relatedTerms': ['Memorial Descritivo', 'Cronograma'],
  },
  {
    'term': 'Medição',
    'definition':
        'Processo de quantificar o que foi executado na obra para calcular o pagamento devido ao construtor.',
    'whyItMatters':
        'Garante que você pague apenas pelo que foi realmente executado. Deve ser feita por profissional qualificado.',
    'commonMistake':
        'Pagar sem medir ou aceitar medições superficiais, pagando por serviços não executados.',
    'relatedPhase': null,
    'category': 'financial',
    'relatedTerms': ['Cronograma', 'Orçamento'],
  },
  {
    'term': 'BDI',
    'definition':
        'Benefícios e Despesas Indiretas - percentual sobre custos diretos que cobre lucro, impostos, administração e imprevistos.',
    'whyItMatters':
        'Entender o BDI ajuda a avaliar se o orçamento está justo. BDI muito alto ou muito baixo são sinais de alerta.',
    'commonMistake':
        'Não questionar BDI muito alto (acima de 30%) ou aceitar BDI muito baixo que inviabiliza a obra.',
    'relatedPhase': 1,
    'category': 'financial',
    'relatedTerms': ['Orçamento', 'Lucro'],
  },
  {
    'term': 'Reajuste',
    'definition':
        'Correção de valores do contrato devido a variação de custos de materiais e mão de obra ao longo da obra.',
    'whyItMatters':
        'Protege ambas as partes de variações econômicas. Deve estar previsto em contrato com índice definido.',
    'commonMistake':
        'Não prever reajuste em contrato ou usar índice inadequado, causando disputas.',
    'relatedPhase': null,
    'category': 'financial',
    'relatedTerms': ['Contrato', 'Orçamento'],
  },
  {
    'term': 'Aditivo',
    'definition':
        'Alteração formal do contrato original para incluir serviços extras, mudanças de projeto ou ajustes de prazo.',
    'whyItMatters':
        'Formaliza mudanças e evita disputas. Todo serviço extra deve ter aditivo assinado antes da execução.',
    'commonMistake':
        'Aceitar serviços extras sem aditivo formal, gerando cobranças surpresa no final.',
    'relatedPhase': null,
    'category': 'financial',
    'relatedTerms': ['Contrato', 'Orçamento'],
  },
  {
    'term': 'Retenção',
    'definition':
        'Percentual do pagamento retido até a conclusão e aprovação final da obra, garantindo correção de pendências.',
    'whyItMatters':
        'Protege o proprietário, garantindo que o construtor finalize tudo corretamente. Geralmente 5-10% do valor.',
    'commonMistake':
        'Não reter valor ou liberar retenção antes de verificar todas as pendências.',
    'relatedPhase': 15,
    'category': 'financial',
    'relatedTerms': ['Medição', 'Contrato'],
  },
  {
    'term': 'Garantia',
    'definition':
        'Período em que o construtor é responsável por corrigir defeitos de execução, geralmente 5 anos para estrutura.',
    'whyItMatters':
        'Protege contra vícios construtivos. Deve estar clara no contrato com prazos específicos por tipo de serviço.',
    'commonMistake':
        'Não formalizar garantias em contrato ou não acionar dentro do prazo.',
    'relatedPhase': 15,
    'category': 'financial',
    'relatedTerms': ['Contrato', 'Vícios'],
  },
  {
    'term': 'Custo por m²',
    'definition':
        'Valor total da obra dividido pela área construída, usado como referência para comparar custos.',
    'whyItMatters':
        'Facilita comparação entre orçamentos e avaliação de viabilidade. Varia conforme padrão de acabamento.',
    'commonMistake':
        'Comparar custos por m² sem considerar diferenças de padrão, terreno e complexidade.',
    'relatedPhase': 1,
    'category': 'financial',
    'relatedTerms': ['Orçamento', 'Padrão de Acabamento'],
  },

  // ========== CONDOMÍNIO (7 termos) ==========
  {
    'term': 'Convenção de Condomínio',
    'definition':
        'Documento que estabelece regras de uso, direitos e deveres dos condôminos, e funcionamento do condomínio.',
    'whyItMatters':
        'É a "lei" do condomínio. Deve ser lida antes de comprar para conhecer restrições e obrigações.',
    'commonMistake':
        'Comprar sem ler a convenção e descobrir restrições inaceitáveis depois (pets, reformas, etc).',
    'relatedPhase': null,
    'category': 'condominium',
    'relatedTerms': ['Regimento Interno', 'Assembleia'],
  },
  {
    'term': 'Regimento Interno',
    'definition':
        'Complemento da convenção com regras detalhadas de convivência, uso de áreas comuns e procedimentos.',
    'whyItMatters':
        'Define regras práticas do dia a dia. Pode ser alterado mais facilmente que a convenção.',
    'commonMistake':
        'Ignorar o regimento e violar regras, gerando multas e conflitos com vizinhos.',
    'relatedPhase': null,
    'category': 'condominium',
    'relatedTerms': ['Convenção', 'Multa'],
  },
  {
    'term': 'Fração Ideal',
    'definition':
        'Percentual da área total do terreno que pertence a cada unidade, usado para calcular despesas comuns.',
    'whyItMatters':
        'Define quanto cada unidade paga de condomínio. Unidades maiores têm fração ideal maior.',
    'commonMistake':
        'Não verificar se a fração ideal está correta na matrícula, pagando mais que o devido.',
    'relatedPhase': null,
    'category': 'condominium',
    'relatedTerms': ['Condomínio', 'Matrícula'],
  },
  {
    'term': 'Taxa de Condomínio',
    'definition':
        'Valor mensal pago por cada unidade para custear despesas comuns (limpeza, segurança, manutenção, etc).',
    'whyItMatters':
        'Despesa fixa mensal que deve ser considerada no planejamento financeiro. Inadimplência gera multa e juros.',
    'commonMistake':
        'Não pesquisar o valor do condomínio antes de comprar, descobrindo custo alto demais depois.',
    'relatedPhase': null,
    'category': 'condominium',
    'relatedTerms': ['Fração Ideal', 'Assembleia'],
  },
  {
    'term': 'Assembleia',
    'definition':
        'Reunião dos condôminos para deliberar sobre assuntos importantes do condomínio, como obras e mudanças de regras.',
    'whyItMatters':
        'É onde decisões importantes são tomadas. Participar é direito e dever para defender seus interesses.',
    'commonMistake':
        'Não participar de assembleias e depois reclamar de decisões tomadas.',
    'relatedPhase': null,
    'category': 'condominium',
    'relatedTerms': ['Convenção', 'Síndico'],
  },
  {
    'term': 'Síndico',
    'definition':
        'Representante legal do condomínio, responsável pela administração e cumprimento da convenção.',
    'whyItMatters':
        'Administra recursos, contrata serviços e representa o condomínio. Bom síndico faz diferença na qualidade de vida.',
    'commonMistake':
        'Eleger síndico sem experiência ou não fiscalizar a gestão, permitindo má administração.',
    'relatedPhase': null,
    'category': 'condominium',
    'relatedTerms': ['Assembleia', 'Convenção'],
  },
  {
    'term': 'Fundo de Reserva',
    'definition':
        'Valor acumulado mensalmente para custear despesas extraordinárias e emergências do condomínio.',
    'whyItMatters':
        'Evita cobranças extras surpresa quando há necessidade de reparos ou obras. Deve ter pelo menos 3 meses de despesas.',
    'commonMistake':
        'Não contribuir para fundo de reserva e ter que fazer rateio emergencial quando surge problema.',
    'relatedPhase': null,
    'category': 'condominium',
    'relatedTerms': ['Taxa de Condomínio', 'Assembleia'],
  },
  // ========== SEGURANÇA (12 termos) ==========
  {
    'term': 'EPI',
    'definition':
        'Equipamento de Proteção Individual - conjunto de dispositivos de uso pessoal para proteger trabalhadores de riscos na obra.',
    'whyItMatters':
        'Obrigatório por lei e essencial para prevenir acidentes. Obra sem EPIs pode ser embargada e gerar multas pesadas.',
    'commonMistake':
        'Não fornecer EPIs adequados ou permitir trabalho sem equipamentos de proteção.',
    'relatedPhase': null,
    'category': 'safety',
    'relatedTerms': [],
  },
  {
    'term': 'Capacete de Segurança',
    'definition':
        'EPI que protege a cabeça contra impactos de objetos em queda e choques elétricos.',
    'whyItMatters':
        'Previne traumatismos cranianos, principal causa de acidentes fatais em obras.',
    'commonMistake':
        'Usar capacete vencido, danificado ou não ajustado corretamente.',
    'relatedPhase': null,
    'category': 'safety',
    'relatedTerms': [],
  },
  {
    'term': 'Cinto de Segurança',
    'definition':
        'EPI para trabalho em altura que prende o trabalhador a ponto de ancoragem, evitando quedas.',
    'whyItMatters':
        'Obrigatório para trabalhos acima de 2 metros. Previne quedas fatais.',
    'commonMistake':
        'Usar cinto sem ponto de ancoragem adequado ou não inspecionar antes do uso.',
    'relatedPhase': null,
    'category': 'safety',
    'relatedTerms': [],
  },
  {
    'term': 'Andaime',
    'definition':
        'Estrutura temporária para trabalho em altura, com plataformas, guarda-corpos e escadas.',
    'whyItMatters':
        'Permite trabalho seguro em altura. Deve ser montado por profissional qualificado e inspecionado diariamente.',
    'commonMistake':
        'Usar andaime improvisado, sem guarda-corpo ou com sobrecarga.',
    'relatedPhase': null,
    'category': 'safety',
    'relatedTerms': [],
  },
  {
    'term': 'Guarda-Corpo',
    'definition':
        'Proteção coletiva instalada em bordas de lajes, escadas e aberturas para prevenir quedas.',
    'whyItMatters':
        'Obrigatório em qualquer desnível acima de 2 metros. Protege todos os trabalhadores simultaneamente.',
    'commonMistake':
        'Não instalar guarda-corpo ou usar material inadequado que não suporta impacto.',
    'relatedPhase': null,
    'category': 'safety',
    'relatedTerms': [],
  },
  {
    'term': 'Tela de Proteção',
    'definition':
        'Rede instalada em fachadas e aberturas para conter queda de materiais e pessoas.',
    'whyItMatters':
        'Protege pedestres e trabalhadores de objetos em queda. Obrigatória em obras urbanas.',
    'commonMistake':
        'Usar tela danificada ou não fixá-la adequadamente, perdendo eficácia.',
    'relatedPhase': null,
    'category': 'safety',
    'relatedTerms': [],
  },
  {
    'term': 'Sinalização de Obra',
    'definition':
        'Placas, faixas e dispositivos que alertam sobre riscos e orientam circulação na obra.',
    'whyItMatters':
        'Previne acidentes alertando sobre perigos. Obrigatória e deve ser visível.',
    'commonMistake':
        'Não sinalizar adequadamente ou usar placas pequenas e ilegíveis.',
    'relatedPhase': null,
    'category': 'safety',
    'relatedTerms': [],
  },
  {
    'term': 'Tapume',
    'definition':
        'Cerca que isola a obra da rua, protegendo pedestres e evitando invasões.',
    'whyItMatters':
        'Obrigatório em obras urbanas. Protege público e evita furtos de materiais.',
    'commonMistake':
        'Fazer tapume frágil ou com aberturas que permitem acesso não autorizado.',
    'relatedPhase': 2,
    'category': 'safety',
    'relatedTerms': [],
  },
  {
    'term': 'Extintor de Incêndio',
    'definition':
        'Equipamento para combate inicial a princípios de incêndio, obrigatório em obras.',
    'whyItMatters':
        'Pode evitar que pequeno foco vire incêndio grande. Deve estar acessível e com carga válida.',
    'commonMistake':
        'Não ter extintores suficientes ou deixá-los vencidos e inacessíveis.',
    'relatedPhase': null,
    'category': 'safety',
    'relatedTerms': [],
  },
  {
    'term': 'CIPA',
    'definition':
        'Comissão Interna de Prevenção de Acidentes - grupo de trabalhadores que promove segurança na obra.',
    'whyItMatters':
        'Obrigatória em obras com mais de 20 trabalhadores. Reduz acidentes significativamente.',
    'commonMistake':
        'Não formar CIPA quando obrigatório ou não dar poder de atuação à comissão.',
    'relatedPhase': null,
    'category': 'safety',
    'relatedTerms': [],
  },
  {
    'term': 'NR-18',
    'definition':
        'Norma Regulamentadora que estabelece diretrizes de segurança e saúde no trabalho na construção civil.',
    'whyItMatters':
        'Lei que deve ser cumprida. Não seguir gera multas, embargos e responsabilização por acidentes.',
    'commonMistake':
        'Desconhecer ou ignorar requisitos da NR-18, expondo trabalhadores a riscos.',
    'relatedPhase': null,
    'category': 'safety',
    'relatedTerms': [],
  },
  {
    'term': 'Primeiros Socorros',
    'definition':
        'Atendimento inicial a vítimas de acidentes antes da chegada de socorro especializado.',
    'whyItMatters':
        'Pode salvar vidas. Obra deve ter kit de primeiros socorros e pessoas treinadas.',
    'commonMistake':
        'Não ter kit completo ou ninguém treinado para atendimento emergencial.',
    'relatedPhase': null,
    'category': 'safety',
    'relatedTerms': [],
  },

  // ========== SUSTENTABILIDADE (10 termos) ==========
  {
    'term': 'Captação de Água da Chuva',
    'definition':
        'Sistema que coleta, filtra e armazena água pluvial para usos não potáveis.',
    'whyItMatters':
        'Reduz consumo de água tratada em até 50%. Economia na conta e sustentabilidade.',
    'commonMistake':
        'Dimensionar cisterna muito pequena ou não separar usos potáveis de não potáveis.',
    'relatedPhase': 9,
    'category': 'sustainability',
    'relatedTerms': [],
  },
  {
    'term': 'Energia Solar Fotovoltaica',
    'definition':
        'Sistema que converte luz solar em energia elétrica através de painéis fotovoltaicos.',
    'whyItMatters':
        'Reduz conta de luz em até 95%. Investimento se paga em 4-6 anos e valoriza imóvel.',
    'commonMistake':
        'Dimensionar sistema incorretamente ou instalar em telhado com sombreamento.',
    'relatedPhase': 14,
    'category': 'sustainability',
    'relatedTerms': [],
  },
  {
    'term': 'Aquecedor Solar',
    'definition':
        'Sistema que usa energia solar para aquecer água, reduzindo consumo de energia elétrica ou gás.',
    'whyItMatters':
        'Reduz gasto com aquecimento de água em até 80%. Retorno do investimento em 2-3 anos.',
    'commonMistake':
        'Não dimensionar boiler adequadamente ou instalar sem backup para dias nublados.',
    'relatedPhase': 9,
    'category': 'sustainability',
    'relatedTerms': [],
  },
  {
    'term': 'Isolamento Térmico',
    'definition':
        'Materiais e técnicas que reduzem troca de calor entre interior e exterior da edificação.',
    'whyItMatters':
        'Reduz necessidade de ar-condicionado e aquecimento, economizando energia e aumentando conforto.',
    'commonMistake':
        'Não isolar laje de cobertura ou usar materiais inadequados para o clima local.',
    'relatedPhase': 8,
    'category': 'sustainability',
    'relatedTerms': [],
  },
  {
    'term': 'Telhado Verde',
    'definition':
        'Cobertura com camada de vegetação sobre impermeabilização, drenagem e substrato.',
    'whyItMatters':
        'Melhora isolamento térmico, retém água da chuva, reduz ilhas de calor e embeleza.',
    'commonMistake':
        'Não fazer impermeabilização adequada ou escolher plantas inadequadas para o clima.',
    'relatedPhase': 8,
    'category': 'sustainability',
    'relatedTerms': [],
  },
  {
    'term': 'Materiais Reciclados',
    'definition':
        'Produtos de construção feitos total ou parcialmente com materiais reaproveitados.',
    'whyItMatters':
        'Reduz impacto ambiental e pode ser mais econômico. Exemplos: tijolos de entulho, madeira de demolição.',
    'commonMistake':
        'Usar materiais reciclados sem verificar qualidade e adequação estrutural.',
    'relatedPhase': null,
    'category': 'sustainability',
    'relatedTerms': [],
  },
  {
    'term': 'Madeira Certificada',
    'definition':
        'Madeira de reflorestamento ou manejo sustentável com certificação FSC ou similar.',
    'whyItMatters':
        'Garante origem legal e sustentável. Evita contribuir com desmatamento ilegal.',
    'commonMistake':
        'Comprar madeira sem certificação por preço menor, contribuindo com desmatamento.',
    'relatedPhase': null,
    'category': 'sustainability',
    'relatedTerms': [],
  },
  {
    'term': 'Gestão de Resíduos',
    'definition':
        'Plano para separar, reduzir, reutilizar e destinar corretamente resíduos da obra.',
    'whyItMatters':
        'Obrigatório por lei. Reduz custos com caçambas e evita multas ambientais.',
    'commonMistake':
        'Misturar todos os resíduos ou descartar em locais irregulares.',
    'relatedPhase': null,
    'category': 'sustainability',
    'relatedTerms': [],
  },
  {
    'term': 'Lâmpadas LED',
    'definition':
        'Tecnologia de iluminação que consome até 80% menos energia que lâmpadas incandescentes.',
    'whyItMatters':
        'Reduz drasticamente consumo de energia e dura muito mais. Investimento se paga rapidamente.',
    'commonMistake':
        'Comprar LEDs muito baratos de baixa qualidade que queimam rápido.',
    'relatedPhase': 14,
    'category': 'sustainability',
    'relatedTerms': [],
  },
  {
    'term': 'Sensor de Presença',
    'definition':
        'Dispositivo que liga/desliga luzes automaticamente detectando movimento.',
    'whyItMatters':
        'Economiza energia evitando luzes acesas desnecessariamente. Ideal para áreas de circulação.',
    'commonMistake':
        'Instalar em ambientes onde pessoas ficam paradas, causando apagões inconvenientes.',
    'relatedPhase': 14,
    'category': 'sustainability',
    'relatedTerms': [],
  },

  // ========== MANUTENÇÃO (8 termos) ==========
  {
    'term': 'Manutenção Preventiva',
    'definition':
        'Inspeções e serviços periódicos para evitar problemas antes que ocorram.',
    'whyItMatters':
        'Previne defeitos maiores e mais caros. Prolonga vida útil de sistemas e equipamentos.',
    'commonMistake':
        'Só fazer manutenção quando algo quebra, gastando muito mais com reparos emergenciais.',
    'relatedPhase': 15,
    'category': 'maintenance',
    'relatedTerms': [],
  },
  {
    'term': 'Manutenção Corretiva',
    'definition': 'Reparos realizados após falha ou defeito já ter ocorrido.',
    'whyItMatters':
        'Necessária quando preventiva falha. Geralmente mais cara e causa transtornos.',
    'commonMistake':
        'Adiar reparos necessários, agravando problemas e aumentando custos.',
    'relatedPhase': 15,
    'category': 'maintenance',
    'relatedTerms': [],
  },
  {
    'term': 'Manual do Proprietário',
    'definition':
        'Documento com instruções de uso, manutenção e garantias de todos os sistemas da casa.',
    'whyItMatters':
        'Essencial para manutenção adequada. Deve incluir cronograma de manutenções e contatos.',
    'commonMistake': 'Não exigir manual completo do construtor ou perdê-lo.',
    'relatedPhase': 15,
    'category': 'maintenance',
    'relatedTerms': [],
  },
  {
    'term': 'Inspeção Predial',
    'definition':
        'Vistoria técnica completa para identificar problemas, riscos e necessidades de manutenção.',
    'whyItMatters':
        'Recomendada a cada 2-3 anos. Identifica problemas antes que se tornem graves.',
    'commonMistake':
        'Nunca fazer inspeção profissional, descobrindo problemas graves tarde demais.',
    'relatedPhase': 15,
    'category': 'maintenance',
    'relatedTerms': [],
  },
  {
    'term': 'Limpeza de Calhas',
    'definition':
        'Remoção periódica de folhas e detritos que obstruem calhas e condutores.',
    'whyItMatters':
        'Previne entupimentos que causam infiltrações. Deve ser feita antes da época de chuvas.',
    'commonMistake':
        'Nunca limpar calhas, causando transbordamento e infiltrações.',
    'relatedPhase': 15,
    'category': 'maintenance',
    'relatedTerms': [],
  },
  {
    'term': 'Limpeza de Caixa d\'Água',
    'definition':
        'Higienização completa do reservatório de água, obrigatória a cada 6 meses.',
    'whyItMatters':
        'Previne contaminação da água e doenças. É obrigação legal do proprietário.',
    'commonMistake':
        'Não limpar regularmente ou fazer limpeza inadequada sem desinfecção.',
    'relatedPhase': 15,
    'category': 'maintenance',
    'relatedTerms': [],
  },
  {
    'term': 'Revisão Elétrica',
    'definition':
        'Inspeção periódica de instalações elétricas para identificar problemas e riscos.',
    'whyItMatters':
        'Previne curtos-circuitos, choques e incêndios. Recomendada a cada 5 anos.',
    'commonMistake':
        'Nunca revisar instalação elétrica até que ocorra problema grave.',
    'relatedPhase': 15,
    'category': 'maintenance',
    'relatedTerms': [],
  },
  {
    'term': 'Pintura de Manutenção',
    'definition':
        'Repintura periódica para proteger superfícies e manter aparência.',
    'whyItMatters':
        'Protege paredes contra umidade e desgaste. Deve ser feita a cada 3-5 anos.',
    'commonMistake':
        'Esperar pintura descascar completamente, tendo que refazer preparação da parede.',
    'relatedPhase': 15,
    'category': 'maintenance',
    'relatedTerms': [],
  },

  // ========== TECNOLOGIA (10 termos) ==========
  {
    'term': 'Automação Residencial',
    'definition':
        'Sistema que permite controlar iluminação, climatização, segurança e outros através de dispositivos inteligentes.',
    'whyItMatters':
        'Aumenta conforto, segurança e eficiência energética. Valoriza o imóvel.',
    'commonMistake':
        'Instalar sistemas incompatíveis entre si ou muito complexos de usar.',
    'relatedPhase': 14,
    'category': 'technology',
    'relatedTerms': [],
  },
  {
    'term': 'Smart Home',
    'definition':
        'Casa inteligente com dispositivos conectados à internet que podem ser controlados remotamente.',
    'whyItMatters':
        'Permite controle remoto, automações e economia de energia. Tendência crescente.',
    'commonMistake':
        'Não planejar infraestrutura de rede adequada desde o projeto.',
    'relatedPhase': 14,
    'category': 'technology',
    'relatedTerms': [],
  },
  {
    'term': 'BIM',
    'definition':
        'Building Information Modeling - metodologia que usa modelo 3D digital com todas as informações da construção.',
    'whyItMatters':
        'Reduz erros, facilita coordenação entre projetos e melhora planejamento.',
    'commonMistake':
        'Contratar profissionais que não usam BIM, perdendo benefícios da tecnologia.',
    'relatedPhase': 1,
    'category': 'technology',
    'relatedTerms': [],
  },
  {
    'term': 'Câmeras de Segurança',
    'definition':
        'Sistema de vigilância por vídeo com gravação e acesso remoto.',
    'whyItMatters':
        'Aumenta segurança e permite monitoramento remoto. Pode reduzir seguro.',
    'commonMistake':
        'Instalar câmeras sem planejamento de pontos de rede e energia.',
    'relatedPhase': 14,
    'category': 'technology',
    'relatedTerms': [],
  },
  {
    'term': 'Interfone com Vídeo',
    'definition':
        'Sistema de comunicação com câmera que permite ver visitantes antes de abrir.',
    'whyItMatters':
        'Aumenta segurança permitindo identificação visual. Pode ter acesso remoto via celular.',
    'commonMistake':
        'Instalar interfone básico sem vídeo, perdendo recurso importante de segurança.',
    'relatedPhase': 14,
    'category': 'technology',
    'relatedTerms': [],
  },
  {
    'term': 'Fechadura Digital',
    'definition':
        'Fechadura eletrônica que abre com senha, biometria, cartão ou celular.',
    'whyItMatters':
        'Elimina necessidade de chaves, permite acesso temporário e registra entradas.',
    'commonMistake':
        'Não ter backup de energia ou chave mecânica para emergências.',
    'relatedPhase': 14,
    'category': 'technology',
    'relatedTerms': [],
  },
  {
    'term': 'Rede Estruturada',
    'definition':
        'Cabeamento organizado de dados que distribui internet e telefone por toda a casa.',
    'whyItMatters':
        'Garante internet rápida e estável em todos os ambientes. Essencial para smart home.',
    'commonMistake': 'Depender só de WiFi ou fazer cabeamento inadequado.',
    'relatedPhase': 9,
    'category': 'technology',
    'relatedTerms': [],
  },
  {
    'term': 'Termostato Inteligente',
    'definition':
        'Dispositivo que controla temperatura automaticamente aprendendo hábitos e economizando energia.',
    'whyItMatters':
        'Reduz consumo de ar-condicionado em até 30% mantendo conforto.',
    'commonMistake':
        'Instalar em local inadequado que não representa temperatura real do ambiente.',
    'relatedPhase': 14,
    'category': 'technology',
    'relatedTerms': [],
  },
  {
    'term': 'Assistente Virtual',
    'definition':
        'Dispositivo com inteligência artificial que controla casa por comandos de voz.',
    'whyItMatters':
        'Facilita controle de automação, especialmente para idosos e pessoas com mobilidade reduzida.',
    'commonMistake':
        'Não verificar compatibilidade com outros dispositivos antes de comprar.',
    'relatedPhase': 14,
    'category': 'technology',
    'relatedTerms': [],
  },
  {
    'term': 'Carregador Veicular',
    'definition':
        'Ponto de recarga para carros elétricos instalado em garagem.',
    'whyItMatters':
        'Essencial para quem tem ou planeja ter carro elétrico. Valoriza imóvel.',
    'commonMistake':
        'Não prever infraestrutura elétrica adequada desde o projeto.',
    'relatedPhase': 9,
    'category': 'technology',
    'relatedTerms': [],
  },

  // ========== PAISAGISMO (10 termos) ==========
  {
    'term': 'Projeto Paisagístico',
    'definition':
        'Planejamento técnico de jardins, áreas verdes e elementos decorativos externos.',
    'whyItMatters':
        'Garante harmonia, funcionalidade e manutenção adequada. Evita erros caros.',
    'commonMistake':
        'Plantar sem projeto, escolhendo espécies inadequadas para o clima e espaço.',
    'relatedPhase': 15,
    'category': 'landscaping',
    'relatedTerms': [],
  },
  {
    'term': 'Drenagem de Jardim',
    'definition':
        'Sistema que remove excesso de água do solo, evitando encharcamento.',
    'whyItMatters':
        'Previne morte de plantas e problemas estruturais. Essencial em terrenos com má drenagem.',
    'commonMistake':
        'Não fazer drenagem adequada, causando morte de plantas e infiltrações.',
    'relatedPhase': 15,
    'category': 'landscaping',
    'relatedTerms': [],
  },
  {
    'term': 'Irrigação por Gotejamento',
    'definition':
        'Sistema que fornece água diretamente às raízes gota a gota, economizando água.',
    'whyItMatters':
        'Economiza até 70% de água comparado a irrigação convencional. Mais eficiente.',
    'commonMistake': 'Usar mangueira manual, desperdiçando água e tempo.',
    'relatedPhase': 15,
    'category': 'landscaping',
    'relatedTerms': [],
  },
  {
    'term': 'Grama',
    'definition': 'Cobertura vegetal rasteira para jardins e áreas de lazer.',
    'whyItMatters':
        'Embeleza, reduz temperatura e permite uso recreativo. Requer manutenção regular.',
    'commonMistake':
        'Escolher tipo de grama inadequado para clima, sol/sombra e uso.',
    'relatedPhase': 15,
    'category': 'landscaping',
    'relatedTerms': [],
  },
  {
    'term': 'Deck',
    'definition': 'Piso elevado de madeira ou composto para áreas externas.',
    'whyItMatters':
        'Cria área de convivência confortável e bonita. Requer manutenção periódica.',
    'commonMistake':
        'Usar madeira não tratada ou sem impermeabilização, apodrecendo rapidamente.',
    'relatedPhase': 15,
    'category': 'landscaping',
    'relatedTerms': [],
  },
  {
    'term': 'Pergolado',
    'definition':
        'Estrutura de madeira ou metal com cobertura parcial para sombreamento.',
    'whyItMatters':
        'Cria área sombreada agradável. Pode ter plantas trepadeiras.',
    'commonMistake':
        'Não tratar madeira adequadamente ou não dimensionar estrutura corretamente.',
    'relatedPhase': 15,
    'category': 'landscaping',
    'relatedTerms': [],
  },
  {
    'term': 'Iluminação de Jardim',
    'definition':
        'Sistema de luminárias externas para valorizar paisagismo e permitir uso noturno.',
    'whyItMatters': 'Valoriza jardim, aumenta segurança e permite uso à noite.',
    'commonMistake':
        'Usar luminárias não apropriadas para externo ou iluminação excessiva.',
    'relatedPhase': 15,
    'category': 'landscaping',
    'relatedTerms': [],
  },
  {
    'term': 'Muro Verde',
    'definition': 'Parede coberta com vegetação, criando jardim vertical.',
    'whyItMatters':
        'Embeleza, melhora isolamento térmico e acústico. Ideal para espaços pequenos.',
    'commonMistake':
        'Não fazer impermeabilização adequada da parede ou escolher plantas inadequadas.',
    'relatedPhase': 15,
    'category': 'landscaping',
    'relatedTerms': [],
  },
  {
    'term': 'Horta',
    'definition': 'Área para cultivo de hortaliças, temperos e ervas.',
    'whyItMatters':
        'Fornece alimentos frescos e orgânicos. Atividade terapêutica e educativa.',
    'commonMistake':
        'Plantar em local com pouco sol ou sem preparar solo adequadamente.',
    'relatedPhase': 15,
    'category': 'landscaping',
    'relatedTerms': [],
  },
  {
    'term': 'Cerca Viva',
    'definition': 'Barreira natural formada por arbustos plantados em linha.',
    'whyItMatters':
        'Delimita espaço, dá privacidade e embeleza. Mais bonita que muro.',
    'commonMistake':
        'Escolher espécie de crescimento muito lento ou que requer muita manutenção.',
    'relatedPhase': 15,
    'category': 'landscaping',
    'relatedTerms': [],
  },

  // ========== ACESSIBILIDADE (10 termos) ==========
  {
    'term': 'NBR 9050',
    'definition':
        'Norma brasileira que estabelece critérios de acessibilidade em edificações.',
    'whyItMatters':
        'Obrigatória em edifícios públicos e recomendada em residências. Garante acesso universal.',
    'commonMistake':
        'Ignorar norma em projeto residencial, dificultando uso futuro por idosos ou pessoas com deficiência.',
    'relatedPhase': 1,
    'category': 'accessibility',
    'relatedTerms': [],
  },
  {
    'term': 'Rampa de Acesso',
    'definition':
        'Plano inclinado que permite acesso de cadeirantes e pessoas com mobilidade reduzida.',
    'whyItMatters':
        'Essencial para acessibilidade. Deve ter inclinação máxima de 8,33% e corrimão.',
    'commonMistake':
        'Fazer rampa muito íngreme ou sem corrimão, tornando-a perigosa.',
    'relatedPhase': 15,
    'category': 'accessibility',
    'relatedTerms': [],
  },
  {
    'term': 'Corrimão',
    'definition': 'Barra de apoio instalada em escadas, rampas e corredores.',
    'whyItMatters':
        'Essencial para segurança de idosos e pessoas com mobilidade reduzida.',
    'commonMistake': 'Instalar apenas de um lado ou em altura inadequada.',
    'relatedPhase': 15,
    'category': 'accessibility',
    'relatedTerms': [],
  },
  {
    'term': 'Barra de Apoio',
    'definition':
        'Barra fixada em paredes de banheiros para auxiliar transferências e equilíbrio.',
    'whyItMatters':
        'Previne quedas em banheiros, local de maior risco para idosos.',
    'commonMistake':
        'Instalar em parede sem reforço estrutural, soltando quando usada.',
    'relatedPhase': 15,
    'category': 'accessibility',
    'relatedTerms': [],
  },
  {
    'term': 'Piso Tátil',
    'definition':
        'Piso com textura diferenciada para orientar pessoas com deficiência visual.',
    'whyItMatters':
        'Obrigatório em espaços públicos. Orienta e alerta sobre obstáculos.',
    'commonMistake':
        'Instalar piso tátil apenas decorativamente, sem seguir padrões corretos.',
    'relatedPhase': 15,
    'category': 'accessibility',
    'relatedTerms': [],
  },
  {
    'term': 'Piso Antiderrapante',
    'definition': 'Revestimento com textura que reduz risco de escorregões.',
    'whyItMatters':
        'Essencial em áreas molhadas. Previne quedas, especialmente de idosos.',
    'commonMistake': 'Usar porcelanato polido em banheiros e áreas externas.',
    'relatedPhase': 11,
    'category': 'accessibility',
    'relatedTerms': [],
  },
  {
    'term': 'Porta Larga',
    'definition':
        'Vão de porta com mínimo 80cm para permitir passagem de cadeira de rodas.',
    'whyItMatters':
        'Essencial para acessibilidade. Facilita também passagem de móveis.',
    'commonMistake':
        'Fazer portas de 70cm, padrão antigo que impede acesso de cadeirantes.',
    'relatedPhase': 12,
    'category': 'accessibility',
    'relatedTerms': [],
  },
  {
    'term': 'Banheiro Acessível',
    'definition':
        'Banheiro com dimensões e equipamentos adequados para uso por cadeirantes.',
    'whyItMatters':
        'Permite autonomia e dignidade. Deve ter área de manobra, barras e altura adequada.',
    'commonMistake':
        'Fazer banheiro pequeno demais ou instalar barras em posições inadequadas.',
    'relatedPhase': 12,
    'category': 'accessibility',
    'relatedTerms': [],
  },
  {
    'term': 'Elevador Residencial',
    'definition':
        'Equipamento para transporte vertical, essencial em casas com múltiplos pavimentos.',
    'whyItMatters':
        'Garante acessibilidade e valoriza imóvel. Essencial para idosos e pessoas com mobilidade reduzida.',
    'commonMistake':
        'Não prever espaço para elevador no projeto, impossibilitando instalação futura.',
    'relatedPhase': 1,
    'category': 'accessibility',
    'relatedTerms': [],
  },
  {
    'term': 'Iluminação Adequada',
    'definition':
        'Sistema de iluminação que garante visibilidade segura em todos os ambientes.',
    'whyItMatters':
        'Previne quedas e acidentes, especialmente para idosos com visão reduzida.',
    'commonMistake':
        'Deixar áreas escuras ou com iluminação insuficiente em circulações.',
    'relatedPhase': 14,
    'category': 'accessibility',
    'relatedTerms': [],
  },
];

// Made with Bob
