import 'package:equatable/equatable.dart';

class FinancialSummaryEntity extends Equatable {
  final double totalBudget;
  final double totalConfirmed;
  final double totalCommitted;
  final double totalEstimated;
  final double totalSpent; // confirmed + committed
  final double remaining;
  final double percentageUsed;
  final Map<String, CategorySummary> categorySummaries;

  const FinancialSummaryEntity({
    required this.totalBudget,
    required this.totalConfirmed,
    required this.totalCommitted,
    required this.totalEstimated,
    required this.totalSpent,
    required this.remaining,
    required this.percentageUsed,
    required this.categorySummaries,
  });

  @override
  List<Object?> get props => [
    totalBudget,
    totalConfirmed,
    totalCommitted,
    totalEstimated,
    totalSpent,
    remaining,
    percentageUsed,
    categorySummaries,
  ];
}

class CategorySummary extends Equatable {
  final String categoryId;
  final String categoryName;
  final double budget;
  final double spent;
  final double percentage;
  final CategoryStatus status;

  const CategorySummary({
    required this.categoryId,
    required this.categoryName,
    required this.budget,
    required this.spent,
    required this.percentage,
    required this.status,
  });

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    budget,
    spent,
    percentage,
    status,
  ];
}

enum CategoryStatus {
  ok, // < 80%
  warning, // 80-100%
  exceeded, // > 100%
}

// Made with Bob
