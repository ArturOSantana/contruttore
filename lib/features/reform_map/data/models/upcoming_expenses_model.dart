import '../../domain/entities/upcoming_expenses_entity.dart';

/// Model para serialização de despesas futuras
class UpcomingExpensesModel extends UpcomingExpensesEntity {
  const UpcomingExpensesModel({
    required super.days,
    required super.expenses,
    required super.totalAmount,
    required super.availableBudget,
    required super.calculatedAt,
  });

  factory UpcomingExpensesModel.fromMap(Map<String, dynamic> map) {
    return UpcomingExpensesModel(
      days: map['days'] as int,
      expenses: (map['expenses'] as List<dynamic>)
          .map((expense) =>
              ExpensePreviewModel.fromMap(expense as Map<String, dynamic>))
          .toList(),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      availableBudget: (map['availableBudget'] as num).toDouble(),
      calculatedAt: DateTime.parse(map['calculatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'days': days,
      'expenses':
          expenses.map((e) => (e as ExpensePreviewModel).toMap()).toList(),
      'totalAmount': totalAmount,
      'availableBudget': availableBudget,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  factory UpcomingExpensesModel.fromEntity(UpcomingExpensesEntity entity) {
    return UpcomingExpensesModel(
      days: entity.days,
      expenses: entity.expenses
          .map((e) => ExpensePreviewModel.fromEntity(e))
          .toList(),
      totalAmount: entity.totalAmount,
      availableBudget: entity.availableBudget,
      calculatedAt: entity.calculatedAt,
    );
  }
}

/// Model para preview de despesa
class ExpensePreviewModel extends ExpensePreviewEntity {
  const ExpensePreviewModel({
    required super.id,
    required super.stepName,
    required super.category,
    required super.amount,
    required super.estimatedDate,
    required super.isCommitted,
    super.description,
    super.supplierId,
  });

  factory ExpensePreviewModel.fromMap(Map<String, dynamic> map) {
    return ExpensePreviewModel(
      id: map['id'] as String,
      stepName: map['stepName'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      estimatedDate: DateTime.parse(map['estimatedDate'] as String),
      isCommitted: map['isCommitted'] as bool,
      description: map['description'] as String?,
      supplierId: map['supplierId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stepName': stepName,
      'category': category,
      'amount': amount,
      'estimatedDate': estimatedDate.toIso8601String(),
      'isCommitted': isCommitted,
      'description': description,
      'supplierId': supplierId,
    };
  }

  factory ExpensePreviewModel.fromEntity(ExpensePreviewEntity entity) {
    return ExpensePreviewModel(
      id: entity.id,
      stepName: entity.stepName,
      category: entity.category,
      amount: entity.amount,
      estimatedDate: entity.estimatedDate,
      isCommitted: entity.isCommitted,
      description: entity.description,
      supplierId: entity.supplierId,
    );
  }
}

// Made with Bob
