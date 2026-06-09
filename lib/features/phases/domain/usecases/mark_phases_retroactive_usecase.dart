import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/phase_repository.dart';

/// Use case para marcar múltiplas fases como concluídas retroativamente
///
/// Usado no onboarding quando o usuário indica que já completou
/// certas fases antes de começar a usar o app
@lazySingleton
class MarkPhasesRetroactiveUseCase {
  final PhaseRepository _repository;

  MarkPhasesRetroactiveUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required List<String> phaseNames,
  }) async {
    return await _repository.markPhasesRetroactive(
      projectId: projectId,
      phaseNames: phaseNames,
    );
  }
}

// Made with Bob
