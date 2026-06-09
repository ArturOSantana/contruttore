import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/diary_entry_entity.dart';

abstract class DiaryRepository {
  Future<Either<Failure, List<DiaryEntryEntity>>> getDiaryEntries(
    String projectId,
  );
  Future<Either<Failure, void>> addDiaryEntry(DiaryEntryEntity entry);
  Future<Either<Failure, void>> updateDiaryEntry(DiaryEntryEntity entry);
  Future<Either<Failure, void>> deleteDiaryEntry(
    String projectId,
    String entryId,
  );
  Future<Either<Failure, String>> uploadPhoto(
    String projectId,
    String filePath,
  );
  Future<Either<Failure, DateTime?>> getLastEntryDate(String projectId);

  /// Adiciona uma entrada automática no diário
  Future<Either<Failure, void>> addAutomaticEntry({
    required String projectId,
    required String title,
    required String description,
    String? phaseId,
    DiaryEntryType type = DiaryEntryType.daily,
  });
}

// Made with Bob
