import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Sistema de tipografia do Costruttore
/// Baseado na fonte DM Sans com hierarquia clara
class AppTextStyles {
  AppTextStyles._();

  // Família de fonte base
  static TextStyle get _baseStyle => GoogleFonts.dmSans();

  // Display - Para títulos grandes e destaque
  static TextStyle get displayLarge => _baseStyle.copyWith(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
  );

  static TextStyle get displayMedium => _baseStyle.copyWith(
    fontSize: 45,
    fontWeight: FontWeight.w700,
    height: 1.16,
    color: AppColors.textPrimary,
  );

  static TextStyle get displaySmall => _baseStyle.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.22,
    color: AppColors.textPrimary,
  );

  // Headline - Para títulos de seções
  static TextStyle get headlineLarge => _baseStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineMedium => _baseStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.29,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineSmall => _baseStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    color: AppColors.textPrimary,
  );

  // Title - Para títulos de cards e componentes
  static TextStyle get titleLarge => _baseStyle.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleMedium => _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleSmall => _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  // Body - Para texto de conteúdo
  static TextStyle get bodyLarge => _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  // Label - Para labels de botões e campos
  static TextStyle get labelLarge => _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelMedium => _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelSmall => _baseStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.45,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  // Estilos específicos do app
  static TextStyle get buttonText =>
      labelLarge.copyWith(color: AppColors.textOnPrimary);

  static TextStyle get caption =>
      bodySmall.copyWith(color: AppColors.textTertiary);

  static TextStyle get overline => labelSmall.copyWith(
    textBaseline: TextBaseline.alphabetic,
    color: AppColors.textSecondary,
  );

  // Estilos para valores monetários
  static TextStyle get currencyLarge => displaySmall.copyWith(
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static TextStyle get currencyMedium => headlineSmall.copyWith(
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle get currencySmall => titleMedium.copyWith(
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  // Estilos para status
  static TextStyle get statusSuccess => labelMedium.copyWith(
    color: AppColors.success,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get statusWarning => labelMedium.copyWith(
    color: AppColors.warning,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get statusError =>
      labelMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.w600);

  static TextStyle get statusInfo =>
      labelMedium.copyWith(color: AppColors.info, fontWeight: FontWeight.w600);

  // Aliases para compatibilidade
  static TextStyle get headingSmall => titleLarge;
  static TextStyle get headingMedium => headlineMedium;
  static TextStyle get headingLarge => headlineLarge;
  static TextStyle get moneyLarge => currencyLarge;
  static TextStyle get moneyMedium => currencyMedium;
  static TextStyle get label => labelMedium;
}

// Made with Bob
