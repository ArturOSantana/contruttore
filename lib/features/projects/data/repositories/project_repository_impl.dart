import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../models/project_model.dart';

@LazySingleton(as: ProjectRepository)
class ProjectRepositoryImpl implements ProjectRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProjectRepositoryImpl(this._firestore, this._auth);

  @override
  Future<Either<Failure, ProjectEntity>> createProject(
    ProjectEntity project,
  ) async {
    try {
      final projectModel = ProjectModel.fromEntity(project);

      await _firestore
          .collection('projects')
          .doc(project.id)
          .set(projectModel.toMap());

      // Atualizar currentProjectId no usuário
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'currentProjectId': project.id,
        });
      }

      return Right(projectModel);
    } catch (e) {
      return Left(ServerFailure('Erro ao criar projeto: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProjectEntity>>> getProjects(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final projects = snapshot.docs
          .map((doc) => ProjectModel.fromMap(doc.data()))
          .toList();

      return Right(projects);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar projetos: $e'));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> getProject(String projectId) async {
    try {
      final doc = await _firestore.collection('projects').doc(projectId).get();

      if (!doc.exists) {
        return Left(ServerFailure('Projeto não encontrado'));
      }

      final project = ProjectModel.fromMap(doc.data()!);
      return Right(project);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar projeto: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProject(ProjectEntity project) async {
    try {
      final projectModel = ProjectModel.fromEntity(project);

      await _firestore
          .collection('projects')
          .doc(project.id)
          .update(projectModel.toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar projeto: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(String projectId) async {
    try {
      // Buscar o projeto para obter o userId
      final projectDoc = await _firestore
          .collection('projects')
          .doc(projectId)
          .get();

      if (!projectDoc.exists) {
        return Left(ServerFailure('Projeto não encontrado'));
      }

      final userId = projectDoc.data()?['userId'] as String?;

      // Deletar o projeto
      await _firestore.collection('projects').doc(projectId).delete();

      // Se este era o projeto atual do usuário, limpar o currentProjectId
      if (userId != null) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final currentProjectId = userDoc.data()?['currentProjectId'] as String?;

        if (currentProjectId == projectId) {
          await _firestore.collection('users').doc(userId).update({
            'currentProjectId': null,
          });
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao deletar projeto: $e'));
    }
  }
}

// Made with Bob
