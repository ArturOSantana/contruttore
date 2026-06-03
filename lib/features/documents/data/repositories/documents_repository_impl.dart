import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/documents_repository.dart';
import '../models/document_model.dart';

@LazySingleton(as: DocumentsRepository)
class DocumentsRepositoryImpl implements DocumentsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  DocumentsRepositoryImpl(this._firestore, this._storage);

  @override
  Future<Either<Failure, List<DocumentEntity>>> getDocuments(
    String projectId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('documents')
          .orderBy('createdAt', descending: true)
          .get();

      final documents = snapshot.docs
          .map((doc) => DocumentModel.fromMap(doc.data(), doc.id))
          .toList();

      return Right(documents);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar documentos: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addDocument(DocumentEntity document) async {
    try {
      await _firestore
          .collection('projects')
          .doc(document.projectId)
          .collection('documents')
          .doc(document.id)
          .set((document as DocumentModel).toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao adicionar documento: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateDocument(DocumentEntity document) async {
    try {
      await _firestore
          .collection('projects')
          .doc(document.projectId)
          .collection('documents')
          .doc(document.id)
          .update((document as DocumentModel).toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar documento: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument(
    String projectId,
    String documentId,
  ) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('documents')
          .doc(documentId)
          .delete();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao deletar documento: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadFile(
    String projectId,
    String filePath,
  ) async {
    try {
      final file = File(filePath);
      final extension = filePath.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
      final ref = _storage.ref().child(
        'projects/$projectId/documents/$fileName',
      );

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      return Right(url);
    } catch (e) {
      return Left(ServerFailure('Erro ao fazer upload do arquivo: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DocumentEntity>>> getExpiringDocuments(
    String projectId,
  ) async {
    try {
      final now = DateTime.now();
      final thirtyDaysFromNow = now.add(const Duration(days: 30));

      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('documents')
          .where('expiryDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where(
            'expiryDate',
            isLessThanOrEqualTo: Timestamp.fromDate(thirtyDaysFromNow),
          )
          .get();

      final documents = snapshot.docs
          .map((doc) => DocumentModel.fromMap(doc.data(), doc.id))
          .toList();

      return Right(documents);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar documentos vencendo: $e'));
    }
  }
}

// Made with Bob
