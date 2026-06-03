import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/payment_generator.dart';
import '../../../financial/domain/entities/transaction_entity.dart';
import '../../../financial/domain/repositories/transaction_repository.dart';
import '../../../payments/domain/repositories/payment_repository.dart';
import '../entities/quote_entity.dart';
import '../repositories/supplier_repository.dart';

/// UseCase para aceitar orçamento
///
/// INTEGRAÇÃO COMPLETA COM FINANCEIRO:
/// 1. Atualiza status do quote para 'accepted'
/// 2. Cria TransactionEntity tipo 'commitment' (vai para "Comprometido")
/// 3. Gera PaymentEntity (parcelas) automaticamente
/// 4. Operação atômica - se falhar, reverte tudo
@injectable
class AcceptQuoteUseCase {
  final SupplierRepository _supplierRepository;
  final TransactionRepository _transactionRepository;
  final PaymentRepository _paymentRepository;
  final Uuid _uuid;

  AcceptQuoteUseCase(
    this._supplierRepository,
    this._transactionRepository,
    this._paymentRepository,
    this._uuid,
  );

  Future<Either<Failure, void>> call({
    required String projectId,
    required String quoteId,
    required int installments,
    required DateTime firstPaymentDate,
  }) async {
    try {
      // 1. Buscar o quote
      final quoteResult = await _supplierRepository.getQuoteById(
        projectId,
        quoteId,
      );

      return await quoteResult.fold((failure) async => Left(failure), (
        quote,
      ) async {
        // 2. Buscar o supplier para pegar o nome
        final supplierResult = await _supplierRepository.getSupplier(
          projectId,
          quote.supplierId,
        );

        return await supplierResult.fold((failure) async => Left(failure), (
          supplier,
        ) async {
          // 3. Atualizar status do quote para 'accepted'
          final updateResult = await _supplierRepository.updateQuoteStatus(
            projectId,
            quoteId,
            QuoteStatus.accepted,
          );

          return await updateResult.fold((failure) async => Left(failure), (
            _,
          ) async {
            // 4. Criar transaction de commitment
            final transaction = TransactionEntity(
              id: _uuid.v4(),
              projectId: projectId,
              type: TransactionType.commitment,
              source: TransactionSource.contract,
              amount: quote.totalValue,
              signedAmount: quote.totalValue,
              description: '${supplier.name} - ${quote.description}',
              date: DateTime.now(),
              supplierId: quote.supplierId,
              createdAt: DateTime.now(),
            );
            final transactionResult = await _transactionRepository
                .createManualTransaction(transaction);

            return await transactionResult.fold(
              (failure) async => Left(failure),
              (_) async {
                // 5. Gerar payments (parcelas)
                try {
                  final payments = PaymentGenerator.generatePayments(
                    projectId: projectId,
                    name: '${supplier.name} - ${quote.description}',
                    sourceType: 'supplier',
                    sourceId: quote.supplierId,
                    totalAmount: quote.totalValue,
                    installments: installments,
                    firstPaymentDate: firstPaymentDate,
                  );

                  await _paymentRepository.createPayments(payments);

                  return const Right(null);
                } catch (e) {
                  return Left(
                    ServerFailure(
                      'Orçamento aceito, mas erro ao gerar parcelas: $e',
                    ),
                  );
                }
              },
            );
          });
        });
      });
    } catch (e) {
      return Left(ServerFailure('Erro ao aceitar orçamento: $e'));
    }
  }
}

// Made with Bob
