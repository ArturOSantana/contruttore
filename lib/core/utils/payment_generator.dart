import 'package:uuid/uuid.dart';

import '../../features/payments/domain/entities/payment_entity.dart';

/// Helper para gerar payments automaticamente
/// Usado por Suppliers e Shopping quando há parcelamento
class PaymentGenerator {
  static const _uuid = Uuid();

  /// Gera lista de payments para um supplier ou purchase
  ///
  /// [projectId] - ID do projeto
  /// [name] - Nome da parcela (ex: "Marcenaria da cozinha")
  /// [sourceType] - 'supplier' ou 'purchase'
  /// [sourceId] - ID do supplier ou purchase
  /// [totalAmount] - Valor total a ser parcelado
  /// [installments] - Número de parcelas
  /// [firstPaymentDate] - Data da primeira parcela
  ///
  /// Retorna lista de PaymentEntity com datas calculadas mensalmente
  static List<PaymentEntity> generatePayments({
    required String projectId,
    required String name,
    required String sourceType,
    required String sourceId,
    required double totalAmount,
    required int installments,
    required DateTime firstPaymentDate,
  }) {
    if (installments <= 0) {
      throw ArgumentError('Número de parcelas deve ser maior que zero');
    }

    if (totalAmount <= 0) {
      throw ArgumentError('Valor total deve ser maior que zero');
    }

    final payments = <PaymentEntity>[];
    final installmentAmount = totalAmount / installments;

    for (int i = 0; i < installments; i++) {
      // Calcula a data de vencimento (mensal)
      final dueDate = DateTime(
        firstPaymentDate.year,
        firstPaymentDate.month + i,
        firstPaymentDate.day,
      );

      payments.add(
        PaymentEntity(
          id: _uuid.v4(),
          projectId: projectId,
          name: name,
          sourceType: sourceType,
          sourceId: sourceId,
          installmentNumber: i + 1,
          totalInstallments: installments,
          amount: installmentAmount,
          dueDate: dueDate,
          paid: false,
          paidAt: null,
          createdAt: DateTime.now(),
        ),
      );
    }

    return payments;
  }

  /// Gera um único payment (pagamento à vista)
  ///
  /// Útil quando installments = 1
  static PaymentEntity generateSinglePayment({
    required String projectId,
    required String name,
    required String sourceType,
    required String sourceId,
    required double amount,
    required DateTime dueDate,
  }) {
    return PaymentEntity(
      id: _uuid.v4(),
      projectId: projectId,
      name: name,
      sourceType: sourceType,
      sourceId: sourceId,
      installmentNumber: 1,
      totalInstallments: 1,
      amount: amount,
      dueDate: dueDate,
      paid: false,
      paidAt: null,
      createdAt: DateTime.now(),
    );
  }

  /// Calcula o valor de cada parcela
  ///
  /// Útil para exibir na UI antes de criar
  static double calculateInstallmentAmount({
    required double totalAmount,
    required int installments,
  }) {
    if (installments <= 0) return 0;
    return totalAmount / installments;
  }

  /// Calcula todas as datas de vencimento
  ///
  /// Útil para exibir na UI antes de criar
  static List<DateTime> calculateDueDates({
    required DateTime firstPaymentDate,
    required int installments,
  }) {
    final dates = <DateTime>[];

    for (int i = 0; i < installments; i++) {
      final dueDate = DateTime(
        firstPaymentDate.year,
        firstPaymentDate.month + i,
        firstPaymentDate.day,
      );
      dates.add(dueDate);
    }

    return dates;
  }

  /// Valida se os parâmetros para gerar payments são válidos
  ///
  /// Retorna mensagem de erro ou null se válido
  static String? validatePaymentParams({
    required double totalAmount,
    required int installments,
    required DateTime firstPaymentDate,
  }) {
    if (totalAmount <= 0) {
      return 'Valor total deve ser maior que zero';
    }

    if (installments <= 0) {
      return 'Número de parcelas deve ser maior que zero';
    }

    if (installments > 120) {
      return 'Número máximo de parcelas é 120 (10 anos)';
    }

    final now = DateTime.now();
    final minDate = DateTime(now.year - 1, now.month, now.day);

    if (firstPaymentDate.isBefore(minDate)) {
      return 'Data da primeira parcela não pode ser há mais de 1 ano';
    }

    return null;
  }
}

// Made with Bob
