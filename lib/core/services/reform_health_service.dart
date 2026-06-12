import 'package:injectable/injectable.dart';
import '../../features/projects/domain/entities/phase_entity.dart';
import '../../features/projects/domain/entities/project_entity.dart';

/// Serviço que calcula a "saúde" da reforma
///
/// Analisa múltiplos fatores para determinar se a reforma está saudável:
/// - Prazo (25%)
/// - Orçamento (30%)
/// - Problemas (20%)
/// - Tarefas (15%)
/// - Pagamentos (10%)
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
    // FATOR 1: PRAZO (25%)
    final deadlineScore = _calculateDeadlineScore(project);

    // FATOR 2: ORÇAMENTO (30%)
    final budgetScore = _calculateBudgetScore(
      totalBudget: project.totalBudget ?? 0.0,
      totalSpent: totalSpent,
      totalPending: totalPending,
    );

    // FATOR 3: PROBLEMAS (20%)
    final problemsScore = _calculateProblemsScore(criticalAlertsCount);

    // FATOR 4: TAREFAS (15%)
    final tasksScore = _calculateTasksScore(phases);

    // FATOR 5: PAGAMENTOS (10%)
    final paymentsScore = _calculatePaymentsScore(delayedPhasesCount);

    // Calcula score total
    final totalScore = (deadlineScore * 0.25) +
        (budgetScore * 0.30) +
        (problemsScore * 0.20) +
        (tasksScore * 0.15) +
        (paymentsScore * 0.10);

    // Determina status
    final status = _determineHealthStatus(totalScore);

    // Gera mensagem inteligente
    final message = _getHealthMessage(
      totalScore,
      deadlineScore,
      budgetScore,
      problemsScore,
      tasksScore,
      paymentsScore,
    );

    // Gera issues e positives
    final issues = _generateIssues(
      deadlineScore: deadlineScore,
      budgetScore: budgetScore,
      problemsScore: problemsScore,
      tasksScore: tasksScore,
      paymentsScore: paymentsScore,
      criticalAlertsCount: criticalAlertsCount,
      delayedPhasesCount: delayedPhasesCount,
      totalBudget: project.totalBudget ?? 0.0,
      totalSpent: totalSpent,
      totalPending: totalPending,
      estimatedEndDate: project.deliveryDate,
      phases: phases,
    );

    final positives = _generatePositives(
      deadlineScore: deadlineScore,
      budgetScore: budgetScore,
      problemsScore: problemsScore,
      tasksScore: tasksScore,
      paymentsScore: paymentsScore,
      phases: phases,
    );

    // Gera recomendações (mantém compatibilidade)
    final recommendations = [message, ...issues.take(2)];

    return ReformHealthScore(
      totalScore: totalScore,
      status: status,
      progressScore: tasksScore, // Mantém compatibilidade
      financialScore: budgetScore, // Mantém compatibilidade
      timelineScore: deadlineScore, // Mantém compatibilidade
      qualityScore: problemsScore, // Mantém compatibilidade
      recommendations: recommendations,
      message: message,
      issues: issues,
      positives: positives,
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

  /// Calcula score de prazo (0-100)
  double _calculateDeadlineScore(ProjectEntity project) {
    double deadlineScore = 100.0;
    final estimatedEndDate = project.deliveryDate;

    final now = DateTime.now();
    final daysRemaining = estimatedEndDate.difference(now).inDays;

    if (daysRemaining < 0) {
      // Atrasado
      final daysDelayed = daysRemaining.abs();
      if (daysDelayed > 30) {
        deadlineScore = 0.0; // Muito atrasado
      } else if (daysDelayed > 15) {
        deadlineScore = 30.0; // Atrasado
      } else {
        deadlineScore = 60.0; // Levemente atrasado
      }
    } else if (daysRemaining < 7) {
      deadlineScore = 70.0; // Prazo apertado
    } else if (daysRemaining < 15) {
      deadlineScore = 85.0; // Prazo próximo
    }

    return deadlineScore;
  }

  /// Calcula score de orçamento (0-100)
  double _calculateBudgetScore({
    required double totalBudget,
    required double totalSpent,
    required double totalPending,
  }) {
    double budgetScore = 100.0;

    if (totalBudget > 0) {
      final totalCommitted = totalSpent + totalPending;
      final percentageUsed = (totalCommitted / totalBudget) * 100;

      if (percentageUsed > 110) {
        budgetScore = 0.0; // Muito acima do orçamento
      } else if (percentageUsed > 100) {
        budgetScore = 30.0; // Acima do orçamento
      } else if (percentageUsed > 90) {
        budgetScore = 60.0; // Próximo do limite
      } else if (percentageUsed > 80) {
        budgetScore = 80.0; // Atenção
      } else if (percentageUsed > 70) {
        budgetScore = 90.0; // Bom
      }
    }

    return budgetScore;
  }

  /// Calcula score de problemas (0-100)
  double _calculateProblemsScore(int criticalAlertsCount) {
    double problemsScore = 100.0;

    if (criticalAlertsCount > 0) {
      // Penalizar por alertas críticos (cada um vale 30 pontos)
      final problemImpact = criticalAlertsCount * 30;
      problemsScore = (100.0 - problemImpact).clamp(0.0, 100.0);
    }

    return problemsScore;
  }

  /// Calcula score de tarefas (0-100)
  double _calculateTasksScore(List<PhaseEntity> phases) {
    double tasksScore = 100.0;
    int totalSubtasks = 0;
    int completedSubtasks = 0;

    for (final phase in phases) {
      for (final subtask in phase.subtasks) {
        totalSubtasks++;
        if (subtask.isDone) {
          completedSubtasks++;
        }
      }
    }

    if (totalSubtasks > 0) {
      final completionRate = (completedSubtasks / totalSubtasks) * 100;
      tasksScore = completionRate;
    }

    return tasksScore;
  }

  /// Calcula score de pagamentos (0-100)
  double _calculatePaymentsScore(int delayedPhasesCount) {
    double paymentsScore = 100.0;

    if (delayedPhasesCount > 0) {
      if (delayedPhasesCount > 5) {
        paymentsScore = 0.0; // Muitos pagamentos atrasados
      } else if (delayedPhasesCount > 3) {
        paymentsScore = 40.0; // Vários pagamentos atrasados
      } else if (delayedPhasesCount > 1) {
        paymentsScore = 70.0; // Alguns pagamentos atrasados
      } else {
        paymentsScore = 85.0; // Um pagamento atrasado
      }
    }

    return paymentsScore;
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

  /// Gera mensagem inteligente baseada nos scores
  String _getHealthMessage(
    double score,
    double deadlineScore,
    double budgetScore,
    double problemsScore,
    double tasksScore,
    double paymentsScore,
  ) {
    // Identificar o fator mais crítico
    final factors = {
      'prazo': deadlineScore,
      'orçamento': budgetScore,
      'problemas': problemsScore,
      'tarefas': tasksScore,
      'pagamentos': paymentsScore,
    };

    final lowestFactor =
        factors.entries.reduce((a, b) => a.value < b.value ? a : b);

    if (score >= 90) {
      return 'Excelente! Sua reforma está indo muito bem';
    } else if (score >= 80) {
      return 'Tudo está no caminho certo. Continue assim!';
    } else if (score >= 70) {
      if (lowestFactor.key == 'prazo') {
        return 'Atenção ao cronograma para manter o prazo';
      } else if (lowestFactor.key == 'orçamento') {
        return 'Fique atento aos gastos para não estourar o orçamento';
      } else if (lowestFactor.key == 'problemas') {
        return 'Resolva os problemas pendentes para evitar atrasos';
      } else if (lowestFactor.key == 'pagamentos') {
        return 'Organize os pagamentos pendentes';
      } else {
        return 'Conclua as tarefas pendentes para avançar';
      }
    } else if (score >= 50) {
      return 'Alguns pontos precisam de atenção urgente';
    } else {
      return 'Ação imediata necessária para evitar problemas maiores';
    }
  }

  /// Gera lista de issues baseada nos dados reais
  List<String> _generateIssues({
    required double deadlineScore,
    required double budgetScore,
    required double problemsScore,
    required double tasksScore,
    required double paymentsScore,
    required int criticalAlertsCount,
    required int delayedPhasesCount,
    required double totalBudget,
    required double totalSpent,
    required double totalPending,
    required DateTime estimatedEndDate,
    required List<PhaseEntity> phases,
  }) {
    final issues = <String>[];

    // Issues de prazo
    if (deadlineScore < 70) {
      final daysRemaining = estimatedEndDate.difference(DateTime.now()).inDays;
      if (daysRemaining < 0) {
        issues.add('Obra atrasada em ${daysRemaining.abs()} dias');
      } else if (daysRemaining < 7) {
        issues.add('Apenas $daysRemaining dias até o prazo final');
      } else if (daysRemaining < 15) {
        issues.add('Prazo se aproximando: $daysRemaining dias restantes');
      }
    }

    // Issues de orçamento
    if (budgetScore < 70 && totalBudget > 0) {
      final totalCommitted = totalSpent + totalPending;
      final percentageUsed = (totalCommitted / totalBudget) * 100;
      if (percentageUsed > 100) {
        final overBudget = totalCommitted - totalBudget;
        issues
            .add('Orçamento estourado em R\$ ${overBudget.toStringAsFixed(2)}');
      } else if (percentageUsed > 90) {
        final remaining = totalBudget - totalCommitted;
        issues.add(
            'Apenas R\$ ${remaining.toStringAsFixed(2)} restantes no orçamento');
      } else if (percentageUsed > 80) {
        issues.add(
            '${percentageUsed.toStringAsFixed(0)}% do orçamento já comprometido');
      }
    }

    // Issues de problemas
    if (criticalAlertsCount > 0) {
      issues.add(
          '$criticalAlertsCount problema(s) crítico(s) requer atenção imediata');
    }

    // Issues de tarefas
    if (tasksScore < 70) {
      issues.add(
          'Muitas tarefas pendentes (${(100 - tasksScore).toStringAsFixed(0)}% incompletas)');
    }

    // Issues de pagamentos
    if (delayedPhasesCount > 0) {
      issues.add('$delayedPhasesCount pagamento(s) atrasado(s)');
    }

    return issues;
  }

  /// Gera lista de positives baseada nos dados reais
  List<String> _generatePositives({
    required double deadlineScore,
    required double budgetScore,
    required double problemsScore,
    required double tasksScore,
    required double paymentsScore,
    required List<PhaseEntity> phases,
  }) {
    final positives = <String>[];

    // Positivos de prazo
    if (deadlineScore >= 85) {
      positives.add('Cronograma dentro do prazo');
    }

    // Positivos de orçamento
    if (budgetScore >= 80) {
      positives.add('Orçamento sob controle');
    }

    // Positivos de problemas
    if (problemsScore >= 90) {
      positives.add('Nenhum problema crítico identificado');
    }

    // Positivos de tarefas
    int totalSubtasks = 0;
    int completedSubtasks = 0;
    for (final phase in phases) {
      for (final subtask in phase.subtasks) {
        totalSubtasks++;
        if (subtask.isDone) {
          completedSubtasks++;
        }
      }
    }

    if (tasksScore >= 80 && totalSubtasks > 0) {
      positives.add('$completedSubtasks de $totalSubtasks tarefas concluídas');
    }

    // Positivos de pagamentos
    if (paymentsScore >= 90) {
      positives.add('Todos os pagamentos em dia');
    }

    // Se não houver positivos específicos, adicionar mensagem genérica
    if (positives.isEmpty) {
      positives.add('Continue trabalhando para melhorar a saúde da reforma');
    }

    return positives;
  }
}

/// Score de saúde da reforma
class ReformHealthScore {
  /// Score total (0-100)
  final double totalScore;

  /// Status de saúde
  final ReformHealthStatus status;

  /// Score de progresso (0-30) - mantido para compatibilidade
  final double progressScore;

  /// Score financeiro (0-25) - mantido para compatibilidade
  final double financialScore;

  /// Score de prazo (0-25) - mantido para compatibilidade
  final double timelineScore;

  /// Score de qualidade (0-20) - mantido para compatibilidade
  final double qualityScore;

  /// Recomendações - mantido para compatibilidade
  final List<String> recommendations;

  /// Mensagem principal
  final String message;

  /// Lista de issues (pontos de atenção)
  final List<String> issues;

  /// Lista de positives (pontos positivos)
  final List<String> positives;

  const ReformHealthScore({
    required this.totalScore,
    required this.status,
    required this.progressScore,
    required this.financialScore,
    required this.timelineScore,
    required this.qualityScore,
    required this.recommendations,
    required this.message,
    required this.issues,
    required this.positives,
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
