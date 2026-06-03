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
];

// Made with Bob
