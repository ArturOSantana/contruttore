import 'package:flutter/material.dart';

/// Paleta de cores do Costruttore
/// Baseada em tons terrosos e naturais para transmitir confiança e solidez
class AppColors {
  AppColors._();

  // Cores Primárias - Terracota
  static const Color primary = Color(0xFFBF5942);
  static const Color primaryLight = Color(0xFFD47A65);
  static const Color primaryDark = Color(0xFFA04532);

  // Cores Secundárias - Areia
  static const Color secondary = Color(0xFFF7F3EE);
  static const Color secondaryLight = Color(0xFFFFFBF7);
  static const Color secondaryDark = Color(0xFFE8E0D5);

  // Cores de Fundo
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Cores de Texto
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Cores de Status
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFC62828);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF42A5F5);
  static const Color infoDark = Color(0xFF1976D2);

  // Cores de Borda e Divisores
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // Cores de Sombra
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowDark = Color(0x33000000);

  // Cores de Overlay
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // Cores de Fase (para indicadores de progresso)
  static const Color phaseNotStarted = Color(0xFFE0E0E0);
  static const Color phaseInProgress = Color(0xFFBF5942);
  static const Color phaseCompleted = Color(0xFF4CAF50);
  static const Color phaseDelayed = Color(0xFFFFA726);

  // Cores de fase por categoria (para agrupamento visual)
  static const Color phaseBlue = Color(0xFF1976D2);
  static const Color phaseGreen = Color(0xFF388E3C);
  static const Color phaseOrange = Color(0xFFF57C00);
  static const Color phasePurple = Color(0xFF7B1FA2);
}

/// Classe auxiliar para border radius
class AppRadius {
  AppRadius._();

  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 24.0;
}

// Made with Bob
