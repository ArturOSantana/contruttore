import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/notification_service.dart';
import '../../../payments/domain/repositories/payment_repository.dart';
import '../entities/alert_entity.dart';
import '../repositories/alerts_repository.dart';

@injectable
class GenerateAlertsUseCase {
  final AlertsRepository _alertsRepository;
  final FirebaseFirestore _firestore;
  final NotificationService _notificationService;
  final PaymentRepository _paymentRepository;
  final Uuid _uuid;

  GenerateAlertsUseCase(
    this._alertsRepository,
    this._firestore,
    this._notificationService,
    this._paymentRepository,
    this._uuid,
  );

  Future<Either<Failure, void>> call(String projectId) async {
    try {
      final now = DateTime.now();

      // 1. Verificar payments vencidos/vencendo (NOVO SISTEMA)
      await _checkPayments(projectId, now);

      // 2. Verificar documentos expirando
      await _checkDocuments(projectId, now);

      // 3. Verificar inatividade no diário
      await _checkDiaryInactivity(projectId, now);

      // 4. Verificar orçamento estourado
      await _checkBudgetOverrun(projectId);

      // 5. Verificar fases sem progresso
      await _checkPhasesProgress(projectId, now);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao gerar alertas: $e'));
    }
  }

  /// Verifica payments vencidos ou vencendo em breve (NOVO SISTEMA)
  Future<void> _checkPayments(String projectId, DateTime now) async {
    // Buscar todos os payments pendentes do projeto
    final payments = await _paymentRepository.getPendingPayments(projectId);

    for (final payment in payments) {
      final dueDate = payment.dueDate;
      final amount = payment.amount;
      final difference = dueDate.difference(now).inDays;

      // Buscar nome do fornecedor/compra via sourceId
      String sourceName = 'Pagamento';
      if (payment.sourceType == 'supplier') {
        final supplierDoc = await _firestore
            .collection('projects')
            .doc(projectId)
            .collection('suppliers')
            .doc(payment.sourceId)
            .get();
        if (supplierDoc.exists) {
          sourceName = supplierDoc.data()?['name'] ?? 'Fornecedor';
        }
      } else if (payment.sourceType == 'purchase') {
        final purchaseDoc = await _firestore
            .collection('projects')
            .doc(projectId)
            .collection('shopping')
            .doc(payment.sourceId)
            .get();
        if (purchaseDoc.exists) {
          sourceName = purchaseDoc.data()?['name'] ?? 'Compra';
        }
      }

      // Payment vencido
      if (difference < 0) {
        await _createAlertIfNotExists(
          projectId: projectId,
          type: AlertType.critical,
          title: 'Parcela vencida',
          message:
              'A parcela ${payment.installmentNumber}/${payment.totalInstallments} de $sourceName venceu há ${difference.abs()} ${difference.abs() == 1 ? "dia" : "dias"}. Valor: R\$ ${amount.toStringAsFixed(2)}',
          actionRoute: '/home/payments',
        );
      }
      // Payment vence em 3 dias
      else if (difference <= 3 && difference >= 0) {
        await _createAlertIfNotExists(
          projectId: projectId,
          type: AlertType.critical,
          title:
              'Parcela vence em $difference ${difference == 1 ? "dia" : "dias"}',
          message:
              'Lembre-se: parcela ${payment.installmentNumber}/${payment.totalInstallments} de $sourceName vence em breve. Valor: R\$ ${amount.toStringAsFixed(2)}',
          actionRoute: '/home/payments',
        );
      }
      // Payment vence em 7 dias
      else if (difference <= 7 && difference > 3) {
        await _createAlertIfNotExists(
          projectId: projectId,
          type: AlertType.preventive,
          title: 'Parcela vence em $difference dias',
          message:
              'Parcela ${payment.installmentNumber}/${payment.totalInstallments} de $sourceName vence em $difference dias. Valor: R\$ ${amount.toStringAsFixed(2)}',
          actionRoute: '/home/payments',
        );
      }
    }
  }

  /// Verifica documentos expirando
  Future<void> _checkDocuments(String projectId, DateTime now) async {
    final documentsSnapshot = await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('documents')
        .get();

    for (final doc in documentsSnapshot.docs) {
      final data = doc.data();
      final expiryDate = data['expiryDate'];
      if (expiryDate == null) continue;

      final expiry = (expiryDate as Timestamp).toDate();
      final difference = expiry.difference(now).inDays;
      final docName = data['name'] ?? 'Documento';

      // Documento vencido
      if (difference < 0) {
        await _createAlertIfNotExists(
          projectId: projectId,
          type: AlertType.critical,
          title: 'Documento vencido',
          message:
              '$docName venceu há ${difference.abs()} ${difference.abs() == 1 ? "dia" : "dias"}',
          actionRoute: '/home/documents',
        );
      }
      // Documento vence em 7 dias
      else if (difference <= 7 && difference >= 0) {
        await _createAlertIfNotExists(
          projectId: projectId,
          type: AlertType.preventive,
          title: 'Documento vence em breve',
          message:
              '$docName vence em $difference ${difference == 1 ? "dia" : "dias"}',
          actionRoute: '/home/documents',
        );
      }
      // Documento vence em 30 dias
      else if (difference <= 30 && difference > 7) {
        await _createAlertIfNotExists(
          projectId: projectId,
          type: AlertType.info,
          title: 'Documento vence em $difference dias',
          message:
              '$docName vence em $difference dias. Providencie a renovação.',
          actionRoute: '/home/documents',
        );
      }
    }
  }

  /// Verifica inatividade no diário (21 dias sem registro)
  Future<void> _checkDiaryInactivity(String projectId, DateTime now) async {
    final diarySnapshot = await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('diary')
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (diarySnapshot.docs.isEmpty) {
      // Nunca registrou nada
      await _createAlertIfNotExists(
        projectId: projectId,
        type: AlertType.educational,
        title: 'Dica: Registre sua obra',
        message:
            'Registrar fotos e anotações no diário protege você em caso de disputas com fornecedores.',
        actionRoute: '/home/diary',
      );
    } else {
      final lastEntry = diarySnapshot.docs.first.data();
      final lastDate = (lastEntry['date'] as Timestamp).toDate();
      final daysSinceLastEntry = now.difference(lastDate).inDays;

      if (daysSinceLastEntry >= 21) {
        await _createAlertIfNotExists(
          projectId: projectId,
          type: AlertType.preventive,
          title: 'Diário sem atualizações',
          message:
              'Faz $daysSinceLastEntry dias que você não registra nada no diário. Registre o andamento da obra.',
          actionRoute: '/home/diary',
        );
      }
    }
  }

  /// Verifica orçamento estourado por categoria
  Future<void> _checkBudgetOverrun(String projectId) async {
    // Buscar projeto para pegar o orçamento total
    final projectDoc = await _firestore
        .collection('projects')
        .doc(projectId)
        .get();

    if (!projectDoc.exists) return;

    final totalBudget = (projectDoc.data()?['totalBudget'] ?? 0).toDouble();
    if (totalBudget == 0) return;

    // Buscar todas as despesas confirmadas
    final expensesSnapshot = await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('expenses')
        .where('status', isEqualTo: 'confirmed')
        .get();

    // Agrupar por categoria
    final Map<String, double> categoryTotals = {};
    for (final doc in expensesSnapshot.docs) {
      final data = doc.data();
      final categoryId = data['categoryId'] ?? 'outros';
      final amount = (data['amount'] ?? 0).toDouble();
      categoryTotals[categoryId] = (categoryTotals[categoryId] ?? 0) + amount;
    }

    // Calcular total gasto
    final totalSpent = categoryTotals.values.fold(0.0, (a, b) => a + b);
    final percentageSpent = (totalSpent / totalBudget) * 100;

    // Alerta se gastou mais de 90% do orçamento
    if (percentageSpent >= 90) {
      await _createAlertIfNotExists(
        projectId: projectId,
        type: AlertType.critical,
        title: 'Orçamento crítico',
        message:
            'Você já gastou ${percentageSpent.toStringAsFixed(1)}% do orçamento total (R\$ ${totalSpent.toStringAsFixed(2)} de R\$ ${totalBudget.toStringAsFixed(2)})',
        actionRoute: '/home/financial',
      );
    }
    // Alerta se gastou mais de 80% do orçamento
    else if (percentageSpent >= 80) {
      await _createAlertIfNotExists(
        projectId: projectId,
        type: AlertType.preventive,
        title: 'Orçamento próximo do limite',
        message:
            'Você já gastou ${percentageSpent.toStringAsFixed(1)}% do orçamento total. Atenção aos próximos gastos.',
        actionRoute: '/home/financial',
      );
    }
  }

  /// Verifica fases ativas sem progresso há 30 dias
  Future<void> _checkPhasesProgress(String projectId, DateTime now) async {
    final phasesSnapshot = await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('phases')
        .where('status', isEqualTo: 'active')
        .get();

    for (final doc in phasesSnapshot.docs) {
      final data = doc.data();
      final phaseName = data['name'] ?? 'Fase';
      final startDate = data['startDate'];

      if (startDate == null) continue;

      final start = (startDate as Timestamp).toDate();
      final daysSinceStart = now.difference(start).inDays;

      // Verificar se tem alguma subtarefa concluída
      final subtasks = data['subtasks'] as List<dynamic>? ?? [];
      final hasCompletedSubtasks = subtasks.any((s) => s['isDone'] == true);

      // Se fase ativa há mais de 30 dias sem nenhuma subtarefa concluída
      if (daysSinceStart >= 30 && !hasCompletedSubtasks) {
        await _createAlertIfNotExists(
          projectId: projectId,
          type: AlertType.preventive,
          title: 'Fase sem progresso',
          message:
              '$phaseName está ativa há $daysSinceStart dias sem progresso. Verifique o andamento.',
          actionRoute: '/home/phases',
        );
      }
    }
  }

  Future<void> _createAlertIfNotExists({
    required String projectId,
    required AlertType type,
    required String title,
    required String message,
    String? actionRoute,
  }) async {
    // Verificar se alerta já existe
    final existsResult = await _alertsRepository.alertExists(projectId, title);

    existsResult.fold((failure) => null, (exists) async {
      if (!exists) {
        final alert = AlertEntity(
          id: _uuid.v4(),
          projectId: projectId,
          type: type,
          title: title,
          message: message,
          isRead: false,
          actionRoute: actionRoute,
          createdAt: DateTime.now(),
        );

        await _alertsRepository.addAlert(alert);

        // Enviar push notification para alertas críticos
        if (type == AlertType.critical) {
          await _sendPushNotification(title, message, actionRoute);
        }
      }
    });
  }

  /// Envia push notification para alertas críticos
  Future<void> _sendPushNotification(
    String title,
    String message,
    String? actionRoute,
  ) async {
    try {
      await _notificationService.showNotification(
        title: '🔴 $title',
        body: message,
        payload: actionRoute,
      );
      print('✅ Push notification enviada: $title');
    } catch (e) {
      print('❌ Erro ao enviar push notification: $e');
    }
  }
}

// Made with Bob
