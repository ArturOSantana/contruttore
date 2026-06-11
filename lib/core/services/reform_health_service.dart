import 'package:injectable/injectable.dart';
import '../../features/projects/domain/entities/phase_entity.dart';
import '../../features/projects/domain/entities/project_entity.dart';

/// Serviço que calcula a "saúde" da reforma
///
/// Analisa múltiplos fatores para determinar se a reforma está saudável:
/// - Progresso das fases
/// - Orçamento vs gastos
/// - Prazos vs datas reais
/// - Pendências críticas
/// - Qualidade da execução
@lazySingleton
class ReformHealthService {
  /// Calcula a saúde geral da reforma (0-100)
  ///
  /// Retorna um score que representa o quão bem a reforma está indo
  ReformHealthScore calculateHealth({
    required ProjectEntity project,
    required List<PhaseEntity> phases,
    required double totalSpent,
    required double totalPending,
    required int criticalAlertsCount,
    required int delayedPhasesCount,
  }) {
    // 1. Score de Progresso (30 pontos)
    final progressScore = _calculateProgressScore(phases);

    // 2. Score Financeiro (25 pontos)
    final financialScore = _calculateFinancialScore(
      project: project,
      totalSpent: totalSpent,
      totalPending: totalPending,
    );

    // 3. Score de Prazo (25 pontos)
    final timelineScore = _calculateTimelineScore(
      project: project,
      phases: phases,
      delayedPhasesCount: delayedPhasesCount,
    );

    // 4. Score de Qualidade (20 pontos)
    final qualityScore = _calculateQualityScore(
      phases: phases,
      criticalAlertsCount: criticalAlertsCount,
    );

    // Calcula score total
    final totalScore =
        progressScore + financialScore + timelineScore + qualityScore;

    // Determina status
    final status = _determineHealthStatus(totalScore);

    // Gera recomendações
    final recommendations = _generateRecommendations(
      status: status,
      progressScore: progressScore,
      financialScore: financialScore,
      timelineScore: timelineScore,
      qualityScore: qualityScore,
      project: project,
      phases: phases,
    );

    return ReformHealthScore(
      totalScore: totalScore,
      status: status,
      progressScore: progressScore,
      financialScore: financialScore,
      timelineScore: timelineScore,
      qualityScore: qualityScore,
      recommendations: recommendations,
    );
  }

  /// Calcula o progresso real da obra (0-100)
  ///
  /// Usa pesos diferentes para cada fase baseado na complexidade
  double calculateOverallProgress(List<PhaseEntity> phases) {
    if (phases.isEmpty) return 0;

    // Pesos por fase (total = 100)
    final phaseWeights = _getPhaseWeights(phases.length);

    double weightedProgress = 0;
    for (int i = 0; i < phases.length; i++) {
      final phase = phases[i];
      final weight = phaseWeights[i];

      // Progresso da fase (0-100)
      double phaseProgress = 0;

      if (phase.status == PhaseStatus.done ||
          phase.status == PhaseStatus.doneNoRecord) {
        phaseProgress = 100;
      } else if (phase.status == PhaseStatus.active) {
        phaseProgress = phase.progressPercentage;
      }
      // locked = 0

      weightedProgress += (phaseProgress * weight) / 100;
    }

    return weightedProgress.clamp(0, 100);
  }

  /// Retorna os pesos de cada fase baseado no total de fases
  List<double> _getPhaseWeights(int totalPhases) {
    // Pesos padrão para 8 fases típicas de uma reforma
    if (totalPhases == 8) {
      return [
        5, // 1. Planejamento
        10, // 2. Demolição
        15, // 3. Infraestrutura (elétrica/hidráulica)
        15, // 4. Alvenaria
        20, // 5. Revestimentos
        15, // 6. Acabamentos
        10, // 7. Instalações finais
        10, // 8. Limpeza e entrega
      ];
    }

    // Se tiver número diferente, distribui uniformemente
    final weight = 100.0 / totalPhases;
    return List.filled(totalPhases, weight);
  }

  /// Calcula score de progresso (0-30)
  double _calculateProgressScore(List<PhaseEntity> phases) {
    if (phases.isEmpty) return 0;

    final overallProgress = calculateOverallProgress(phases);

    // Converte progresso 0-100 para score 0-30
    return (overallProgress * 30) / 100;
  }

  /// Calcula score financeiro (0-25)
  double _calculateFinancialScore({
    required ProjectEntity project,
    required double totalSpent,
    required double totalPending,
  }) {
    final budget = project.totalBudget ?? 0;
    if (budget == 0) return 25; // Se não tem orçamento, não penaliza

    final totalCommitted = totalSpent + totalPending;
    final usagePercentage = (totalCommitted / budget) * 100;

    // Score baseado no uso do orçamento
    if (usagePercentage <= 80) {
      return 25; // Excelente - dentro do orçamento
    } else if (usagePercentage <= 95) {
      return 20; // Bom - próximo do limite
    } else if (usagePercentage <= 105) {
      return 15; // Atenção - no limite
    } else if (usagePercentage <= 120) {
      return 10; // Ruim - estourou o orçamento
    } else {
      return 5; // Crítico - muito acima do orçamento
    }
  }

  /// Calcula score de prazo (0-25)
  double _calculateTimelineScore({
    required ProjectEntity project,
    required List<PhaseEntity> phases,
    required int delayedPhasesCount,
  }) {
    if (phases.isEmpty) return 25;

    // Penaliza por fases atrasadas
    final delayPenalty = delayedPhasesCount * 5.0;

    // Verifica se está próximo da data de mudança
    if (project.plannedMoveInDate != null) {
      final now = DateTime.now();
      final daysUntilMoveIn = project.plannedMoveInDate!.difference(now).inDays;
      final overallProgress = calculateOverallProgress(phases);

      // Se falta pouco tempo e o progresso está baixo, penaliza
      if (daysUntilMoveIn <= 30 && overallProgress < 80) {
        return (25 - delayPenalty - 10).clamp(0, 25);
      } else if (daysUntilMoveIn <= 60 && overallProgress < 60) {
        return (25 - delayPenalty - 5).clamp(0, 25);
      }
    }

    return (25 - delayPenalty).clamp(0, 25);
  }

  /// Calcula score de qualidade (0-20)
  double _calculateQualityScore({
    required List<PhaseEntity> phases,
    required int criticalAlertsCount,
  }) {
    // Penaliza por alertas críticos
    final alertPenalty = criticalAlertsCount * 3.0;

    // Penaliza por fases sem registro (doneNoRecord)
    final noRecordPhases =
        phases.where((p) => p.status == PhaseStatus.doneNoRecord).length;
    final noRecordPenalty = noRecordPhases * 2.0;

    return (20 - alertPenalty - noRecordPenalty).clamp(0, 20);
  }

  /// Determina o status de saúde baseado no score
  ReformHealthStatus _determineHealthStatus(double score) {
    if (score >= 85) {
      return ReformHealthStatus.excellent;
    } else if (score >= 70) {
      return ReformHealthStatus.good;
    } else if (score >= 50) {
      return ReformHealthStatus.attention;
    } else if (score >= 30) {
      return ReformHealthStatus.critical;
    } else {
      return ReformHealthStatus.emergency;
    }
  }

  /// Gera recomendações baseadas nos scores
  List<String> _generateRecommendations({
    required ReformHealthStatus status,
    required double progressScore,
    required double financialScore,
    required double timelineScore,
    required double qualityScore,
    required ProjectEntity project,
    required List<PhaseEntity> phases,
  }) {
    final recommendations = <String>[];

    // Recomendações de progresso
    if (progressScore < 15) {
      recommendations.add(
          'A obra está avançando devagar. Considere aumentar a equipe ou revisar o cronograma.');
    }

    // Recomendações financeiras
    if (financialScore < 15) {
      recommendations.add(
          'Orçamento crítico! Revise gastos e priorize apenas o essencial.');
    } else if (financialScore < 20) {
      recommendations
          .add('Atenção ao orçamento. Evite gastos extras e negocie preços.');
    }

    // Recomendações de prazo
    if (timelineScore < 15) {
      recommendations.add(
          'Cronograma atrasado. Foque em resolver pendências críticas primeiro.');
    } else if (timelineScore < 20) {
      recommendations
          .add('Algumas fases estão atrasadas. Monitore prazos de perto.');
    }

    // Recomendações de qualidade
    if (qualityScore < 12) {
      recommendations.add(
          'Muitos alertas críticos! Resolva problemas urgentes antes de continuar.');
    } else if (qualityScore < 16) {
      recommendations
          .add('Registre melhor o andamento da obra para ter mais controle.');
    }

    // Recomendações gerais por status
    switch (status) {
      case ReformHealthStatus.excellent:
        recommendations
            .add('Parabéns! A reforma está indo muito bem. Continue assim!');
        break;
      case ReformHealthStatus.good:
        recommendations
            .add('A reforma está no caminho certo. Mantenha o controle.');
        break;
      case ReformHealthStatus.attention:
        recommendations
            .add('Alguns pontos precisam de atenção. Revise prioridades.');
        break;
      case ReformHealthStatus.critical:
        recommendations.add(
            'Situação crítica! Foque em resolver os problemas principais.');
        break;
      case ReformHealthStatus.emergency:
        recommendations
            .add('URGENTE: A reforma precisa de intervenção imediata!');
        break;
    }

    return recommendations;
  }
}

/// Score de saúde da reforma
class ReformHealthScore {
  /// Score total (0-100)
  final double totalScore;

  /// Status de saúde
  final ReformHealthStatus status;

  /// Score de progresso (0-30)
  final double progressScore;

  /// Score financeiro (0-25)
  final double financialScore;

  /// Score de prazo (0-25)
  final double timelineScore;

  /// Score de qualidade (0-20)
  final double qualityScore;

  /// Recomendações
  final List<String> recommendations;

  const ReformHealthScore({
    required this.totalScore,
    required this.status,
    required this.progressScore,
    required this.financialScore,
    required this.timelineScore,
    required this.qualityScore,
    required this.recommendations,
  });

  /// Retorna a cor associada ao status
  String get statusColor {
    switch (status) {
      case ReformHealthStatus.excellent:
        return '#4CAF50'; // Verde
      case ReformHealthStatus.good:
        return '#8BC34A'; // Verde claro
      case ReformHealthStatus.attention:
        return '#FFC107'; // Amarelo
      case ReformHealthStatus.critical:
        return '#FF9800'; // Laranja
      case ReformHealthStatus.emergency:
        return '#F44336'; // Vermelho
    }
  }

  /// Retorna o ícone associado ao status
  String get statusIcon {
    switch (status) {
      case ReformHealthStatus.excellent:
        return '🎉';
      case ReformHealthStatus.good:
        return '👍';
      case ReformHealthStatus.attention:
        return '⚠️';
      case ReformHealthStatus.critical:
        return '🚨';
      case ReformHealthStatus.emergency:
        return '🆘';
    }
  }
}

/// Status de saúde da reforma
enum ReformHealthStatus {
  excellent, // 85-100: Excelente
  good, // 70-84: Bom
  attention, // 50-69: Atenção
  critical, // 30-49: Crítico
  emergency, // 0-29: Emergência
}

extension ReformHealthStatusExtension on ReformHealthStatus {
  String get label {
    switch (this) {
      case ReformHealthStatus.excellent:
        return 'Excelente';
      case ReformHealthStatus.good:
        return 'Bom';
      case ReformHealthStatus.attention:
        return 'Atenção';
      case ReformHealthStatus.critical:
        return 'Crítico';
      case ReformHealthStatus.emergency:
        return 'Emergência';
    }
  }

  String get description {
    switch (this) {
      case ReformHealthStatus.excellent:
        return 'Sua reforma está indo muito bem!';
      case ReformHealthStatus.good:
        return 'Tudo está no caminho certo';
      case ReformHealthStatus.attention:
        return 'Alguns pontos precisam de atenção';
      case ReformHealthStatus.critical:
        return 'Situação crítica, ação necessária';
      case ReformHealthStatus.emergency:
        return 'Intervenção urgente necessária!';
    }
  }
}

// Made with Bob
