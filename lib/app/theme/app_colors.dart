import 'package:flutter/material.dart';

/// Paleta de cores do Costruttore - Design System Profissional
/// Inspirado em materiais naturais e arquitetura moderna
/// Foco em clareza, calma e organização
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════
  // CORES PRIMÁRIAS - Tons Naturais e Sofisticados
  // ═══════════════════════════════════════════════════════════

  /// Cor principal - Cinza Ardósia (Slate)
  /// Transmite profissionalismo, solidez e modernidade
  static const Color primary = Color(0xFF475569); // Slate 600
  static const Color primaryLight = Color(0xFF64748B); // Slate 500
  static const Color primaryDark = Color(0xFF334155); // Slate 700
  static const Color primarySubtle = Color(0xFFF1F5F9); // Slate 100

  /// Cor de destaque - Âmbar Suave
  /// Para CTAs e elementos importantes sem agressividade
  static const Color accent = Color(0xFFF59E0B); // Amber 500
  static const Color accentLight = Color(0xFFFBBF24); // Amber 400
  static const Color accentDark = Color(0xFFD97706); // Amber 600
  static const Color accentSubtle = Color(0xFFFEF3C7); // Amber 100

  // ═══════════════════════════════════════════════════════════
  // CORES SECUNDÁRIAS - Paleta Expandida
  // ═══════════════════════════════════════════════════════════

  /// Azul Céu - Para informações e navegação
  static const Color blue = Color(0xFF3B82F6); // Blue 500
  static const Color blueLight = Color(0xFF60A5FA); // Blue 400
  static const Color blueDark = Color(0xFF2563EB); // Blue 600
  static const Color blueSubtle = Color(0xFFDCEEFE); // Blue 100

  /// Verde Esmeralda - Para sucesso e confirmações
  static const Color green = Color(0xFF10B981); // Emerald 500
  static const Color greenLight = Color(0xFF34D399); // Emerald 400
  static const Color greenDark = Color(0xFF059669); // Emerald 600
  static const Color greenSubtle = Color(0xFFD1FAE5); // Emerald 100

  /// Roxo Lavanda - Para features premium
  static const Color purple = Color(0xFF8B5CF6); // Violet 500
  static const Color purpleLight = Color(0xFFA78BFA); // Violet 400
  static const Color purpleDark = Color(0xFF7C3AED); // Violet 600
  static const Color purpleSubtle = Color(0xFFEDE9FE); // Violet 100

  /// Rosa Coral - Para alertas suaves
  static const Color rose = Color(0xFFF43F5E); // Rose 500
  static const Color roseLight = Color(0xFFFB7185); // Rose 400
  static const Color roseDark = Color(0xFFE11D48); // Rose 600
  static const Color roseSubtle = Color(0xFFFFE4E6); // Rose 100

  // ═══════════════════════════════════════════════════════════
  // CORES DE FUNDO - Sistema de Camadas
  // ═══════════════════════════════════════════════════════════

  /// Fundo principal - Branco puro para clareza
  static const Color background = Color(0xFFFFFFFF);

  /// Superfície elevada - Cinza muito claro
  static const Color surface = Color(0xFFFAFAFA);

  /// Superfície com destaque - Cinza suave
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  /// Superfície com elevação - Para cards importantes
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════
  // CORES DE TEXTO - Hierarquia Clara
  // ═══════════════════════════════════════════════════════════

  /// Texto principal - Preto suave (não puro)
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900

  /// Texto secundário - Cinza médio
  static const Color textSecondary = Color(0xFF64748B); // Slate 500

  /// Texto terciário - Cinza claro
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400

  /// Texto desabilitado
  static const Color textDisabled = Color(0xFFCBD5E1); // Slate 300

  /// Texto sobre cores escuras
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Texto sobre cores claras
  static const Color textOnLight = Color(0xFF0F172A);

  /// Texto inverso
  static const Color textInverse = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════
  // CORES DE STATUS - Semântica Clara
  // ═══════════════════════════════════════════════════════════

  /// Sucesso - Verde natural
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successLight = Color(0xFF6EE7B7); // Emerald 300
  static const Color successDark = Color(0xFF047857); // Emerald 700
  static const Color successSubtle = Color(0xFFD1FAE5); // Emerald 100

  /// Aviso - Âmbar quente
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningLight = Color(0xFFFCD34D); // Amber 300
  static const Color warningDark = Color(0xFFB45309); // Amber 700
  static const Color warningSubtle = Color(0xFFFEF3C7); // Amber 100

  /// Erro - Vermelho suave
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorLight = Color(0xFFFCA5A5); // Red 300
  static const Color errorDark = Color(0xFFB91C1C); // Red 700
  static const Color errorSubtle = Color(0xFFFEE2E2); // Red 100

  /// Informação - Azul céu
  static const Color info = Color(0xFF3B82F6); // Blue 500
  static const Color infoLight = Color(0xFF93C5FD); // Blue 300
  static const Color infoDark = Color(0xFF1D4ED8); // Blue 700
  static const Color infoSubtle = Color(0xFFDCEEFE); // Blue 100

  // ═══════════════════════════════════════════════════════════
  // CORES DE BORDA E DIVISORES - Sutileza
  // ═══════════════════════════════════════════════════════════

  /// Borda padrão - Cinza muito claro
  static const Color border = Color(0xFFE2E8F0); // Slate 200

  /// Borda com foco
  static const Color borderFocus = Color(0xFF94A3B8); // Slate 400

  /// Divisor - Ainda mais sutil
  static const Color divider = Color(0xFFF1F5F9); // Slate 100

  // ═══════════════════════════════════════════════════════════
  // CORES DE SOMBRA - Profundidade Sutil
  // ═══════════════════════════════════════════════════════════

  /// Sombra padrão - Muito sutil
  static const Color shadow = Color(0x0A000000); // 4% opacity

  /// Sombra leve
  static const Color shadowLight = Color(0x05000000); // 2% opacity

  /// Sombra média
  static const Color shadowMedium = Color(0x0F000000); // 6% opacity

  /// Sombra forte
  static const Color shadowDark = Color(0x1A000000); // 10% opacity

  // ═══════════════════════════════════════════════════════════
  // CORES DE OVERLAY - Modais e Diálogos
  // ═══════════════════════════════════════════════════════════

  /// Overlay escuro
  static const Color overlay = Color(0x80000000); // 50% opacity

  /// Overlay leve
  static const Color overlayLight = Color(0x40000000); // 25% opacity

  /// Overlay muito leve
  static const Color overlaySubtle = Color(0x1A000000); // 10% opacity

  // ═══════════════════════════════════════════════════════════
  // CORES DE FASE - Sistema de Progresso
  // ═══════════════════════════════════════════════════════════

  /// Fase não iniciada
  static const Color phaseNotStarted = Color(0xFFE2E8F0); // Slate 200

  /// Fase em progresso
  static const Color phaseInProgress = Color(0xFF3B82F6); // Blue 500

  /// Fase concluída
  static const Color phaseCompleted = Color(0xFF10B981); // Emerald 500

  /// Fase atrasada
  static const Color phaseDelayed = Color(0xFFF59E0B); // Amber 500

  /// Fase bloqueada
  static const Color phaseLocked = Color(0xFF94A3B8); // Slate 400

  // ═══════════════════════════════════════════════════════════
  // CORES CATEGORIAS - Identificação Visual
  // ═══════════════════════════════════════════════════════════

  /// Categoria Azul - Documentação e planejamento
  static const Color categoryBlue = Color(0xFF3B82F6);

  /// Categoria Verde - Execução e obra
  static const Color categoryGreen = Color(0xFF10B981);

  /// Categoria Laranja - Compras e fornecedores
  static const Color categoryOrange = Color(0xFFF59E0B);

  /// Categoria Roxo - Acabamentos e design
  static const Color categoryPurple = Color(0xFF8B5CF6);

  /// Categoria Rosa - Problemas e alertas
  static const Color categoryRose = Color(0xFFF43F5E);

  /// Categoria Cinza - Administrativo
  static const Color categoryGray = Color(0xFF64748B);

  // ═══════════════════════════════════════════════════════════
  // GRADIENTES - Para Cards Especiais
  // ═══════════════════════════════════════════════════════════

  /// Gradiente principal
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF475569), Color(0xFF334155)],
  );

  /// Gradiente de destaque
  static const LinearGradient gradientAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  /// Gradiente sucesso
  static const LinearGradient gradientSuccess = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  /// Gradiente sutil
  static const LinearGradient gradientSubtle = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA)],
  );

  // ═══════════════════════════════════════════════════════════
  // COMPATIBILIDADE - Aliases para código existente
  // ═══════════════════════════════════════════════════════════

  /// Cor secundária (mantida para compatibilidade)
  static const Color secondary = surfaceVariant;
  static const Color secondaryLight = surface;
  static const Color secondaryDark = border;

  /// Cores de fase antigas (aliases)
  static const Color phaseBlue = categoryBlue;
  static const Color phaseGreen = categoryGreen;
  static const Color phaseOrange = categoryOrange;
  static const Color phasePurple = categoryPurple;
}

/// Classe auxiliar para border radius - Sistema consistente
class AppRadius {
  AppRadius._();

  /// Extra pequeno - 4px
  static const double xs = 4.0;

  /// Pequeno - 8px
  static const double s = 8.0;

  /// Médio - 12px
  static const double m = 12.0;

  /// Grande - 16px
  static const double l = 16.0;

  /// Extra grande - 24px
  static const double xl = 24.0;

  /// Circular completo
  static const double full = 999.0;
}

// Made with ❤️ by Bob - Redesign Profissional 2026

// Made with Bob
