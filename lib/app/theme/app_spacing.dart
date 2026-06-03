/// Sistema de espaçamento baseado em múltiplos de 4pt
/// Garante consistência visual em todo o aplicativo
class AppSpacing {
  AppSpacing._();

  // Espaçamentos base (múltiplos de 4)
  static const double xs = 4.0; // Extra small
  static const double sm = 8.0; // Small
  static const double md = 16.0; // Medium
  static const double lg = 24.0; // Large
  static const double xl = 32.0; // Extra large
  static const double xxl = 48.0; // Extra extra large

  // Aliases para compatibilidade
  static const double xxs = xs; // Alias para xs
  static const double s = sm; // Alias para sm
  static const double m = md; // Alias para md
  static const double l = lg; // Alias para lg

  // Espaçamentos específicos
  static const double none = 0.0;
  static const double tiny = 2.0;
  static const double huge = 64.0;

  // Padding padrão de telas
  static const double screenPadding = md;
  static const double screenPaddingHorizontal = md;
  static const double screenPaddingVertical = lg;

  // Espaçamento entre cards
  static const double cardSpacing = md;

  // Espaçamento entre seções
  static const double sectionSpacing = xl;

  // Espaçamento entre elementos de lista
  static const double listItemSpacing = sm;

  // Espaçamento interno de cards
  static const double cardPadding = md;

  // Espaçamento de botões
  static const double buttonPadding = md;
  static const double buttonSpacing = sm;

  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // Elevação (para sombras)
  static const double elevationNone = 0.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;

  // Tamanhos de ícones
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Tamanhos de avatar
  static const double avatarSm = 32.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 64.0;
  static const double avatarXl = 96.0;

  // Altura de componentes
  static const double buttonHeight = 48.0;
  static const double inputHeight = 48.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 64.0;
  static const double tabBarHeight = 48.0;
}

// Made with Bob
