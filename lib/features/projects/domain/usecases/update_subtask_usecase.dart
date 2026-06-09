import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/phase_entity.dart';
import '../repositories/phase_repository.dart';

@injectable
class UpdateSubtaskUsecase implements UseCase<void, UpdateSubtaskParams> {
  final PhaseRepository _repository;

  UpdateSubtaskUsecase(this._repository);

  @override
  Future<Either<Failure, void>> call(UpdateSubtaskParams params) async {
    return await _repository.updateSubtask(params.phaseId, params.subtask);
  }
}

class UpdateSubtaskParams extends Equatable {
  final String phaseId;
  final SubtaskEntity subtask;

  const UpdateSubtaskParams({
    required this.phaseId,
    required this.subtask,
  });

  @override
  List<Object?> get props => [phaseId, subtask];
}

// Made with Bob
