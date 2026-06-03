import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/installment_entity.dart';
import '../../domain/repositories/installment_repository.dart';
import '../models/installment_model.dart';

@LazySingleton(as: InstallmentRepository)
class InstallmentRepositoryImpl implements InstallmentRepository {
  final FirebaseFirestore _firestore;

  InstallmentRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, List<InstallmentEntity>>> getInstallments(
    String projectId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('installments')
          .orderBy('createdAt', descending: true)
          .get();

      final installments = snapshot.docs
          .map((doc) => InstallmentModel.fromMap(doc.data(), doc.id))
          .toList();

      return Right(installments);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar parcelas: $e'));
    }
  }

  @override
  Future<Either<Failure, InstallmentEntity>> getInstallment(
    String projectId,
    String installmentId,
  ) async {
    try {
      final doc = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('installments')
          .doc(installmentId)
          .get();

      if (!doc.exists) {
        return Left(ServerFailure('Contrato não encontrado'));
      }

      return Right(InstallmentModel.fromMap(doc.data()!, doc.id));
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar contrato: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addInstallment(
    InstallmentEntity installment,
  ) async {
    try {
      await _firestore
          .collection('projects')
          .doc(installment.projectId)
          .collection('installments')
          .doc(installment.id)
          .set((installment as InstallmentModel).toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao adicionar contrato: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateInstallment(
    InstallmentEntity installment,
  ) async {
    try {
      await _firestore
          .collection('projects')
          .doc(installment.projectId)
          .collection('installments')
          .doc(installment.id)
          .update((installment as InstallmentModel).toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar contrato: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteInstallment(
    String projectId,
    String installmentId,
  ) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('installments')
          .doc(installmentId)
          .delete();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao deletar contrato: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markPaymentAsPaid({
    required String projectId,
    required String installmentId,
    required String paymentId,
    required double paidAmount,
    required DateTime paidAt,
  }) async {
    try {
      final doc = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('installments')
          .doc(installmentId)
          .get();

      if (!doc.exists) {
        return Left(ServerFailure('Contrato não encontrado'));
      }

      final installment = InstallmentModel.fromMap(doc.data()!, doc.id);
      final updatedPayments = installment.payments.map((payment) {
        if (payment.id == paymentId) {
          return PaymentModel(
            id: payment.id,
            number: payment.number,
            amount: payment.amount,
            dueDate: payment.dueDate,
            isPaid: true,
            paidAt: paidAt,
            paidAmount: paidAmount,
          );
        }
        return payment;
      }).toList();

      // Atualizar status do contrato
      final allPaid = updatedPayments.every((p) => p.isPaid);
      final hasOverdue = updatedPayments.any(
        (p) => !p.isPaid && p.dueDate.isBefore(DateTime.now()),
      );

      InstallmentStatus newStatus;
      if (allPaid) {
        newStatus = InstallmentStatus.completed;
      } else if (hasOverdue) {
        newStatus = InstallmentStatus.overdue;
      } else {
        newStatus = InstallmentStatus.active;
      }

      final updatedInstallment = InstallmentModel(
        id: installment.id,
        projectId: installment.projectId,
        supplierId: installment.supplierId,
        supplierName: installment.supplierName,
        serviceDescription: installment.serviceDescription,
        phaseId: installment.phaseId,
        totalValue: installment.totalValue,
        totalInstallments: installment.totalInstallments,
        contractDate: installment.contractDate,
        status: newStatus,
        payments: updatedPayments,
        createdAt: installment.createdAt,
      );

      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('installments')
          .doc(installmentId)
          .update(updatedInstallment.toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao marcar parcela como paga: $e'));
    }
  }
}

// Made with Bob
