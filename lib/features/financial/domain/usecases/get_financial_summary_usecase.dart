import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/financial_summary_entity.dart';
import '../repositories/transaction_repository.dart';
import '../../../projects/domain/repositories/project_repository.dart';
import '../../../payments/domain/repositories/payment_repository.dart';

/// Use case para obter resumo financeiro do projeto
///
/// NOVA ARQUITETURA COM PAYMENTS:
/// - Usa TransactionRepository.getFinancialSummary()
/// - Usa PaymentRepository para somar payments pagos
/// - Commitment representa valor total do contrato
/// - Expenses são subset (não somam com commitment)
/// - Payments pagos somam ao totalSpent
/// - Reversals com signedAmount negativo já incluídos
/// - Converte Map<String, double> para FinancialSummaryEntity
@lazySingleton
class GetFinancialSummaryUseCase
    implements UseCase<FinancialSummaryEntity, String> {
  final TransactionRepository _transactionRepository;
  final ProjectRepository _projectRepository;
  final PaymentRepository _paymentRepository;

  GetFinancialSummaryUseCase(
    this._transactionRepository,
    this._projectRepository,
    this._paymentRepository,
  );

  @override
  Future<Either<Failure, FinancialSummaryEntity>> call(String projectId) async {
    try {
      // 1. Buscar dados do projeto (orçamento total)
      final projectResult = await _projectRepository.getProject(projectId);
      if (projectResult.isLeft()) {
        return Left(
          projectResult.fold((failure) => failure, (_) => throw Exception()),
        );
      }
      final project = projectResult.getOrElse(() => throw Exception());

      // 2. Buscar resumo financeiro das transactions
      final summaryResult = await _transactionRepository.getFinancialSummary(
        projectId,
      );
      if (summaryResult.isLeft()) {
        return Left(
          summaryResult.fold((failure) => failure, (_) => throw Exception()),
        );
      }
      final summaryMap = summaryResult.getOrElse(() => throw Exception());

      // 3. Buscar payments pagos (nova integração)
      final payments = await _paymentRepository.getPayments(projectId);
      final paidPayments = payments.where((p) => p.paid).toList();
      final totalPaidFromPayments = paidPayments.fold<double>(
        0.0,
        (sum, payment) => sum + payment.amount,
      );

      // 4. Extrair valores do Map
      final totalCommitted = summaryMap['totalCommitted'] ?? 0.0;
      final totalExpenses = summaryMap['totalExpenses'] ?? 0.0;
      final totalEstimates = summaryMap['totalEstimates'] ?? 0.0;
      final pendingFromContracts = summaryMap['pendingFromContracts'] ?? 0.0;

      // 5. Calcular totais
      // REGRA ATUALIZADA:
      // - totalSpent = expenses + payments pagos
      // - expenses são transações manuais confirmadas
      // - payments pagos são parcelas de suppliers/purchases
      // - NÃO somar committed (é apenas referência do valor total dos contratos)
      final totalSpent = totalExpenses + totalPaidFromPayments;
      final totalBudget = project.totalBudget ?? 0.0;
      final remaining = totalBudget - totalSpent;
      final percentageUsed = totalBudget > 0
          ? (totalSpent / totalBudget) * 100
          : 0.0;

      // 6. Criar entity
      final summary = FinancialSummaryEntity(
        totalBudget: totalBudget,
        totalConfirmed:
            totalExpenses, // Expenses confirmados (transações manuais)
        totalCommitted:
            totalCommitted, // Valor total dos contratos (referência)
        totalEstimated: totalEstimates,
        totalSpent: totalSpent, // Expenses + Payments pagos
        remaining: remaining,
        percentageUsed: percentageUsed,
        categorySummaries: {}, // TODO: implementar por categoria se necessário
      );

      return Right(summary);
    } catch (e) {
      return Left(
        ServerFailure('Erro ao calcular resumo financeiro: ${e.toString()}'),
      );
    }
  }
}

// Made with Bob
