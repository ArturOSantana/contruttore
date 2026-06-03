import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/diary_entry_entity.dart';
import '../repositories/diary_repository.dart';

@injectable
class AddDiaryEntryUseCase {
  final DiaryRepository _repository;

  AddDiaryEntryUseCase(this._repository);

  Future<Either<Failure, void>> call(DiaryEntryEntity entry) {
    return _repository.addDiaryEntry(entry);
  }
}

// Made with Bob
