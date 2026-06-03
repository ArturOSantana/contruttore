import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_option.dart';
import '../../domain/entities/quick_supplier.dart';
import '../../domain/entities/retroactive_expense_entry.dart';

/// Estados do fluxo de onboarding retroativo
abstract class RetroactiveState extends Equatable {
  const RetroactiveState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class RetroactiveInitial extends RetroactiveState {
  const RetroactiveInitial();
}

/// Coletando dados do usuário
class RetroactiveCollecting extends RetroactiveState {
  final int? selectedPhaseNumber;
  final BudgetOption? budgetOption;
  final double? totalSpent;
  final List<RetroactiveExpenseEntry> expenseEntries;
  final List<QuickSupplier> quickSuppliers;

  const RetroactiveCollecting({
    this.selectedPhaseNumber,
    this.budgetOption,
    this.totalSpent,
    this.expenseEntries = const [],
    this.quickSuppliers = const [],
  });

  RetroactiveCollecting copyWith({
    int? selectedPhaseNumber,
    BudgetOption? budgetOption,
    double? totalSpent,
    List<RetroactiveExpenseEntry>? expenseEntries,
    List<QuickSupplier>? quickSuppliers,
  }) {
    return RetroactiveCollecting(
      selectedPhaseNumber: selectedPhaseNumber ?? this.selectedPhaseNumber,
      budgetOption: budgetOption ?? this.budgetOption,
      totalSpent: totalSpent ?? this.totalSpent,
      expenseEntries: expenseEntries ?? this.expenseEntries,
      quickSuppliers: quickSuppliers ?? this.quickSuppliers,
    );
  }

  bool get canProceed {
    // Precisa ter selecionado a fase atual
    if (selectedPhaseNumber == null) return false;

    // Precisa ter escolhido uma opção de orçamento
    if (budgetOption == null) return false;

    // Se escolheu "total", precisa ter informado o valor
    if (budgetOption == BudgetOption.total &&
        (totalSpent == null || totalSpent! <= 0)) {
      return false;
    }

    // Se escolheu "receipts", precisa ter adicionado pelo menos uma despesa
    if (budgetOption == BudgetOption.receipts && expenseEntries.isEmpty) {
      return false;
    }

    return true;
  }

  double get calculatedTotalSpent {
    if (budgetOption == BudgetOption.total) {
      return totalSpent ?? 0.0;
    } else if (budgetOption == BudgetOption.receipts) {
      return expenseEntries.fold(0.0, (sum, entry) => sum + entry.amount);
    }
    return 0.0;
  }

  @override
  List<Object?> get props => [
    selectedPhaseNumber,
    budgetOption,
    totalSpent,
    expenseEntries,
    quickSuppliers,
  ];
}

/// Criando projeto retroativo
class RetroactiveCreating extends RetroactiveState {
  const RetroactiveCreating();
}

/// Projeto retroativo criado com sucesso
class RetroactiveSuccess extends RetroactiveState {
  final String projectId;

  const RetroactiveSuccess(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Erro ao criar projeto retroativo
class RetroactiveError extends RetroactiveState {
  final String message;

  const RetroactiveError(this.message);

  @override
  List<Object?> get props => [message];
}

// Made with Bob
