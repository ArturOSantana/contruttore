import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/upcoming_expenses_entity.dart';
import '../repositories/reform_map_repository.dart';

/// Use case para calcular despesas futuras previstas
///
/// Calcula as despesas previstas para um período específico (30, 60 ou 90 dias)
/// considerando parcelas pendentes e orçamento disponível.
@lazySingleton
class CalculateUpcomingExpensesUseCase
    implements
        UseCase<UpcomingExpensesEntity, CalculateUpcomingExpensesParams> {
  final ReformMapRepository repository;

  CalculateUpcomingExpensesUseCase(this.repository);

  @override
  Future<Either<Failure, UpcomingExpensesEntity>> call(
    CalculateUpcomingExpensesParams params,
  ) async {
    return await repository.calculateUpcomingExpenses(
      params.projectId,
      params.days,
    );
  }
}

/// Parâmetros para calcular despesas futuras
class CalculateUpcomingExpensesParams {
  final String projectId;
  final int days; // 30, 60 ou 90 dias

  const CalculateUpcomingExpensesParams({
    required this.projectId,
    required this.days,
  });
}

// Made with Bob
