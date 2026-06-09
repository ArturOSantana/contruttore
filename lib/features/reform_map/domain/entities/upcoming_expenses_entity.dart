import 'package:equatable/equatable.dart';

/// Entidade que representa despesas futuras previstas
class UpcomingExpensesEntity extends Equatable {
  final int days; // Período de previsão (30, 60, 90 dias)
  final List<ExpensePreviewEntity> expenses;
  final double totalAmount;
  final double availableBudget; // Orçamento disponível
  final DateTime calculatedAt;

  const UpcomingExpensesEntity({
    required this.days,
    required this.expenses,
    required this.totalAmount,
    required this.availableBudget,
    required this.calculatedAt,
  });

  /// Verifica se há orçamento suficiente
  bool get hasEnoughBudget => availableBudget >= totalAmount;

  /// Calcula o déficit orçamentário
  double get budgetShortfall {
    final shortfall = totalAmount - availableBudget;
    return shortfall > 0 ? shortfall : 0;
  }

  /// Verifica se há risco de fluxo de caixa
  bool get hasCashFlowRisk => budgetShortfall > 0;

  /// Despesas comprometidas (contratos assinados)
  List<ExpensePreviewEntity> get committedExpenses =>
      expenses.where((e) => e.isCommitted).toList();

  /// Despesas estimadas (ainda não comprometidas)
  List<ExpensePreviewEntity> get estimatedExpenses =>
      expenses.where((e) => !e.isCommitted).toList();

  /// Total de despesas comprometidas
  double get committedTotal =>
      committedExpenses.fold(0, (sum, e) => sum + e.amount);

  /// Total de despesas estimadas
  double get estimatedTotal =>
      estimatedExpenses.fold(0, (sum, e) => sum + e.amount);

  @override
  List<Object?> get props => [
        days,
        expenses,
        totalAmount,
        availableBudget,
        calculatedAt,
      ];
}

/// Preview de uma despesa futura
class ExpensePreviewEntity extends Equatable {
  final String id;
  final String stepName; // Nome da etapa relacionada
  final String category; // Categoria da despesa
  final double amount;
  final DateTime estimatedDate;
  final bool isCommitted; // Se já tem contrato assinado
  final String? description;
  final String? supplierId; // Fornecedor relacionado

  const ExpensePreviewEntity({
    required this.id,
    required this.stepName,
    required this.category,
    required this.amount,
    required this.estimatedDate,
    required this.isCommitted,
    this.description,
    this.supplierId,
  });

  /// Dias até a despesa
  int get daysUntil {
    final diff = estimatedDate.difference(DateTime.now());
    return diff.inDays;
  }

  /// Verifica se é urgente (menos de 7 dias)
  bool get isUrgent => daysUntil <= 7 && daysUntil >= 0;

  /// Verifica se está atrasada
  bool get isOverdue => daysUntil < 0;

  @override
  List<Object?> get props => [
        id,
        stepName,
        category,
        amount,
        estimatedDate,
        isCommitted,
        description,
        supplierId,
      ];
}

// Made with Bob
