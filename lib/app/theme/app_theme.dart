import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';

/// Tema principal do aplicativo Costruttore - Design System Profissional
/// Inspirado em apps modernos: Notion, Linear, Arc
/// Foco em clareza, respiro visual e hierarquia
class AppTheme {
  AppTheme._();

  /// Tema claro (principal) - Redesign 2026
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // ═══════════════════════════════════════════════════════════
      // COLOR SCHEME - Paleta profissional
      // ═══════════════════════════════════════════════════════════
      colorScheme: ColorScheme.light(
        // Primárias
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        primaryContainer: AppColors.primarySubtle,
        onPrimaryContainer: AppColors.primaryDark,

        // Secundárias
        secondary: AppColors.accent,
        onSecondary: AppColors.textOnPrimary,
        secondaryContainer: AppColors.accentSubtle,
        onSecondaryContainer: AppColors.accentDark,

        // Terciárias
        tertiary: AppColors.blue,
        onTertiary: AppColors.textOnPrimary,
        tertiaryContainer: AppColors.blueSubtle,
        onTertiaryContainer: AppColors.blueDark,

        // Superfícies
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariant,
        surfaceContainerHigh: AppColors.surfaceElevated,

        // Status
        error: AppColors.error,
        onError: AppColors.textOnPrimary,
        errorContainer: AppColors.errorSubtle,
        onErrorContainer: AppColors.errorDark,

        // Bordas e divisores
        outline: AppColors.border,
        outlineVariant: AppColors.divider,

        // Sombras e overlays
        shadow: AppColors.shadow,
        scrim: AppColors.overlay,
      ),

      // ═══════════════════════════════════════════════════════════
      // SCAFFOLD - Fundo limpo
      // ═══════════════════════════════════════════════════════════
      scaffoldBackgroundColor: AppColors.background,

      // ═══════════════════════════════════════════════════════════
      // APP BAR - Minimalista e clean
      // ═══════════════════════════════════════════════════════════
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0, // Sem elevação ao rolar
        centerTitle: false, // Alinhado à esquerda (mais moderno)
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: AppSpacing.iconMd,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.textSecondary,
          size: AppSpacing.iconMd,
        ),
      ),

      // ═══════════════════════════════════════════════════════════
      // CARD - Design moderno com sombra sutil
      // ═══════════════════════════════════════════════════════════
      cardTheme: CardThemeData(
        elevation: 0, // Sem elevação padrão
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero, // Controle manual de margens
        clipBehavior: Clip.antiAlias,
      ),

      // ═══════════════════════════════════════════════════════════
      // BOTÕES - Sistema consistente e acessível
      // ═══════════════════════════════════════════════════════════

      // Botão primário (filled)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0, // Flat design
          shadowColor: Colors.transparent,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textDisabled,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTextStyles.labelLarge,
        ).copyWith(
          // Hover e pressed states
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.textOnPrimary.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.hovered)) {
              return AppColors.textOnPrimary.withValues(alpha: 0.05);
            }
            return null;
          }),
        ),
      ),

      // Botão secundário (outlined)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textDisabled,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          side: const BorderSide(
            color: AppColors.border,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTextStyles.labelLarge,
        ).copyWith(
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(color: AppColors.border, width: 1.5);
            }
            if (states.contains(WidgetState.pressed)) {
              return BorderSide(color: AppColors.primaryDark, width: 1.5);
            }
            if (states.contains(WidgetState.hovered)) {
              return BorderSide(color: AppColors.primary, width: 1.5);
            }
            return BorderSide(color: AppColors.border, width: 1.5);
          }),
        ),
      ),

      // Botão terciário (text)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textDisabled,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textStyle: AppTextStyles.labelLarge,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primary.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.hovered)) {
              return AppColors.primary.withValues(alpha: 0.05);
            }
            return null;
          }),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: AppSpacing.elevationMd,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),

      // ═══════════════════════════════════════════════════════════
      // INPUT FIELDS - Limpo e acessível
      // ═══════════════════════════════════════════════════════════
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        // Borda padrão
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: 1.5,
          ),
        ),
        // Borda habilitada
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: 1.5,
          ),
        ),
        // Borda com foco
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        // Borda de erro
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        // Borda de erro com foco
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        // Estilos de texto
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        helperStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.error,
        ),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),

      // ═══════════════════════════════════════════════════════════
      // DIVIDER - Sutil e discreto
      // ═══════════════════════════════════════════════════════════
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: AppSpacing.lg,
      ),

      // ═══════════════════════════════════════════════════════════
      // CHIP - Moderno e clean
      // ═══════════════════════════════════════════════════════════
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primarySubtle,
        disabledColor: AppColors.border,
        labelStyle: AppTextStyles.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        side: BorderSide.none,
      ),

      // ═══════════════════════════════════════════════════════════
      // DIALOG - Elevado e focado
      // ═══════════════════════════════════════════════════════════
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: AppSpacing.elevationXl,
        shadowColor: AppColors.shadowDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        titleTextStyle: AppTextStyles.headlineSmall,
        contentTextStyle: AppTextStyles.bodyMedium,
        actionsPadding: const EdgeInsets.all(AppSpacing.lg),
      ),

      // ═══════════════════════════════════════════════════════════
      // BOTTOM SHEET - Suave e arredondado
      // ═══════════════════════════════════════════════════════════
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: AppSpacing.elevationXl,
        shadowColor: AppColors.shadowDark,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ═══════════════════════════════════════════════════════════
      // SNACKBAR - Feedback claro
      // ═══════════════════════════════════════════════════════════
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textOnPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        elevation: AppSpacing.elevationMd,
      ),

      // ═══════════════════════════════════════════════════════════
      // PROGRESS INDICATOR - Consistente com cores
      // ═══════════════════════════════════════════════════════════
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceVariant,
        circularTrackColor: AppColors.surfaceVariant,
      ),

      // ═══════════════════════════════════════════════════════════
      // SWITCH - Toggle moderno
      // ═══════════════════════════════════════════════════════════
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.textOnPrimary;
          }
          return AppColors.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.border;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ═══════════════════════════════════════════════════════════
      // CHECKBOX - Limpo e acessível
      // ═══════════════════════════════════════════════════════════
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.textOnPrimary),
        side: BorderSide(color: AppColors.border, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        ),
      ),

      // ═══════════════════════════════════════════════════════════
      // RADIO - Consistente com checkbox
      // ═══════════════════════════════════════════════════════════
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.border;
        }),
      ),

      // ═══════════════════════════════════════════════════════════
      // TIPOGRAFIA - Hierarquia clara
      // ═══════════════════════════════════════════════════════════
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // ═══════════════════════════════════════════════════════════
      // ICON - Tamanhos consistentes
      // ═══════════════════════════════════════════════════════════
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: AppSpacing.iconMd,
      ),

      primaryIconTheme: const IconThemeData(
        color: AppColors.primary,
        size: AppSpacing.iconMd,
      ),

      // ═══════════════════════════════════════════════════════════
      // LIST TILE - Espaçamento generoso
      // ═══════════════════════════════════════════════════════════
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        minLeadingWidth: 40,
        titleTextStyle: AppTextStyles.titleMedium,
        subtitleTextStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
        leadingAndTrailingTextStyle: AppTextStyles.labelMedium,
        iconColor: AppColors.textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),

      // ═══════════════════════════════════════════════════════════
      // NAVIGATION BAR - Bottom navigation moderna
      // ═══════════════════════════════════════════════════════════
      navigationBarTheme: NavigationBarThemeData(
        height: AppSpacing.bottomNavHeight,
        backgroundColor: AppColors.surface,
        elevation: 0,
        indicatorColor: AppColors.primarySubtle,
        labelTextStyle: WidgetStateProperty.all(
          AppTextStyles.labelSmall,
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.primary,
              size: AppSpacing.iconMd,
            );
          }
          return const IconThemeData(
            color: AppColors.textSecondary,
            size: AppSpacing.iconMd,
          );
        }),
      ),

      // ═══════════════════════════════════════════════════════════
      // TAB BAR - Tabs limpas
      // ═══════════════════════════════════════════════════════════
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelLarge,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),

      // ═══════════════════════════════════════════════════════════
      // TOOLTIP - Informações contextuais
      // ═══════════════════════════════════════════════════════════
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        textStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textOnPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),

      // ═══════════════════════════════════════════════════════════
      // BANNER - Mensagens de sistema
      // ═══════════════════════════════════════════════════════════
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: AppColors.surfaceVariant,
        contentTextStyle: AppTextStyles.bodyMedium,
        padding: const EdgeInsets.all(AppSpacing.md),
      ),

      // ═══════════════════════════════════════════════════════════
      // EXPANSÃO - Painéis expansíveis
      // ═══════════════════════════════════════════════════════════
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: AppColors.surface,
        collapsedBackgroundColor: AppColors.surface,
        textColor: AppColors.textPrimary,
        iconColor: AppColors.textSecondary,
        collapsedTextColor: AppColors.textPrimary,
        collapsedIconColor: AppColors.textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),

      // ═══════════════════════════════════════════════════════════
      // VISUAL DENSITY - Confortável
      // ═══════════════════════════════════════════════════════════
      visualDensity: VisualDensity.comfortable,

      // ═══════════════════════════════════════════════════════════
      // SPLASH - Feedback tátil
      // ═══════════════════════════════════════════════════════════
      splashColor: AppColors.primary.withValues(alpha: 0.1),
      highlightColor: AppColors.primary.withValues(alpha: 0.05),
      hoverColor: AppColors.primary.withValues(alpha: 0.03),
    );
  }
}

// Made with ❤️ by Bob - Redesign Profissional 2026
