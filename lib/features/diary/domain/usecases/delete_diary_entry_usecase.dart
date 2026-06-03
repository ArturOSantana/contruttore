import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/diary_repository.dart';

@injectable
class DeleteDiaryEntryUseCase implements UseCase<void, DeleteDiaryEntryParams> {
  final DiaryRepository repository;

  DeleteDiaryEntryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteDiaryEntryParams params) async {
    return await repository.deleteDiaryEntry(params.projectId, params.entryId);
  }
}

class DeleteDiaryEntryParams {
  final String projectId;
  final String entryId;

  DeleteDiaryEntryParams({required this.projectId, required this.entryId});
}
