/// Opções de orçamento no onboarding retroativo
enum BudgetOption {
  /// Usuário sabe o total gasto até agora
  total,

  /// Usuário tem notas fiscais e vai somar
  receipts,

  /// Usuário não sabe quanto gastou
  zero,
}

extension BudgetOptionExtension on BudgetOption {
  String get displayName {
    switch (this) {
      case BudgetOption.total:
        return 'Sei o total gasto';
      case BudgetOption.receipts:
        return 'Tenho notas fiscais';
      case BudgetOption.zero:
        return 'Não sei quanto gastei';
    }
  }

  String get description {
    switch (this) {
      case BudgetOption.total:
        return 'Vou informar o valor total aproximado';
      case BudgetOption.receipts:
        return 'Vou adicionar os gastos que tenho registrados';
      case BudgetOption.zero:
        return 'Vou começar a controlar a partir de agora';
    }
  }
}

// Made with Bob
