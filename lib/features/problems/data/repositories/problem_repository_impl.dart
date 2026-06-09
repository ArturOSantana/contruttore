import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../reform_map/domain/entities/problem_entity.dart';
import '../../../reform_map/data/models/problem_model.dart';
import '../../domain/repositories/problem_repository.dart';

@LazySingleton(as: ProblemRepository)
class ProblemRepositoryImpl implements ProblemRepository {
  final FirebaseFirestore _firestore;

  ProblemRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, void>> addProblem(ProblemEntity problem) async {
    try {
      final problemModel = ProblemModel.fromEntity(problem);
      await _firestore
          .collection('projects')
          .doc(problem.projectId)
          .collection('problems')
          .doc(problem.id)
          .set(problemModel.toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao adicionar problema: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProblemEntity>>> getProblems(
    String projectId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('problems')
          .orderBy('createdAt', descending: true)
          .get();

      final problems = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ProblemModel.fromMap(data);
      }).toList();

      return Right(problems);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar problemas: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProblemEntity>>> getProblemsByPhase(
    String projectId,
    String phaseId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('problems')
          .where('phaseId', isEqualTo: phaseId)
          .orderBy('createdAt', descending: true)
          .get();

      final problems = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ProblemModel.fromMap(data);
      }).toList();

      return Right(problems);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar problemas da fase: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProblemEntity>>> getProblemsByStatus(
    String projectId,
    ProblemStatus status,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('problems')
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true)
          .get();

      final problems = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ProblemModel.fromMap(data);
      }).toList();

      return Right(problems);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar problemas por status: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProblemEntity>>> getCriticalProblems(
    String projectId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('problems')
          .where('severity', isEqualTo: ProblemSeverity.critical.name)
          .where('status', isEqualTo: ProblemStatus.open.name)
          .orderBy('createdAt', descending: true)
          .get();

      final problems = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ProblemModel.fromMap(data);
      }).toList();

      return Right(problems);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar problemas críticos: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProblem(ProblemEntity problem) async {
    try {
      final problemModel = ProblemModel.fromEntity(problem);
      await _firestore
          .collection('projects')
          .doc(problem.projectId)
          .collection('problems')
          .doc(problem.id)
          .update(problemModel.toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar problema: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resolveProblem({
    required String problemId,
    required String solution,
  }) async {
    try {
      // Buscar o problema primeiro para pegar o projectId
      final problemDoc = await _firestore
          .collectionGroup('problems')
          .where(FieldPath.documentId, isEqualTo: problemId)
          .limit(1)
          .get();

      if (problemDoc.docs.isEmpty) {
        return Left(ServerFailure('Problema não encontrado'));
      }

      final doc = problemDoc.docs.first;
      await doc.reference.update({
        'status': ProblemStatus.resolved.name,
        'solution': solution,
        'resolvedAt': FieldValue.serverTimestamp(),
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao resolver problema: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProblem(
    String projectId,
    String problemId,
  ) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('problems')
          .doc(problemId)
          .delete();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao deletar problema: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> countOpenProblems(String projectId) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('problems')
          .where('status', isEqualTo: ProblemStatus.open.name)
          .count()
          .get();

      return Right(snapshot.count ?? 0);
    } catch (e) {
      return Left(ServerFailure('Erro ao contar problemas: $e'));
    }
  }
}

// Made with Bob
