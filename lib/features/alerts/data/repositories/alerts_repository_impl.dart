import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../models/alert_model.dart';

@LazySingleton(as: AlertsRepository)
class AlertsRepositoryImpl implements AlertsRepository {
  final FirebaseFirestore _firestore;

  AlertsRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, List<AlertEntity>>> getAlerts(String projectId) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('alerts')
          .orderBy('createdAt', descending: true)
          .get();

      final alerts = snapshot.docs
          .map((doc) => AlertModel.fromMap(doc.data(), doc.id))
          .where((alert) => !alert.isSnoozed) // Filtrar alertas em soneca
          .toList();

      return Right(alerts);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar alertas: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addAlert(AlertEntity alert) async {
    try {
      await _firestore
          .collection('projects')
          .doc(alert.projectId)
          .collection('alerts')
          .doc(alert.id)
          .set((alert as AlertModel).toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao adicionar alerta: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(
    String projectId,
    String alertId,
  ) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('alerts')
          .doc(alertId)
          .update({'isRead': true});

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao marcar alerta como lido: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> snoozeAlert(
    String projectId,
    String alertId,
  ) async {
    try {
      final snoozeUntil = DateTime.now().add(const Duration(days: 3));

      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('alerts')
          .doc(alertId)
          .update({'snoozeUntil': Timestamp.fromDate(snoozeUntil)});

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao adiar alerta: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAlert(
    String projectId,
    String alertId,
  ) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('alerts')
          .doc(alertId)
          .delete();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao deletar alerta: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount(String projectId) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('alerts')
          .where('isRead', isEqualTo: false)
          .get();

      return Right(snapshot.docs.length);
    } catch (e) {
      return Left(ServerFailure('Erro ao contar alertas não lidos: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> alertExists(
    String projectId,
    String title,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('alerts')
          .where('title', isEqualTo: title)
          .limit(1)
          .get();

      return Right(snapshot.docs.isNotEmpty);
    } catch (e) {
      return Left(ServerFailure('Erro ao verificar existência de alerta: $e'));
    }
  }
}

// Made with Bob
