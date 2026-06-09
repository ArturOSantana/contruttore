import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/diary_entry_entity.dart';
import '../repositories/diary_repository.dart';

@lazySingleton
class AddAutomaticEntryUseCase {
  final DiaryRepository repository;

  AddAutomaticEntryUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required String title,
    required String description,
    String? phaseId,
    DiaryEntryType type = DiaryEntryType.daily,
  }) async {
    return await repository.addAutomaticEntry(
      projectId: projectId,
      title: title,
      description: description,
      phaseId: phaseId,
      type: type,
    );
  }
}

// Made with Bob
