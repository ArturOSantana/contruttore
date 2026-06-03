import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/document_entity.dart';
import '../repositories/documents_repository.dart';

@injectable
class GetDocumentsUseCase {
  final DocumentsRepository _repository;

  GetDocumentsUseCase(this._repository);

  Future<Either<Failure, List<DocumentEntity>>> call(String projectId) {
    return _repository.getDocuments(projectId);
  }
}

// Made with Bob
