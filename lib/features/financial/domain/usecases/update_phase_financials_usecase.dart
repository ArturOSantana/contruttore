import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/financial_repository.dart';

@lazySingleton
class UpdatePhaseFinancialsUseCase {
  final FinancialRepository repository;

  UpdatePhaseFinancialsUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required String phaseId,
  }) async {
    return await repository.updatePhaseFinancials(
      projectId: projectId,
      phaseId: phaseId,
    );
  }
}

// Made with Bob
