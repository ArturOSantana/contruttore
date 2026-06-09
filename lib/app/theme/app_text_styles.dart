import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Sistema de tipografia do Costruttore - Design System Profissional
/// Baseado na fonte Inter com hierarquia clara e legibilidade otimizada
/// Inspirado em sistemas modernos como Notion, Linear e Arc
class AppTextStyles {
  AppTextStyles._();

  // ═══════════════════════════════════════════════════════════
  // FAMÍLIA DE FONTE - Inter (mais moderna que DM Sans)
  // ═══════════════════════════════════════════════════════════

  /// Família de fonte base - Inter
  /// Fallback para DM Sans se Inter não estiver disponível
  static TextStyle get _baseStyle {
    try {
      return GoogleFonts.inter(
        letterSpacing: -0.01, // Tracking mais apertado para modernidade
      );
    } catch (e) {
      // Fallback para DM Sans
      return GoogleFonts.dmSans();
    }
  }

  // ═══════════════════════════════════════════════════════════
  // DISPLAY - Para títulos grandes e hero sections
  // ═══════════════════════════════════════════════════════════

  static TextStyle get displayLarge => _baseStyle.copyWith(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -1.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get displayMedium => _baseStyle.copyWith(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -1.0,
        color: AppColors.textPrimary,
      );

  static TextStyle get displaySmall => _baseStyle.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  // ═══════════════════════════════════════════════════════════
  // HEADLINE - Para títulos de seções e páginas
  // ═══════════════════════════════════════════════════════════

  static TextStyle get headlineLarge => _baseStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.4,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMedium => _baseStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineSmall => _baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
      );

  // ═══════════════════════════════════════════════════════════
  // TITLE - Para títulos de cards e componentes
  // ═══════════════════════════════════════════════════════════

  static TextStyle get titleLarge => _baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: -0.15,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
        letterSpacing: -0.1,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleSmall => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.45,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  // ═══════════════════════════════════════════════════════════
  // BODY - Para texto de conteúdo (mais legível)
  // ═══════════════════════════════════════════════════════════

  static TextStyle get bodyLarge => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6, // Maior altura de linha para legibilidade
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.55,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => _baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
        color: AppColors.textSecondary,
      );

  // ═══════════════════════════════════════════════════════════
  // LABEL - Para labels de botões, badges e campos
  // ═══════════════════════════════════════════════════════════

  static TextStyle get labelLarge => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.1,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelMedium => _baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: 0.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelSmall => _baseStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.3,
        color: AppColors.textSecondary,
      );

  // ═══════════════════════════════════════════════════════════
  // ESTILOS ESPECÍFICOS DO APP
  // ═══════════════════════════════════════════════════════════

  /// Texto de botão
  static TextStyle get buttonText => labelLarge.copyWith(
        color: AppColors.textOnPrimary,
        fontWeight: FontWeight.w600,
      );

  /// Caption - Para textos auxiliares
  static TextStyle get caption => bodySmall.copyWith(
        color: AppColors.textTertiary,
        fontSize: 12,
      );

  /// Overline - Para labels superiores
  static TextStyle get overline => labelSmall.copyWith(
        textBaseline: TextBaseline.alphabetic,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      );

  // ═══════════════════════════════════════════════════════════
  // ESTILOS PARA VALORES MONETÁRIOS
  // ═══════════════════════════════════════════════════════════

  /// Valor monetário grande - Para destaque
  static TextStyle get currencyLarge => displaySmall.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        fontFeatures: [const FontFeature.tabularFigures()], // Números tabulares
      );

  /// Valor monetário médio
  static TextStyle get currencyMedium => headlineSmall.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        fontFeatures: [const FontFeature.tabularFigures()],
      );

  /// Valor monetário pequeno
  static TextStyle get currencySmall => titleMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        fontFeatures: [const FontFeature.tabularFigures()],
      );

  // ═══════════════════════════════════════════════════════════
  // ESTILOS PARA STATUS - Semântica visual
  // ═══════════════════════════════════════════════════════════

  /// Status de sucesso
  static TextStyle get statusSuccess => labelMedium.copyWith(
        color: AppColors.success,
        fontWeight: FontWeight.w600,
      );

  /// Status de aviso
  static TextStyle get statusWarning => labelMedium.copyWith(
        color: AppColors.warning,
        fontWeight: FontWeight.w600,
      );

  /// Status de erro
  static TextStyle get statusError => labelMedium.copyWith(
        color: AppColors.error,
        fontWeight: FontWeight.w600,
      );

  /// Status de informação
  static TextStyle get statusInfo => labelMedium.copyWith(
        color: AppColors.info,
        fontWeight: FontWeight.w600,
      );

  // ═══════════════════════════════════════════════════════════
  // ESTILOS PARA NÚMEROS E MÉTRICAS
  // ═══════════════════════════════════════════════════════════

  /// Número grande - Para KPIs e métricas
  static TextStyle get numberLarge => displayMedium.copyWith(
        fontWeight: FontWeight.w700,
        fontFeatures: [const FontFeature.tabularFigures()],
        color: AppColors.textPrimary,
      );

  /// Número médio
  static TextStyle get numberMedium => headlineMedium.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: [const FontFeature.tabularFigures()],
        color: AppColors.textPrimary,
      );

  /// Número pequeno
  static TextStyle get numberSmall => titleLarge.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: [const FontFeature.tabularFigures()],
        color: AppColors.textPrimary,
      );

  // ═══════════════════════════════════════════════════════════
  // ESTILOS PARA CÓDIGO E MONOSPACE
  // ═══════════════════════════════════════════════════════════

  /// Código inline
  static TextStyle get code => bodyMedium.copyWith(
        fontFamily: 'monospace',
        backgroundColor: AppColors.surfaceVariant,
        color: AppColors.primary,
      );

  /// Código em bloco
  static TextStyle get codeBlock => bodySmall.copyWith(
        fontFamily: 'monospace',
        height: 1.6,
        color: AppColors.textPrimary,
      );

  // ═══════════════════════════════════════════════════════════
  // ESTILOS PARA LINKS
  // ═══════════════════════════════════════════════════════════

  /// Link padrão
  static TextStyle get link => bodyMedium.copyWith(
        color: AppColors.blue,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.blue,
      );

  /// Link pequeno
  static TextStyle get linkSmall => bodySmall.copyWith(
        color: AppColors.blue,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.blue,
      );

  // ═══════════════════════════════════════════════════════════
  // ALIASES - Compatibilidade com código existente
  // ═══════════════════════════════════════════════════════════

  static TextStyle get headingSmall => titleLarge;
  static TextStyle get headingMedium => headlineMedium;
  static TextStyle get headingLarge => headlineLarge;
  static TextStyle get moneyLarge => currencyLarge;
  static TextStyle get moneyMedium => currencyMedium;
  static TextStyle get label => labelMedium;

  // ═══════════════════════════════════════════════════════════
  // HELPERS - Modificadores de estilo
  // ═══════════════════════════════════════════════════════════

  /// Adiciona peso bold a qualquer estilo
  static TextStyle bold(TextStyle style) => style.copyWith(
        fontWeight: FontWeight.w700,
      );

  /// Adiciona peso semibold a qualquer estilo
  static TextStyle semibold(TextStyle style) => style.copyWith(
        fontWeight: FontWeight.w600,
      );

  /// Adiciona peso medium a qualquer estilo
  static TextStyle medium(TextStyle style) => style.copyWith(
        fontWeight: FontWeight.w500,
      );

  /// Adiciona itálico a qualquer estilo
  static TextStyle italic(TextStyle style) => style.copyWith(
        fontStyle: FontStyle.italic,
      );

  /// Muda a cor de qualquer estilo
  static TextStyle withColor(TextStyle style, Color color) => style.copyWith(
        color: color,
      );

  /// Adiciona opacidade a qualquer estilo
  static TextStyle withOpacity(TextStyle style, double opacity) =>
      style.copyWith(
        color: style.color?.withValues(alpha: opacity),
      );

  /// Adiciona sublinhado a qualquer estilo
  static TextStyle underline(TextStyle style) => style.copyWith(
        decoration: TextDecoration.underline,
        decorationColor: style.color,
      );

  /// Remove decoração de qualquer estilo
  static TextStyle noDecoration(TextStyle style) => style.copyWith(
        decoration: TextDecoration.none,
      );
}

// Made with ❤️ by Bob - Redesign Profissional 2026

// Made with Bob
