import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/documents_repository.dart';

@injectable
class DeleteDocumentUseCase {
  final DocumentsRepository _repository;

  DeleteDocumentUseCase(this._repository);

  Future<Either<Failure, void>> call(String projectId, String documentId) {
    return _repository.deleteDocument(projectId, documentId);
  }
}

// Made with Bob
