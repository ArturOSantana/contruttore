import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/diary_entry_entity.dart';
import '../../domain/repositories/diary_repository.dart';
import '../models/diary_entry_model.dart';

@LazySingleton(as: DiaryRepository)
class DiaryRepositoryImpl implements DiaryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  DiaryRepositoryImpl(this._firestore, this._storage);

  @override
  Future<Either<Failure, List<DiaryEntryEntity>>> getDiaryEntries(
    String projectId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('diary')
          .orderBy('date', descending: true)
          .get();

      final entries = snapshot.docs
          .map((doc) => DiaryEntryModel.fromMap(doc.data(), doc.id))
          .toList();

      return Right(entries);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar entradas: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addDiaryEntry(DiaryEntryEntity entry) async {
    try {
      await _firestore
          .collection('projects')
          .doc(entry.projectId)
          .collection('diary')
          .doc(entry.id)
          .set((entry as DiaryEntryModel).toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao adicionar entrada: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateDiaryEntry(DiaryEntryEntity entry) async {
    try {
      await _firestore
          .collection('projects')
          .doc(entry.projectId)
          .collection('diary')
          .doc(entry.id)
          .update((entry as DiaryEntryModel).toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar entrada: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDiaryEntry(
    String projectId,
    String entryId,
  ) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('diary')
          .doc(entryId)
          .delete();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao deletar entrada: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadPhoto(
    String projectId,
    String filePath,
  ) async {
    try {
      final file = File(filePath);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('projects/$projectId/diary/$fileName');

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      return Right(url);
    } catch (e) {
      return Left(ServerFailure('Erro ao fazer upload da foto: $e'));
    }
  }

  @override
  Future<Either<Failure, DateTime?>> getLastEntryDate(String projectId) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('diary')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return const Right(null);
      }

      final lastEntry = DiaryEntryModel.fromMap(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );

      return Right(lastEntry.date);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar última entrada: $e'));
    }
  }
}

// Made with Bob
