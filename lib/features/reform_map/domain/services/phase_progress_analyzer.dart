import 'package:injectable/injectable.dart';
import '../../../shopping/domain/repositories/shopping_repository.dart';
import '../../../suppliers/domain/repositories/supplier_repository.dart';
import '../../../installments/domain/repositories/installment_repository.dart';
import '../../../projects/domain/entities/phase_entity.dart';
import '../entities/phase_analysis_entity.dart';

/// Serviço que analisa o progresso de cada fase
///
/// Compara o que foi esperado (definido na fase) com o que foi realizado:
/// - Fornecedores: esperados vs contratados
/// - Compras: categorias esperadas vs itens comprados
/// - Documentos: tipos esperados vs salvos
/// - Pagamentos: parcelas pagas vs pendentes
@injectable
class PhaseProgressAnalyzer {
  final ShoppingRepository _shoppingRepository;
  final SupplierRepository _supplierRepository;
  final InstallmentRepository _installmentRepository;

  PhaseProgressAnalyzer(
    this._shoppingRepository,
    this._supplierRepository,
    this._installmentRepository,
  );

  /// Analisa uma fase específica
  Future<PhaseAnalysisEntity> analyze(
    PhaseEntity phase,
    String projectId,
  ) async {
    // 1. Analisar fornecedores
    final suppliersAnalysis = await _analyzeSuppliers(phase, projectId);

    // 2. Analisar compras
    final purchasesAnalysis = await _analyzePurchases(phase, projectId);

    // 3. Analisar documentos (TODO: quando módulo de documentos estiver pronto)
    final documentsAnalysis = _analyzeDocuments(phase);

    // 4. Analisar pagamentos
    final paymentsAnalysis = await _analyzePayments(phase, projectId);

    // 5. Calcular progresso geral
    final completionPercentage = _calculateCompletionPercentage(
      suppliersAnalysis: suppliersAnalysis,
      purchasesAnalysis: purchasesAnalysis,
      documentsAnalysis: documentsAnalysis,
      paymentsAnalysis: paymentsAnalysis,
    );

    // 6. Determinar status de saúde
    final healthStatus = _determineHealthStatus(
      completionPercentage: completionPercentage,
      hasOverduePayments: paymentsAnalysis['hasOverdue'] as bool,
      hasCriticalGaps: suppliersAnalysis['hasCriticalGap'] as bool ||
          purchasesAnalysis['hasCriticalGap'] as bool,
    );

    // 7. Gerar lista de itens faltantes
    final missingItems = _generateMissingItems(
      suppliersAnalysis: suppliersAnalysis,
      purchasesAnalysis: purchasesAnalysis,
      documentsAnalysis: documentsAnalysis,
      paymentsAnalysis: paymentsAnalysis,
    );

    // 8. Gerar recomendações
    final recommendations = _generateRecommendations(
      phase: phase,
      suppliersAnalysis: suppliersAnalysis,
      purchasesAnalysis: purchasesAnalysis,
      paymentsAnalysis: paymentsAnalysis,
      healthStatus: healthStatus,
    );

    return PhaseAnalysisEntity(
      phaseId: phase.id,
      phaseName: phase.name,
      // Fornecedores
      expectedSupplierTypes: phase.expectedSupplierTypes,
      actualSuppliersCount: suppliersAnalysis['count'] as int,
      hiredSupplierNames: suppliersAnalysis['names'] as List<String>,
      hasSuppliersGap: suppliersAnalysis['hasGap'] as bool,
      // Compras
      expectedPurchaseCategories: phase.expectedPurchaseCategories,
      actualPurchasesCount: purchasesAnalysis['totalCount'] as int,
      purchasedItemsCount: purchasesAnalysis['purchasedCount'] as int,
      pendingItemsCount: purchasesAnalysis['pendingCount'] as int,
      totalPurchasesValue: purchasesAnalysis['totalValue'] as double,
      hasPurchasesGap: purchasesAnalysis['hasGap'] as bool,
      // Documentos
      expectedDocumentTypes: phase.expectedDocumentTypes,
      actualDocumentsCount: documentsAnalysis['count'] as int,
      savedDocumentNames: documentsAnalysis['names'] as List<String>,
      hasDocumentsGap: documentsAnalysis['hasGap'] as bool,
      // Pagamentos
      totalPaymentsCount: paymentsAnalysis['totalCount'] as int,
      paidPaymentsCount: paymentsAnalysis['paidCount'] as int,
      pendingPaymentsCount: paymentsAnalysis['pendingCount'] as int,
      totalPaidAmount: paymentsAnalysis['paidAmount'] as double,
      totalPendingAmount: paymentsAnalysis['pendingAmount'] as double,
      hasOverduePayments: paymentsAnalysis['hasOverdue'] as bool,
      // Progresso
      completionPercentage: completionPercentage,
      healthStatus: healthStatus,
      missingItems: missingItems,
      recommendations: recommendations,
    );
  }

  /// Analisa fornecedores da fase
  Future<Map<String, dynamic>> _analyzeSuppliers(
    PhaseEntity phase,
    String projectId,
  ) async {
    final suppliersResult = await _supplierRepository.getSuppliers(projectId);

    int count = 0;
    List<String> names = [];
    bool hasCriticalGap = false;

    await suppliersResult.fold(
      (failure) async => null,
      (suppliers) async {
        // Filtrar fornecedores desta fase
        final phaseSuppliers =
            suppliers.where((s) => s.phaseId == phase.id).toList();
        count = phaseSuppliers.length;
        names = phaseSuppliers.map((s) => s.name).toList();

        // Verificar se faltam fornecedores críticos
        if (phase.expectedSupplierTypes.isNotEmpty && count == 0) {
          hasCriticalGap = true;
        }
      },
    );

    return {
      'count': count,
      'names': names,
      'hasGap': phase.expectedSupplierTypes.isNotEmpty &&
          count < phase.expectedSupplierTypes.length,
      'hasCriticalGap': hasCriticalGap,
    };
  }

  /// Analisa compras da fase
  Future<Map<String, dynamic>> _analyzePurchases(
    PhaseEntity phase,
    String projectId,
  ) async {
    final shoppingResult =
        await _shoppingRepository.getShoppingItems(projectId);

    int totalCount = 0;
    int purchasedCount = 0;
    int pendingCount = 0;
    double totalValue = 0.0;
    bool hasCriticalGap = false;

    await shoppingResult.fold(
      (failure) async => null,
      (items) async {
        // Filtrar itens desta fase
        final phaseItems = items.where((i) => i.phaseId == phase.id).toList();
        totalCount = phaseItems.length;
        purchasedCount = phaseItems.where((i) => i.isPurchased).length;
        pendingCount = phaseItems.where((i) => !i.isPurchased).length;

        // Calcular valor total das compras
        for (final item in phaseItems) {
          if (item.isPurchased && item.actualPrice != null) {
            totalValue += item.actualPrice! * item.quantity;
          } else if (item.estimatedPrice != null) {
            totalValue += item.estimatedPrice! * item.quantity;
          }
        }

        // Verificar se faltam compras críticas
        if (phase.expectedPurchaseCategories.isNotEmpty &&
            purchasedCount == 0) {
          hasCriticalGap = true;
        }
      },
    );

    return {
      'totalCount': totalCount,
      'purchasedCount': purchasedCount,
      'pendingCount': pendingCount,
      'totalValue': totalValue,
      'hasGap': phase.expectedPurchaseCategories.isNotEmpty &&
          totalCount < phase.expectedPurchaseCategories.length,
      'hasCriticalGap': hasCriticalGap,
    };
  }

  /// Analisa documentos da fase (placeholder - módulo ainda não existe)
  Map<String, dynamic> _analyzeDocuments(PhaseEntity phase) {
    // TODO: Implementar quando módulo de documentos estiver pronto
    return {
      'count': 0,
      'names': <String>[],
      'hasGap': phase.expectedDocumentTypes.isNotEmpty,
    };
  }

  /// Analisa pagamentos da fase
  Future<Map<String, dynamic>> _analyzePayments(
    PhaseEntity phase,
    String projectId,
  ) async {
    final installmentsResult =
        await _installmentRepository.getInstallments(projectId);

    int totalCount = 0;
    int paidCount = 0;
    int pendingCount = 0;
    double paidAmount = 0.0;
    double pendingAmount = 0.0;
    bool hasOverdue = false;

    await installmentsResult.fold(
      (failure) async => null,
      (installments) async {
        final now = DateTime.now();

        // Filtrar parcelas desta fase
        for (final installment in installments) {
          if (installment.phaseId == phase.id) {
            for (final payment in installment.payments) {
              totalCount++;

              if (payment.isPaid) {
                paidCount++;
                paidAmount += payment.paidAmount ?? payment.amount;
              } else {
                pendingCount++;
                pendingAmount += payment.amount;

                // Verificar se está vencida
                if (payment.dueDate.isBefore(now)) {
                  hasOverdue = true;
                }
              }
            }
          }
        }
      },
    );

    return {
      'totalCount': totalCount,
      'paidCount': paidCount,
      'pendingCount': pendingCount,
      'paidAmount': paidAmount,
      'pendingAmount': pendingAmount,
      'hasOverdue': hasOverdue,
    };
  }

  /// Calcula percentual de conclusão da fase
  double _calculateCompletionPercentage({
    required Map<String, dynamic> suppliersAnalysis,
    required Map<String, dynamic> purchasesAnalysis,
    required Map<String, dynamic> documentsAnalysis,
    required Map<String, dynamic> paymentsAnalysis,
  }) {
    double score = 0.0;
    int totalWeight = 0;

    // Peso 30%: Fornecedores
    if ((suppliersAnalysis['count'] as int) > 0) {
      score += 30.0;
    }
    totalWeight += 30;

    // Peso 40%: Compras
    final purchasedCount = purchasesAnalysis['purchasedCount'] as int;
    final totalCount = purchasesAnalysis['totalCount'] as int;
    if (totalCount > 0) {
      score += (purchasedCount / totalCount) * 40.0;
    }
    totalWeight += 40;

    // Peso 10%: Documentos (quando implementado)
    // Por enquanto, não conta

    // Peso 20%: Pagamentos
    final paidCount = paymentsAnalysis['paidCount'] as int;
    final totalPayments = paymentsAnalysis['totalCount'] as int;
    if (totalPayments > 0) {
      score += (paidCount / totalPayments) * 20.0;
    }
    totalWeight += 20;

    return score.clamp(0.0, 100.0);
  }

  /// Determina status de saúde da fase
  PhaseHealthStatus _determineHealthStatus({
    required double completionPercentage,
    required bool hasOverduePayments,
    required bool hasCriticalGaps,
  }) {
    // Crítico: pagamentos vencidos ou gaps críticos
    if (hasOverduePayments || hasCriticalGaps) {
      return PhaseHealthStatus.critical;
    }

    // Baseado no percentual de conclusão
    if (completionPercentage >= 90) {
      return PhaseHealthStatus.excellent;
    } else if (completionPercentage >= 70) {
      return PhaseHealthStatus.good;
    } else if (completionPercentage >= 50) {
      return PhaseHealthStatus.warning;
    } else {
      return PhaseHealthStatus.critical;
    }
  }

  /// Gera lista de itens faltantes
  List<String> _generateMissingItems({
    required Map<String, dynamic> suppliersAnalysis,
    required Map<String, dynamic> purchasesAnalysis,
    required Map<String, dynamic> documentsAnalysis,
    required Map<String, dynamic> paymentsAnalysis,
  }) {
    final missing = <String>[];

    // Fornecedores faltantes
    if (suppliersAnalysis['hasGap'] as bool) {
      final count = suppliersAnalysis['count'] as int;
      if (count == 0) {
        missing.add('Nenhum fornecedor contratado');
      } else {
        missing.add('Faltam fornecedores');
      }
    }

    // Compras pendentes
    final pendingCount = purchasesAnalysis['pendingCount'] as int;
    if (pendingCount > 0) {
      missing.add(
          '$pendingCount ${pendingCount == 1 ? 'compra pendente' : 'compras pendentes'}');
    }

    // Documentos faltantes
    if (documentsAnalysis['hasGap'] as bool) {
      missing.add('Documentos pendentes');
    }

    // Pagamentos pendentes
    final pendingPayments = paymentsAnalysis['pendingCount'] as int;
    if (pendingPayments > 0) {
      missing.add(
          '$pendingPayments ${pendingPayments == 1 ? 'pagamento pendente' : 'pagamentos pendentes'}');
    }

    // Pagamentos vencidos
    if (paymentsAnalysis['hasOverdue'] as bool) {
      missing.add('⚠️ Pagamentos vencidos');
    }

    return missing;
  }

  /// Gera recomendações personalizadas
  List<String> _generateRecommendations({
    required PhaseEntity phase,
    required Map<String, dynamic> suppliersAnalysis,
    required Map<String, dynamic> purchasesAnalysis,
    required Map<String, dynamic> paymentsAnalysis,
    required PhaseHealthStatus healthStatus,
  }) {
    final recommendations = <String>[];

    // Recomendações baseadas em pagamentos vencidos
    if (paymentsAnalysis['hasOverdue'] as bool) {
      recommendations.add('🚨 Regularize os pagamentos vencidos imediatamente');
    }

    // Recomendações baseadas em fornecedores
    if (suppliersAnalysis['count'] as int == 0 &&
        phase.expectedSupplierTypes.isNotEmpty) {
      recommendations.add(
          'Contrate os fornecedores necessários: ${phase.expectedSupplierTypes.join(', ')}');
    }

    // Recomendações baseadas em compras
    final pendingCount = purchasesAnalysis['pendingCount'] as int;
    if (pendingCount > 0) {
      if (pendingCount <= 3) {
        recommendations.add('Complete as $pendingCount compras pendentes');
      } else {
        recommendations
            .add('Priorize as compras mais urgentes ($pendingCount pendentes)');
      }
    }

    // Recomendações baseadas em saúde
    switch (healthStatus) {
      case PhaseHealthStatus.critical:
        if (recommendations.isEmpty) {
          recommendations.add('Esta fase precisa de atenção urgente');
        }
        break;
      case PhaseHealthStatus.warning:
        recommendations.add('Acelere o progresso desta fase');
        break;
      case PhaseHealthStatus.good:
        recommendations.add('Continue o bom trabalho!');
        break;
      case PhaseHealthStatus.excellent:
        recommendations
            .add('🎉 Fase quase concluída! Prepare-se para a próxima');
        break;
    }

    // Recomendações específicas por fase
    _addPhaseSpecificRecommendations(phase, recommendations);

    return recommendations;
  }

  /// Adiciona recomendações específicas por tipo de fase
  void _addPhaseSpecificRecommendations(
    PhaseEntity phase,
    List<String> recommendations,
  ) {
    final phaseName = phase.name.toLowerCase();

    if (phaseName.contains('infraestrutura') ||
        phaseName.contains('elétrica')) {
      recommendations.add(
          '💡 Dica: Planeje bem os pontos de tomada antes de fechar as paredes');
    } else if (phaseName.contains('revestimento') ||
        phaseName.contains('piso')) {
      recommendations.add(
          '📏 Dica: Compre 10% a mais de material para quebras e recortes');
    } else if (phaseName.contains('pintura')) {
      recommendations.add(
          '🎨 Dica: Teste as cores em pequenas áreas antes de pintar tudo');
    } else if (phaseName.contains('acabamento')) {
      recommendations
          .add('✨ Dica: Deixe as louças e metais por último para evitar danos');
    }
  }
}

// Made with Bob
