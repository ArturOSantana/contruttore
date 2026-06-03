import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/supplier_entity.dart';
import '../entities/quote_entity.dart';

abstract class SupplierRepository {
  Future<Either<Failure, List<SupplierEntity>>> getSuppliers(String projectId);
  Future<Either<Failure, SupplierEntity>> getSupplier(
    String projectId,
    String supplierId,
  );
  Future<Either<Failure, void>> addSupplier(SupplierEntity supplier);
  Future<Either<Failure, void>> updateSupplier(SupplierEntity supplier);
  Future<Either<Failure, void>> deleteSupplier(
    String projectId,
    String supplierId,
  );

  Future<Either<Failure, List<QuoteEntity>>> getQuotes(
    String projectId,
    String supplierId,
  );
  Future<Either<Failure, List<QuoteEntity>>> getAllQuotes(String projectId);
  Future<Either<Failure, QuoteEntity>> getQuoteById(
    String projectId,
    String quoteId,
  );
  Future<Either<Failure, void>> addQuote(QuoteEntity quote);
  Future<Either<Failure, void>> updateQuoteStatus(
    String projectId,
    String quoteId,
    QuoteStatus status,
  );
  Future<Either<Failure, void>> deleteQuote(String projectId, String quoteId);

  Future<Either<Failure, bool>> validateCNPJ(String cnpj);
}

// Made with Bob
