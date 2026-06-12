import 'package:equatable/equatable.dart';

/// Análise detalhada do progresso de uma fase
///
/// Compara o que foi esperado vs realizado em:
/// - Fornecedores contratados
/// - Compras realizadas
/// - Documentos salvos
/// - Pagamentos efetuados
class PhaseAnalysisEntity extends Equatable {
  final String phaseId;
  final String phaseName;

  // Análise de Fornecedores
  final List<String> expectedSupplierTypes;
  final int actualSuppliersCount;
  final List<String> hiredSupplierNames;
  final bool hasSuppliersGap; // Faltam fornecedores?

  // Análise de Compras
  final List<String> expectedPurchaseCategories;
  final int actualPurchasesCount;
  final int purchasedItemsCount;
  final int pendingItemsCount;
  final double totalPurchasesValue;
  final bool hasPurchasesGap; // Faltam compras?

  // Análise de Documentos
  final List<String> expectedDocumentTypes;
  final int actualDocumentsCount;
  final List<String> savedDocumentNames;
  final bool hasDocumentsGap; // Faltam documentos?

  // Análise Financeira
  final int totalPaymentsCount;
  final int paidPaymentsCount;
  final int pendingPaymentsCount;
  final double totalPaidAmount;
  final double totalPendingAmount;
  final bool hasOverduePayments;

  // Análise de Progresso
  final double completionPercentage; // 0-100
  final PhaseHealthStatus healthStatus;
  final List<String> missingItems; // Lista do que falta
  final List<String> recommendations; // Recomendações

  const PhaseAnalysisEntity({
    required this.phaseId,
    required this.phaseName,
    required this.expectedSupplierTypes,
    required this.actualSuppliersCount,
    required this.hiredSupplierNames,
    required this.hasSuppliersGap,
    required this.expectedPurchaseCategories,
    required this.actualPurchasesCount,
    required this.purchasedItemsCount,
    required this.pendingItemsCount,
    required this.totalPurchasesValue,
    required this.hasPurchasesGap,
    required this.expectedDocumentTypes,
    required this.actualDocumentsCount,
    required this.savedDocumentNames,
    required this.hasDocumentsGap,
    required this.totalPaymentsCount,
    required this.paidPaymentsCount,
    required this.pendingPaymentsCount,
    required this.totalPaidAmount,
    required this.totalPendingAmount,
    required this.hasOverduePayments,
    required this.completionPercentage,
    required this.healthStatus,
    required this.missingItems,
    required this.recommendations,
  });

  /// Verifica se a fase está completa (todos os itens esperados foram realizados)
  bool get isComplete {
    return !hasSuppliersGap &&
        !hasPurchasesGap &&
        !hasDocumentsGap &&
        pendingPaymentsCount == 0;
  }

  /// Verifica se há problemas críticos
  bool get hasCriticalIssues {
    return hasOverduePayments || healthStatus == PhaseHealthStatus.critical;
  }

  /// Verifica se está em bom estado
  bool get isHealthy {
    return healthStatus == PhaseHealthStatus.excellent ||
        healthStatus == PhaseHealthStatus.good;
  }

  @override
  List<Object?> get props => [
        phaseId,
        phaseName,
        expectedSupplierTypes,
        actualSuppliersCount,
        hiredSupplierNames,
        hasSuppliersGap,
        expectedPurchaseCategories,
        actualPurchasesCount,
        purchasedItemsCount,
        pendingItemsCount,
        totalPurchasesValue,
        hasPurchasesGap,
        expectedDocumentTypes,
        actualDocumentsCount,
        savedDocumentNames,
        hasDocumentsGap,
        totalPaymentsCount,
        paidPaymentsCount,
        pendingPaymentsCount,
        totalPaidAmount,
        totalPendingAmount,
        hasOverduePayments,
        completionPercentage,
        healthStatus,
        missingItems,
        recommendations,
      ];
}

/// Status de saúde da fase
enum PhaseHealthStatus {
  excellent, // 90-100% completo, sem problemas
  good, // 70-89% completo, poucos problemas
  warning, // 50-69% completo, alguns problemas
  critical, // <50% completo ou problemas graves
}

extension PhaseHealthStatusExtension on PhaseHealthStatus {
  String get displayName {
    switch (this) {
      case PhaseHealthStatus.excellent:
        return 'Excelente';
      case PhaseHealthStatus.good:
        return 'Bom';
      case PhaseHealthStatus.warning:
        return 'Atenção';
      case PhaseHealthStatus.critical:
        return 'Crítico';
    }
  }

  String get emoji {
    switch (this) {
      case PhaseHealthStatus.excellent:
        return '🎉';
      case PhaseHealthStatus.good:
        return '✅';
      case PhaseHealthStatus.warning:
        return '⚠️';
      case PhaseHealthStatus.critical:
        return '🚨';
    }
  }
}

// Made with Bob
