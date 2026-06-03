import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/document_entity.dart';
import '../repositories/documents_repository.dart';

@injectable
class GetExpiringDocumentsUseCase {
  final DocumentsRepository _repository;

  GetExpiringDocumentsUseCase(this._repository);

  Future<Either<Failure, List<DocumentEntity>>> call(String projectId) {
    return _repository.getExpiringDocuments(projectId);
  }
}

// Made with Bob
