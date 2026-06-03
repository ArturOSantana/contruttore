import 'package:equatable/equatable.dart';

/// Representa o resumo financeiro do projeto
class FinancialSummaryEntity extends Equatable {
  final double totalCommitted;
  final double totalBudget;
  final double percentage;

  const FinancialSummaryEntity({
    required this.totalCommitted,
    required this.totalBudget,
    required this.percentage,
  });

  @override
  List<Object?> get props => [totalCommitted, totalBudget, percentage];
}

// Made with Bob
