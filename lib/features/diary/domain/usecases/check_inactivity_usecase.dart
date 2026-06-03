import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/diary_repository.dart';

@injectable
class CheckInactivityUseCase {
  final DiaryRepository _repository;

  CheckInactivityUseCase(this._repository);

  Future<Either<Failure, bool>> call(String projectId) async {
    final result = await _repository.getLastEntryDate(projectId);

    return result.fold((failure) => Left(failure), (lastDate) {
      if (lastDate == null) return const Right(true);

      final daysSinceLastEntry = DateTime.now().difference(lastDate).inDays;
      return Right(daysSinceLastEntry >= 21);
    });
  }
}

// Made with Bob
