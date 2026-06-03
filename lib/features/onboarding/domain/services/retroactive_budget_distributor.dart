/// Serviço que distribui o orçamento total entre as fases
/// usando pesos baseados em referências SINAPI
class RetroactiveBudgetDistributor {
  /// Pesos percentuais por fase (baseado em obras residenciais típicas)
  /// Total: 100%
  static const Map<int, double> _phaseWeights = {
    // Jornada A - Comprador (antes das chaves)
    1: 0.0, // Assinatura e documentação - sem custo direto
    2: 0.0, // Acompanhamento da obra - sem custo direto
    3: 0.0, // Decisões de personalização - sem custo direto
    4: 0.0, // Preparação para entrega - sem custo direto
    5: 0.0, // Vistoria de entrega - sem custo direto
    // Jornada B - Reforma (após as chaves)
    6: 2.0, // Regularização pós-entrega (ITBI, escritura, etc)
    7: 8.0, // Projeto e planejamento (arquiteto, engenheiro)
    8: 5.0, // Demolição e limpeza
    9: 25.0, // Instalações (hidráulica e elétrica) - maior custo
    10: 30.0, // Revestimentos e pisos - maior custo
    11: 15.0, // Gesso, pintura e acabamentos
    12: 15.0, // Marcenaria e mobiliário
  };

  /// Distribui o valor total entre as fases ativas
  ///
  /// [totalBudget] - Valor total a ser distribuído
  /// [currentPhaseNumber] - Fase atual do usuário (1-12)
  ///
  /// Retorna um Map com o orçamento estimado por fase
  static Map<int, double> distribute({
    required double totalBudget,
    required int currentPhaseNumber,
  }) {
    final result = <int, double>{};

    // Se está na Jornada A (fases 1-5), não distribui orçamento
    if (currentPhaseNumber <= 5) {
      for (int i = 1; i <= 12; i++) {
        result[i] = 0.0;
      }
      return result;
    }

    // Calcula quais fases vão receber orçamento
    // Fases anteriores à atual (6 até currentPhaseNumber-1) = já gastou
    // Fase atual e futuras (currentPhaseNumber até 12) = vai gastar

    // Soma os pesos das fases que ainda vão receber orçamento
    double totalWeightRemaining = 0.0;
    for (int phase = currentPhaseNumber; phase <= 12; phase++) {
      totalWeightRemaining += _phaseWeights[phase] ?? 0.0;
    }

    // Se não há peso restante, distribui igualmente
    if (totalWeightRemaining == 0) {
      final phasesRemaining = 12 - currentPhaseNumber + 1;
      final budgetPerPhase = totalBudget / phasesRemaining;
      for (int phase = currentPhaseNumber; phase <= 12; phase++) {
        result[phase] = budgetPerPhase;
      }
      return result;
    }

    // Distribui proporcionalmente aos pesos
    for (int phase = 1; phase <= 12; phase++) {
      if (phase < currentPhaseNumber) {
        // Fases passadas não recebem orçamento (já foi gasto)
        result[phase] = 0.0;
      } else {
        // Fases futuras recebem proporcionalmente
        final weight = _phaseWeights[phase] ?? 0.0;
        result[phase] = (weight / totalWeightRemaining) * totalBudget;
      }
    }

    return result;
  }

  /// Retorna o peso percentual de uma fase
  static double getPhaseWeight(int phaseNumber) {
    return _phaseWeights[phaseNumber] ?? 0.0;
  }

  /// Retorna descrição do que representa o peso da fase
  static String getPhaseWeightDescription(int phaseNumber) {
    final weight = getPhaseWeight(phaseNumber);
    if (weight == 0) {
      return 'Sem custo direto';
    }
    return '${weight.toStringAsFixed(0)}% do orçamento total';
  }

  /// Calcula o orçamento sugerido para uma fase específica
  /// baseado no orçamento total do projeto
  static double calculatePhaseBudget({
    required double totalBudget,
    required int phaseNumber,
  }) {
    final weight = _phaseWeights[phaseNumber] ?? 0.0;
    return (weight / 100.0) * totalBudget;
  }

  /// Valida se a distribuição está correta (soma = 100%)
  static bool validateWeights() {
    double sum = 0.0;
    _phaseWeights.forEach((_, weight) {
      sum += weight;
    });
    return (sum - 100.0).abs() < 0.01; // Tolerância de 0.01%
  }
}

// Made with Bob
