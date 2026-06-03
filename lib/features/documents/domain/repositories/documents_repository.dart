import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/document_entity.dart';

abstract class DocumentsRepository {
  Future<Either<Failure, List<DocumentEntity>>> getDocuments(String projectId);
  Future<Either<Failure, void>> addDocument(DocumentEntity document);
  Future<Either<Failure, void>> updateDocument(DocumentEntity document);
  Future<Either<Failure, void>> deleteDocument(
    String projectId,
    String documentId,
  );
  Future<Either<Failure, String>> uploadFile(String projectId, String filePath);
  Future<Either<Failure, List<DocumentEntity>>> getExpiringDocuments(
    String projectId,
  );
}

// Made with Bob
