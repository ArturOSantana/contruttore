import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/diary_entry_entity.dart';
import '../repositories/diary_repository.dart';

@injectable
class GetDiaryEntriesUseCase {
  final DiaryRepository _repository;

  GetDiaryEntriesUseCase(this._repository);

  Future<Either<Failure, List<DiaryEntryEntity>>> call(String projectId) {
    return _repository.getDiaryEntries(projectId);
  }
}

// Made with Bob
