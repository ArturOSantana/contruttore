import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/sinapi_service.dart';
import '../entities/quote_entity.dart';
import '../entities/supplier_entity.dart';
import '../repositories/supplier_repository.dart';

@injectable
class CompareQuotesUseCase {
  final SupplierRepository _repository;
  final SinapiService _sinapiService;

  CompareQuotesUseCase(this._repository, this._sinapiService);

  Future<Either<Failure, QuoteComparison>> call(
    String projectId,
    List<String> quoteIds,
  ) async {
    if (quoteIds.length < 2) {
      return Left(ValidationFailure('Mínimo 2 orçamentos para comparar'));
    }

    if (quoteIds.length > 4) {
      return Left(ValidationFailure('Máximo 4 orçamentos para comparar'));
    }

    // Buscar todos os orçamentos
    final quotesWithSuppliers = <QuoteWithSupplier>[];
    for (final id in quoteIds) {
      final quoteResult = await _repository.getQuoteById(projectId, id);

      await quoteResult.fold((failure) async => null, (quote) async {
        // Buscar fornecedor
        final supplierResult = await _repository.getSupplier(
          projectId,
          quote.supplierId,
        );

        supplierResult.fold((failure) => null, (supplier) {
          quotesWithSuppliers.add(
            QuoteWithSupplier(quote: quote, supplier: supplier),
          );
        });
      });
    }

    if (quotesWithSuppliers.length < 2) {
      return Left(NotFoundFailure('Orçamentos não encontrados'));
    }

    // Calcular comparação
    final comparison = _calculateComparison(quotesWithSuppliers);

    return Right(comparison);
  }

  QuoteComparison _calculateComparison(
    List<QuoteWithSupplier> quotesWithSuppliers,
  ) {
    // Ordenar por valor total
    final sortedByPrice = List<QuoteWithSupplier>.from(quotesWithSuppliers)
      ..sort((a, b) => a.quote.totalValue.compareTo(b.quote.totalValue));

    final cheapest = sortedByPrice.first;
    final mostExpensive = sortedByPrice.last;

    // Calcular economia
    final maxSavings =
        mostExpensive.quote.totalValue - cheapest.quote.totalValue;
    final savingsPercent = (maxSavings / mostExpensive.quote.totalValue) * 100;

    // Calcular média de preços
    final averagePrice =
        quotesWithSuppliers.fold<double>(
          0,
          (sum, qws) => sum + qws.quote.totalValue,
        ) /
        quotesWithSuppliers.length;

    // Ordenar por prazo
    final sortedByDeadline = List<QuoteWithSupplier>.from(quotesWithSuppliers)
      ..sort((a, b) {
        final daysA = _calculateEstimatedDays(a.quote);
        final daysB = _calculateEstimatedDays(b.quote);
        return daysA.compareTo(daysB);
      });

    final fastest = sortedByDeadline.first;

    return QuoteComparison(
      quotesWithSuppliers: quotesWithSuppliers,
      cheapest: cheapest,
      mostExpensive: mostExpensive,
      fastest: fastest,
      averagePrice: averagePrice,
      maxSavings: maxSavings,
      savingsPercent: savingsPercent,
    );
  }

  int _calculateEstimatedDays(QuoteEntity quote) {
    // Se o orçamento tiver um campo de prazo estimado, usar ele
    // Por enquanto, vamos calcular baseado na validade
    final daysUntilExpiry = quote.validUntil.difference(DateTime.now()).inDays;
    return daysUntilExpiry > 0 ? daysUntilExpiry : 30; // Default 30 dias
  }
}

/// Orçamento com informações do fornecedor
class QuoteWithSupplier {
  final QuoteEntity quote;
  final SupplierEntity supplier;

  QuoteWithSupplier({required this.quote, required this.supplier});
}

/// Resultado da comparação de orçamentos
class QuoteComparison {
  final List<QuoteWithSupplier> quotesWithSuppliers;
  final QuoteWithSupplier cheapest;
  final QuoteWithSupplier mostExpensive;
  final QuoteWithSupplier fastest;
  final double averagePrice;
  final double maxSavings;
  final double savingsPercent;

  QuoteComparison({
    required this.quotesWithSuppliers,
    required this.cheapest,
    required this.mostExpensive,
    required this.fastest,
    required this.averagePrice,
    required this.maxSavings,
    required this.savingsPercent,
  });
}

// Made with Bob
