import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/documents_repository.dart';

@injectable
class UploadFileUseCase {
  final DocumentsRepository _repository;

  UploadFileUseCase(this._repository);

  Future<Either<Failure, String>> call(String projectId, String filePath) {
    return _repository.uploadFile(projectId, filePath);
  }
}

// Made with Bob
