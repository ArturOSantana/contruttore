import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/diary_repository.dart';

@injectable
class UploadPhotoUseCase {
  final DiaryRepository _repository;

  UploadPhotoUseCase(this._repository);

  Future<Either<Failure, String>> call(String projectId, String filePath) {
    return _repository.uploadPhoto(projectId, filePath);
  }
}

// Made with Bob
