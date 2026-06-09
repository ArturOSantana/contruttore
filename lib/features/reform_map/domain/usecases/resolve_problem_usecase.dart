import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/reform_map_repository.dart';

/// Use case para resolver um problema da reforma
///
/// Marca um problema como resolvido, registrando a solução aplicada
/// e a data de resolução. Isso atualiza automaticamente a saúde da reforma.
@lazySingleton
class ResolveProblemUseCase implements UseCase<void, ResolveProblemParams> {
  final ReformMapRepository repository;

  ResolveProblemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ResolveProblemParams params) async {
    return await repository.resolveProblem(
      params.problemId,
      params.solution,
    );
  }
}

/// Parâmetros para resolver um problema
class ResolveProblemParams {
  final String problemId;
  final String solution;

  const ResolveProblemParams({
    required this.problemId,
    required this.solution,
  });
}

// Made with Bob
