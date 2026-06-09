import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/financial_summary_entity.dart';
import '../../domain/repositories/financial_repository.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';

@LazySingleton(as: FinancialRepository)
class FinancialRepositoryImpl implements FinancialRepository {
  final FirebaseFirestore _firestore;

  FinancialRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses(
    String projectId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('expenses')
          .orderBy('date', descending: true)
          .get();

      final expenses = snapshot.docs
          .map((doc) => ExpenseModel.fromMap(doc.data(), doc.id))
          .toList();

      return Right(expenses);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar despesas: $e'));
    }
  }

  @override
  Future<Either<Failure, ExpenseEntity>> getExpense(
    String projectId,
    String expenseId,
  ) async {
    try {
      final doc = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('expenses')
          .doc(expenseId)
          .get();

      if (!doc.exists) {
        return Left(ServerFailure('Despesa não encontrada'));
      }

      return Right(ExpenseModel.fromMap(doc.data()!, doc.id));
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar despesa: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addExpense(ExpenseEntity expense) async {
    try {
      final expenseModel = ExpenseModel.fromEntity(expense);
      await _firestore
          .collection('projects')
          .doc(expense.projectId)
          .collection('expenses')
          .add(expenseModel.toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao adicionar despesa: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateExpense(ExpenseEntity expense) async {
    try {
      final expenseModel = ExpenseModel.fromEntity(expense);
      await _firestore
          .collection('projects')
          .doc(expense.projectId)
          .collection('expenses')
          .doc(expense.id)
          .update(expenseModel.toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar despesa: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(
    String projectId,
    String expenseId,
  ) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('expenses')
          .doc(expenseId)
          .delete();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao deletar despesa: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories(
    String projectId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('categories')
          .orderBy('order')
          .get();

      final categories = snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
          .toList();

      return Right(categories);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar categorias: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategoryBudget(
    String projectId,
    String categoryId,
    double newBudget,
  ) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('categories')
          .doc(categoryId)
          .update({'budgetAmount': newBudget});

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar orçamento: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> initializeDefaultCategories(
    String projectId,
    CategoryType type,
  ) async {
    try {
      final categories = _getDefaultCategories(type);
      final batch = _firestore.batch();

      for (final category in categories) {
        final docRef = _firestore
            .collection('projects')
            .doc(projectId)
            .collection('categories')
            .doc();

        batch.set(docRef, category.toMap());
      }

      await batch.commit();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao inicializar categorias: $e'));
    }
  }

  List<CategoryModel> _getDefaultCategories(CategoryType type) {
    if (type == CategoryType.buyer) {
      return [
        const CategoryModel(
          id: '',
          name: 'Parcelas do imóvel',
          budgetAmount: 0,
          type: CategoryType.buyer,
          order: 0,
        ),
        const CategoryModel(
          id: '',
          name: 'INCC (estimativa)',
          budgetAmount: 0,
          type: CategoryType.buyer,
          order: 1,
        ),
        const CategoryModel(
          id: '',
          name: 'Balão final',
          budgetAmount: 0,
          type: CategoryType.buyer,
          order: 2,
        ),
        const CategoryModel(
          id: '',
          name: 'ITBI',
          budgetAmount: 0,
          type: CategoryType.buyer,
          order: 3,
        ),
        const CategoryModel(
          id: '',
          name: 'Escritura',
          budgetAmount: 0,
          type: CategoryType.buyer,
          order: 4,
        ),
        const CategoryModel(
          id: '',
          name: 'Registro em cartório',
          budgetAmount: 0,
          type: CategoryType.buyer,
          order: 5,
        ),
        const CategoryModel(
          id: '',
          name: 'Taxa de financiamento',
          budgetAmount: 0,
          type: CategoryType.buyer,
          order: 6,
        ),
      ];
    } else {
      return [
        const CategoryModel(
          id: '',
          name: 'Projeto',
          budgetAmount: 0,
          type: CategoryType.renovation,
          order: 0,
        ),
        const CategoryModel(
          id: '',
          name: 'Demolição',
          budgetAmount: 0,
          type: CategoryType.renovation,
          order: 1,
        ),
        const CategoryModel(
          id: '',
          name: 'Elétrica',
          budgetAmount: 0,
          type: CategoryType.renovation,
          order: 2,
        ),
        const CategoryModel(
          id: '',
          name: 'Hidráulica',
          budgetAmount: 0,
          type: CategoryType.renovation,
          order: 3,
        ),
        const CategoryModel(
          id: '',
          name: 'Gás',
          budgetAmount: 0,
          type: CategoryType.renovation,
          order: 4,
        ),
        const CategoryModel(
          id: '',
          name: 'Revestimentos',
          budgetAmount: 0,
          type: CategoryType.renovation,
          order: 5,
        ),
        const CategoryModel(
          id: '',
          name: 'Pisos',
          budgetAmount: 0,
          type: CategoryType.renovation,
          order: 6,
        ),
        const CategoryModel(
          id: '',
          name: 'Forro e gesso',
          budgetAmount: 0,
          type: CategoryType.renovation,
          order: 7,
        ),
        const CategoryModel(
          id: '',
          name: 'Pintura',
          budgetAmount: 0,
          type: CategoryType.renovation,
          order: 8,
        ),
        const CategoryModel(
          id: '',
          name: 'Esquadrias',
          budgetAmount: 0,
          type: CategoryType.renovation,
          order: 9,
        ),
        const CategoryModel(
          id: '',
          name: 'Louças e metais',
          budgetAmount: 0,
          type: CategoryType.renovation,
          order: 10,
        ),
        const CategoryModel(
          id: '',
          name: 'Marcenaria',
          budgetAmount: 0,
          type: CategoryType.renovation,
          order: 11,
        ),
        const CategoryModel(
          id: '',
          name: 'Mobiliário',
          budgetAmount: 0,
          type: CategoryType.renovation,
          order: 12,
        ),
        const CategoryModel(
          id: '',
          name: 'Contingência',
          budgetAmount: 0,
          type: CategoryType.renovation,
          order: 13,
        ),
      ];
    }
  }

  @override
  Future<Either<Failure, FinancialSummaryEntity>> getFinancialSummary(
    String projectId,
  ) async {
    try {
      // Buscar categorias e despesas em paralelo (otimização)
      final results = await Future.wait([
        getCategories(projectId),
        getExpenses(projectId),
      ]);

      final categoriesResult =
          results[0] as Either<Failure, List<CategoryEntity>>;
      final expensesResult = results[1] as Either<Failure, List<ExpenseEntity>>;

      if (categoriesResult.isLeft()) {
        return Left(ServerFailure('Erro ao buscar categorias'));
      }
      if (expensesResult.isLeft()) {
        return Left(ServerFailure('Erro ao buscar despesas'));
      }

      final categories = categoriesResult.getOrElse(() => []);
      final expenses = expensesResult.getOrElse(() => []);

      // Calcular totais
      double totalBudget = 0;
      double totalConfirmed = 0;
      double totalCommitted = 0;
      double totalEstimated = 0;

      final Map<String, CategorySummary> categorySummaries = {};

      for (final category in categories) {
        totalBudget += category.budgetAmount;

        final categoryExpenses = expenses.where(
          (e) => e.categoryId == category.id,
        );

        double categoryConfirmed = 0;
        double categoryCommitted = 0;
        double categoryEstimated = 0;

        for (final expense in categoryExpenses) {
          switch (expense.status) {
            case ExpenseStatus.confirmed:
              categoryConfirmed += expense.amount;
              totalConfirmed += expense.amount;
              break;
            case ExpenseStatus.committed:
              categoryCommitted += expense.amount;
              totalCommitted += expense.amount;
              break;
            case ExpenseStatus.estimated:
              categoryEstimated += expense.amount;
              totalEstimated += expense.amount;
              break;
          }
        }

        final categorySpent = categoryConfirmed + categoryCommitted;
        final categoryPercentage = category.budgetAmount > 0
            ? (categorySpent / category.budgetAmount) * 100
            : 0;

        CategoryStatus status;
        if (categoryPercentage > 100) {
          status = CategoryStatus.exceeded;
        } else if (categoryPercentage >= 80) {
          status = CategoryStatus.warning;
        } else {
          status = CategoryStatus.ok;
        }

        categorySummaries[category.id] = CategorySummary(
          categoryId: category.id,
          categoryName: category.name,
          budget: category.budgetAmount,
          spent: categorySpent,
          percentage: categoryPercentage.toDouble(),
          status: status,
        );
      }

      final totalSpent = totalConfirmed + totalCommitted;
      final remaining = totalBudget - totalSpent;
      final percentageUsed =
          totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0.0;

      return Right(
        FinancialSummaryEntity(
          totalBudget: totalBudget,
          totalConfirmed: totalConfirmed,
          totalCommitted: totalCommitted,
          totalEstimated: totalEstimated,
          totalSpent: totalSpent,
          remaining: remaining,
          percentageUsed: percentageUsed.toDouble(),
          categorySummaries: categorySummaries,
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao calcular resumo financeiro: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePhaseFinancials({
    required String projectId,
    required String phaseId,
  }) async {
    try {
      // Buscar todas as despesas da fase
      final expensesSnapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('expenses')
          .where('phaseId', isEqualTo: phaseId)
          .get();

      // Calcular totais
      double totalSpent = 0;
      double totalPending = 0;
      double totalEstimated = 0;

      for (final doc in expensesSnapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        final status = data['status'] as String?;

        if (status == 'confirmed') {
          totalSpent += amount;
        } else if (status == 'committed') {
          totalPending += amount;
        } else if (status == 'estimated') {
          totalEstimated += amount;
        }
      }

      // Usar WriteBatch para operações atômicas
      final batch = _firestore.batch();

      // Atualizar a fase
      final phaseRef = _firestore
          .collection('projects')
          .doc(projectId)
          .collection('phases')
          .doc(phaseId);

      batch.update(phaseRef, {
        'totalSpent': totalSpent,
        'totalPending': totalPending,
        'totalEstimated': totalEstimated,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Atualizar o projeto com totais consolidados
      final projectRef = _firestore.collection('projects').doc(projectId);

      // Buscar todas as fases para calcular total do projeto
      final phasesSnapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('phases')
          .get();

      double projectTotalSpent = totalSpent;
      double projectTotalPending = totalPending;

      for (final phaseDoc in phasesSnapshot.docs) {
        if (phaseDoc.id != phaseId) {
          final phaseData = phaseDoc.data();
          projectTotalSpent +=
              (phaseData['totalSpent'] as num?)?.toDouble() ?? 0;
          projectTotalPending +=
              (phaseData['totalPending'] as num?)?.toDouble() ?? 0;
        }
      }

      batch.update(projectRef, {
        'totalSpent': projectTotalSpent,
        'totalPending': projectTotalPending,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Executar todas as operações atomicamente
      await batch.commit();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar financeiro da fase: $e'));
    }
  }
}

// Made with Bob
