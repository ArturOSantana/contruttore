/// Sistema de espaçamento baseado em múltiplos de 4pt
/// Design System Profissional - Hierarquia clara e respiro visual
class AppSpacing {
  AppSpacing._();

  // ═══════════════════════════════════════════════════════════
  // ESPAÇAMENTOS BASE - Sistema 4pt
  // ═══════════════════════════════════════════════════════════

  /// Nenhum espaçamento
  static const double none = 0.0;

  /// Micro - 2px (para ajustes finos)
  static const double micro = 2.0;

  /// Extra pequeno - 4px
  static const double xs = 4.0;

  /// Pequeno - 8px
  static const double sm = 8.0;

  /// Médio - 16px (base do sistema)
  static const double md = 16.0;

  /// Grande - 24px
  static const double lg = 24.0;

  /// Extra grande - 32px
  static const double xl = 32.0;

  /// Extra extra grande - 48px
  static const double xxl = 48.0;

  /// Enorme - 64px (para seções especiais)
  static const double huge = 64.0;

  // ═══════════════════════════════════════════════════════════
  // ALIASES - Compatibilidade com código existente
  // ═══════════════════════════════════════════════════════════

  static const double xxs = xs;
  static const double tiny = micro;
  static const double s = sm;
  static const double m = md;
  static const double l = lg;

  // ═══════════════════════════════════════════════════════════
  // PADDING DE TELAS - Consistência em layouts
  // ═══════════════════════════════════════════════════════════

  /// Padding padrão de telas - 20px (mais generoso)
  static const double screenPadding = 20.0;

  /// Padding horizontal de telas
  static const double screenPaddingHorizontal = 20.0;

  /// Padding vertical de telas
  static const double screenPaddingVertical = 24.0;

  /// Padding compacto para telas densas
  static const double screenPaddingCompact = 16.0;

  /// Padding expandido para telas com respiro
  static const double screenPaddingExpanded = 32.0;

  // ═══════════════════════════════════════════════════════════
  // ESPAÇAMENTO DE COMPONENTES
  // ═══════════════════════════════════════════════════════════

  /// Espaçamento entre cards - 16px
  static const double cardSpacing = 16.0;

  /// Espaçamento entre seções - 32px
  static const double sectionSpacing = 32.0;

  /// Espaçamento entre elementos de lista - 12px
  static const double listItemSpacing = 12.0;

  /// Espaçamento interno de cards - 20px (mais generoso)
  static const double cardPadding = 20.0;

  /// Espaçamento interno compacto - 12px
  static const double cardPaddingCompact = 12.0;

  /// Espaçamento de botões - 16px
  static const double buttonPadding = 16.0;

  /// Espaçamento entre botões - 12px
  static const double buttonSpacing = 12.0;

  /// Espaçamento entre grupos - 24px
  static const double groupSpacing = 24.0;

  // ═══════════════════════════════════════════════════════════
  // BORDER RADIUS - Sistema de arredondamento
  // ═══════════════════════════════════════════════════════════

  /// Nenhum arredondamento
  static const double radiusNone = 0.0;

  /// Extra pequeno - 4px
  static const double radiusXs = 4.0;

  /// Pequeno - 8px
  static const double radiusSm = 8.0;

  /// Médio - 12px (padrão para cards)
  static const double radiusMd = 12.0;

  /// Grande - 16px
  static const double radiusLg = 16.0;

  /// Extra grande - 24px
  static const double radiusXl = 24.0;

  /// Circular completo
  static const double radiusFull = 999.0;

  // ═══════════════════════════════════════════════════════════
  // ELEVAÇÃO - Sistema de sombras (valores reduzidos)
  // ═══════════════════════════════════════════════════════════

  /// Sem elevação
  static const double elevationNone = 0.0;

  /// Elevação mínima - 1px (muito sutil)
  static const double elevationXs = 1.0;

  /// Elevação pequena - 2px
  static const double elevationSm = 2.0;

  /// Elevação média - 4px
  static const double elevationMd = 4.0;

  /// Elevação grande - 8px
  static const double elevationLg = 8.0;

  /// Elevação extra grande - 12px
  static const double elevationXl = 12.0;

  /// Elevação máxima - 16px (para modais)
  static const double elevationMax = 16.0;

  // ═══════════════════════════════════════════════════════════
  // TAMANHOS DE ÍCONES - Hierarquia visual
  // ═══════════════════════════════════════════════════════════

  /// Ícone extra pequeno - 16px
  static const double iconXs = 16.0;

  /// Ícone pequeno - 20px
  static const double iconSm = 20.0;

  /// Ícone médio - 24px (padrão)
  static const double iconMd = 24.0;

  /// Ícone grande - 32px
  static const double iconLg = 32.0;

  /// Ícone extra grande - 48px
  static const double iconXl = 48.0;

  /// Ícone enorme - 64px (para ilustrações)
  static const double iconXxl = 64.0;

  // ═══════════════════════════════════════════════════════════
  // TAMANHOS DE AVATAR - Consistência
  // ═══════════════════════════════════════════════════════════

  /// Avatar extra pequeno - 24px
  static const double avatarXs = 24.0;

  /// Avatar pequeno - 32px
  static const double avatarSm = 32.0;

  /// Avatar médio - 48px
  static const double avatarMd = 48.0;

  /// Avatar grande - 64px
  static const double avatarLg = 64.0;

  /// Avatar extra grande - 96px
  static const double avatarXl = 96.0;

  /// Avatar enorme - 128px
  static const double avatarXxl = 128.0;

  // ═══════════════════════════════════════════════════════════
  // ALTURA DE COMPONENTES - Padrões de UI
  // ═══════════════════════════════════════════════════════════

  /// Altura de botão compacto - 40px
  static const double buttonHeightCompact = 40.0;

  /// Altura de botão padrão - 48px
  static const double buttonHeight = 48.0;

  /// Altura de botão grande - 56px
  static const double buttonHeightLarge = 56.0;

  /// Altura de input - 48px
  static const double inputHeight = 48.0;

  /// Altura de input compacto - 40px
  static const double inputHeightCompact = 40.0;

  /// Altura de AppBar - 56px
  static const double appBarHeight = 56.0;

  /// Altura de Bottom Navigation - 64px
  static const double bottomNavHeight = 64.0;

  /// Altura de Tab Bar - 48px
  static const double tabBarHeight = 48.0;

  /// Altura de List Tile - 56px
  static const double listTileHeight = 56.0;

  /// Altura de List Tile compacto - 48px
  static const double listTileHeightCompact = 48.0;

  // ═══════════════════════════════════════════════════════════
  // LARGURAS - Para componentes específicos
  // ═══════════════════════════════════════════════════════════

  /// Largura máxima de conteúdo (para legibilidade)
  static const double maxContentWidth = 600.0;

  /// Largura de sidebar
  static const double sidebarWidth = 280.0;

  /// Largura de drawer
  static const double drawerWidth = 304.0;

  /// Largura mínima de card
  static const double cardMinWidth = 280.0;

  // ═══════════════════════════════════════════════════════════
  // ESPAÇAMENTO RESPONSIVO - Breakpoints
  // ═══════════════════════════════════════════════════════════

  /// Mobile - até 600px
  static const double breakpointMobile = 600.0;

  /// Tablet - até 900px
  static const double breakpointTablet = 900.0;

  /// Desktop - acima de 900px
  static const double breakpointDesktop = 900.0;

  // ═══════════════════════════════════════════════════════════
  // ANIMAÇÕES - Durações em milissegundos
  // ═══════════════════════════════════════════════════════════

  /// Animação muito rápida - 100ms
  static const int animationFast = 100;

  /// Animação rápida - 200ms
  static const int animationQuick = 200;

  /// Animação normal - 300ms
  static const int animationNormal = 300;

  /// Animação lenta - 500ms
  static const int animationSlow = 500;

  /// Animação muito lenta - 800ms
  static const int animationVerySlow = 800;

  // ═══════════════════════════════════════════════════════════
  // OPACIDADES - Para overlays e estados
  // ═══════════════════════════════════════════════════════════

  /// Opacidade muito leve - 5%
  static const double opacityVeryLight = 0.05;

  /// Opacidade leve - 10%
  static const double opacityLight = 0.10;

  /// Opacidade média - 20%
  static const double opacityMedium = 0.20;

  /// Opacidade forte - 40%
  static const double opacityStrong = 0.40;

  /// Opacidade muito forte - 60%
  static const double opacityVeryStrong = 0.60;

  /// Opacidade de overlay - 80%
  static const double opacityOverlay = 0.80;

  // ═══════════════════════════════════════════════════════════
  // HELPERS - Funções utilitárias
  // ═══════════════════════════════════════════════════════════

  /// Retorna padding responsivo baseado na largura da tela
  static double responsivePadding(double screenWidth) {
    if (screenWidth < breakpointMobile) {
      return screenPaddingCompact;
    } else if (screenWidth < breakpointTablet) {
      return screenPadding;
    } else {
      return screenPaddingExpanded;
    }
  }

  /// Retorna espaçamento de card responsivo
  static double responsiveCardSpacing(double screenWidth) {
    if (screenWidth < breakpointMobile) {
      return 12.0;
    } else {
      return cardSpacing;
    }
  }
}

// Made with ❤️ by Bob - Redesign Profissional 2026

// Made with Bob
