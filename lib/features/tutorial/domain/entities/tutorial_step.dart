/// Entidade que representa um passo do tutorial
class TutorialStep {
  final String title;
  final String description;
  final String imagePath;
  final String? iconData;
  final List<String> highlights;

  const TutorialStep({
    required this.title,
    required this.description,
    required this.imagePath,
    this.iconData,
    this.highlights = const [],
  });
}

/// Passos do tutorial do Costruttore
class TutorialSteps {
  TutorialSteps._();

  static const List<TutorialStep> steps = [
    TutorialStep(
      title: 'Bem-vindo ao Costruttore!',
      description:
          'Seu assistente completo para gerenciar sua obra do início ao fim. Controle custos, acompanhe o progresso e mantenha tudo organizado em um só lugar.',
      imagePath: 'assets/tutorial/welcome.png',
      iconData: 'home_work',
      highlights: [
        'Gestão completa da obra',
        'Controle financeiro',
        'Acompanhamento em tempo real',
      ],
    ),
    TutorialStep(
      title: 'Organize por Fases',
      description:
          'Divida sua obra em 12 fases estruturadas, desde o projeto até a entrega. Acompanhe o progresso de cada etapa e saiba exatamente onde você está.',
      imagePath: 'assets/tutorial/phases.png',
      iconData: 'timeline',
      highlights: [
        '12 fases pré-definidas',
        'Progresso visual',
        'Tarefas por fase',
      ],
    ),
    TutorialStep(
      title: 'Controle Financeiro',
      description:
          'Registre todas as despesas, acompanhe pagamentos e compare orçamentos. Tenha visão completa dos gastos e mantenha sua obra dentro do orçamento.',
      imagePath: 'assets/tutorial/financial.png',
      iconData: 'account_balance_wallet',
      highlights: [
        'Registro de despesas',
        'Controle de pagamentos',
        'Relatórios detalhados',
      ],
    ),
    TutorialStep(
      title: 'Compare Fornecedores',
      description:
          'Cadastre fornecedores, solicite orçamentos e compare preços lado a lado. Tome decisões informadas e economize na sua obra.',
      imagePath: 'assets/tutorial/suppliers.png',
      iconData: 'store',
      highlights: [
        'Cadastro de fornecedores',
        'Comparação de orçamentos',
        'Histórico de compras',
      ],
    ),
    TutorialStep(
      title: 'Diário de Obra',
      description:
          'Registre o dia a dia da construção com fotos, anotações e progresso. Mantenha um histórico completo e compartilhe atualizações.',
      imagePath: 'assets/tutorial/diary.png',
      iconData: 'photo_camera',
      highlights: ['Fotos e anotações', 'Registro diário', 'Linha do tempo'],
    ),
    TutorialStep(
      title: 'Lista de Compras',
      description:
          'Organize suas compras por fase e categoria. Nunca mais esqueça materiais importantes e otimize suas idas às lojas.',
      imagePath: 'assets/tutorial/shopping.png',
      iconData: 'shopping_cart',
      highlights: [
        'Organização por fase',
        'Checklist de materiais',
        'Controle de estoque',
      ],
    ),
    TutorialStep(
      title: 'Alertas Inteligentes',
      description:
          'Receba notificações sobre pagamentos, prazos e atualizações importantes. Nunca perca um prazo ou compromisso.',
      imagePath: 'assets/tutorial/alerts.png',
      iconData: 'notifications_active',
      highlights: [
        'Lembretes de pagamento',
        'Alertas de prazo',
        'Notificações personalizadas',
      ],
    ),
    TutorialStep(
      title: 'Pronto para Começar!',
      description:
          'Agora você conhece todas as funcionalidades. Vamos configurar sua obra e começar a construir o futuro dos seus sonhos!',
      imagePath: 'assets/tutorial/start.png',
      iconData: 'rocket_launch',
      highlights: [
        'Configure sua obra',
        'Comece a usar agora',
        'Suporte sempre disponível',
      ],
    ),
  ];
}

// Made with Bob
