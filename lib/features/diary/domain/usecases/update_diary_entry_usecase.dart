import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/diary_entry_entity.dart';
import '../repositories/diary_repository.dart';

@injectable
class UpdateDiaryEntryUseCase implements UseCase<void, DiaryEntryEntity> {
  final DiaryRepository repository;

  UpdateDiaryEntryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DiaryEntryEntity entry) async {
    return await repository.updateDiaryEntry(entry);
  }
}

// Made with Bob
