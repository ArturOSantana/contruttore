import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/payment_model.dart';

@LazySingleton(as: PaymentRepository)
class PaymentRepositoryImpl implements PaymentRepository {
  final FirebaseFirestore _firestore;

  PaymentRepositoryImpl(this._firestore);

  CollectionReference _paymentsCollection(String projectId) {
    return _firestore
        .collection('projects')
        .doc(projectId)
        .collection('payments');
  }

  @override
  Future<List<PaymentEntity>> getPayments(String projectId) async {
    try {
      final snapshot = await _paymentsCollection(
        projectId,
      ).orderBy('dueDate', descending: false).get();

      return snapshot.docs
          .map(
            (doc) => PaymentModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw ServerException('Erro ao buscar payments: $e');
    }
  }

  @override
  Future<List<PaymentEntity>> getPaymentsBySource({
    required String projectId,
    required String sourceId,
  }) async {
    try {
      final snapshot = await _paymentsCollection(projectId)
          .where('sourceId', isEqualTo: sourceId)
          .orderBy('installmentNumber')
          .get();

      return snapshot.docs
          .map(
            (doc) => PaymentModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw ServerException('Erro ao buscar payments por source: $e');
    }
  }

  @override
  Future<List<PaymentEntity>> getPendingPayments(String projectId) async {
    try {
      final snapshot = await _paymentsCollection(
        projectId,
      ).where('paid', isEqualTo: false).orderBy('dueDate').get();

      return snapshot.docs
          .map(
            (doc) => PaymentModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw ServerException('Erro ao buscar payments pendentes: $e');
    }
  }

  @override
  Future<List<PaymentEntity>> getUpcomingPayments(String projectId) async {
    try {
      final now = DateTime.now();
      final threeDaysFromNow = now.add(const Duration(days: 3));

      final snapshot = await _paymentsCollection(projectId)
          .where('paid', isEqualTo: false)
          .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where(
            'dueDate',
            isLessThanOrEqualTo: Timestamp.fromDate(threeDaysFromNow),
          )
          .orderBy('dueDate')
          .get();

      return snapshot.docs
          .map(
            (doc) => PaymentModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw ServerException('Erro ao buscar payments próximos: $e');
    }
  }

  @override
  Future<List<PaymentEntity>> getOverduePayments(String projectId) async {
    try {
      final now = DateTime.now();

      final snapshot = await _paymentsCollection(projectId)
          .where('paid', isEqualTo: false)
          .where('dueDate', isLessThan: Timestamp.fromDate(now))
          .orderBy('dueDate')
          .get();

      return snapshot.docs
          .map(
            (doc) => PaymentModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw ServerException('Erro ao buscar payments vencidos: $e');
    }
  }

  @override
  Future<List<PaymentEntity>> getPaymentsThisMonth(String projectId) async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final snapshot = await _paymentsCollection(projectId)
          .where(
            'dueDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth),
          )
          .where(
            'dueDate',
            isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth),
          )
          .orderBy('dueDate')
          .get();

      return snapshot.docs
          .map(
            (doc) => PaymentModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw ServerException('Erro ao buscar payments do mês: $e');
    }
  }

  @override
  Future<String> createPayment(PaymentEntity payment) async {
    try {
      final model = PaymentModel.fromEntity(payment);
      final docRef = await _paymentsCollection(
        payment.projectId,
      ).add(model.toMap());
      return docRef.id;
    } catch (e) {
      throw ServerException('Erro ao criar payment: $e');
    }
  }

  @override
  Future<void> createPayments(List<PaymentEntity> payments) async {
    if (payments.isEmpty) return;

    try {
      final batch = _firestore.batch();
      final projectId = payments.first.projectId;

      for (final payment in payments) {
        final model = PaymentModel.fromEntity(payment);
        final docRef = _paymentsCollection(projectId).doc();
        batch.set(docRef, model.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw ServerException('Erro ao criar payments em lote: $e');
    }
  }

  @override
  Future<void> markAsPaid({
    required String projectId,
    required String paymentId,
    required DateTime paidAt,
  }) async {
    try {
      // Usar a coleção específica do projeto
      await _paymentsCollection(projectId).doc(paymentId).update({
        'paid': true,
        'paidAt': Timestamp.fromDate(paidAt),
      });
    } catch (e) {
      throw ServerException('Erro ao marcar payment como pago: $e');
    }
  }

  @override
  Future<void> cancelPendingPaymentsBySource({
    required String projectId,
    required String sourceId,
  }) async {
    try {
      final snapshot = await _paymentsCollection(projectId)
          .where('sourceId', isEqualTo: sourceId)
          .where('paid', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw ServerException('Erro ao cancelar payments pendentes: $e');
    }
  }

  @override
  Future<void> deletePayment(String paymentId) async {
    try {
      // Busca o payment para pegar a referência correta
      final doc = await _firestore
          .collectionGroup('payments')
          .where(FieldPath.documentId, isEqualTo: paymentId)
          .limit(1)
          .get();

      if (doc.docs.isEmpty) {
        throw ServerException('Payment não encontrado');
      }

      await doc.docs.first.reference.delete();
    } catch (e) {
      throw ServerException('Erro ao deletar payment: $e');
    }
  }

  @override
  Stream<List<PaymentEntity>> watchPayments(String projectId) {
    try {
      return _paymentsCollection(projectId)
          .orderBy('dueDate')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map(
                  (doc) => PaymentModel.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  ),
                )
                .toList(),
          );
    } catch (e) {
      throw ServerException('Erro ao observar payments: $e');
    }
  }

  @override
  Stream<List<PaymentEntity>> watchPendingPayments(String projectId) {
    try {
      return _paymentsCollection(projectId)
          .where('paid', isEqualTo: false)
          .orderBy('dueDate')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map(
                  (doc) => PaymentModel.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  ),
                )
                .toList(),
          );
    } catch (e) {
      throw ServerException('Erro ao observar payments pendentes: $e');
    }
  }
}

// Made with Bob
