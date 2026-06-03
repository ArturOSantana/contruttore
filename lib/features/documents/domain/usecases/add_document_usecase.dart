import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/document_entity.dart';
import '../repositories/documents_repository.dart';

@injectable
class AddDocumentUseCase {
  final DocumentsRepository _repository;

  AddDocumentUseCase(this._repository);

  Future<Either<Failure, void>> call(DocumentEntity document) {
    return _repository.addDocument(document);
  }
}

// Made with Bob
