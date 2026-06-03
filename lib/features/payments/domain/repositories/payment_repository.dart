import '../entities/payment_entity.dart';

/// Interface do repositório de Payments
/// Payments são gerados automaticamente por Suppliers e Purchases
abstract class PaymentRepository {
  /// Busca todos os payments de um projeto
  Future<List<PaymentEntity>> getPayments(String projectId);

  /// Busca payments por sourceId (supplierId ou purchaseId)
  Future<List<PaymentEntity>> getPaymentsBySource({
    required String projectId,
    required String sourceId,
  });

  /// Busca payments pendentes (não pagos)
  Future<List<PaymentEntity>> getPendingPayments(String projectId);

  /// Busca payments que vencem em breve (próximos 3 dias)
  Future<List<PaymentEntity>> getUpcomingPayments(String projectId);

  /// Busca payments vencidos
  Future<List<PaymentEntity>> getOverduePayments(String projectId);

  /// Busca payments do mês atual
  Future<List<PaymentEntity>> getPaymentsThisMonth(String projectId);

  /// Cria um payment
  Future<String> createPayment(PaymentEntity payment);

  /// Cria múltiplos payments (usado ao criar supplier/purchase parcelado)
  Future<void> createPayments(List<PaymentEntity> payments);

  /// Marca payment como pago
  Future<void> markAsPaid({
    required String projectId,
    required String paymentId,
    required DateTime paidAt,
  });

  /// Cancela payments pendentes de uma source (usado ao deletar supplier)
  Future<void> cancelPendingPaymentsBySource({
    required String projectId,
    required String sourceId,
  });

  /// Deleta um payment específico
  Future<void> deletePayment(String paymentId);

  /// Stream de payments (para atualização em tempo real)
  Stream<List<PaymentEntity>> watchPayments(String projectId);

  /// Stream de payments pendentes
  Stream<List<PaymentEntity>> watchPendingPayments(String projectId);
}

// Made with Bob
