import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/quote_entity.dart';
import '../repositories/supplier_repository.dart';

@injectable
class GetQuotesUseCase {
  final SupplierRepository _repository;

  GetQuotesUseCase(this._repository);

  Future<Either<Failure, List<QuoteEntity>>> call({
    required String projectId,
    String? supplierId,
  }) {
    if (supplierId != null) {
      return _repository.getQuotes(projectId, supplierId);
    }
    return _repository.getAllQuotes(projectId);
  }
}

// Made with Bob
