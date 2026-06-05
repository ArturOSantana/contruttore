import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reform_health_entity.dart';
import '../repositories/reform_map_repository.dart';

/// Use case para calcular a saúde da reforma
///
/// Calcula um score de 0 a 100 que mostra como está a reforma:
/// - 90-100: Excelente! Tudo nos trilhos
/// - 70-89: Boa! Alguns pontos de atenção
/// - 50-69: Atenção! Precisa de ajustes
/// - 0-49: Crítico! Ação urgente necessária
///
/// O cálculo considera:
/// - Está no prazo? (25%)
/// - Está no orçamento? (30%)
/// - Tem problemas? (20%)
/// - Tem pendências? (15%)
/// - Pagamentos em dia? (10%)
@injectable
class CalculateHealthUseCase implements UseCase<ReformHealthEntity, String> {
  final ReformMapRepository repository;

  CalculateHealthUseCase(this.repository);

  @override
  Future<Either<Failure, ReformHealthEntity>> call(String projectId) async {
    return await repository.calculateHealth(projectId);
  }
}

// Made with Bob
