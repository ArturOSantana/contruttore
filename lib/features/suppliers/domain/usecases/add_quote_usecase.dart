import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/quote_entity.dart';
import '../repositories/supplier_repository.dart';

@injectable
class AddQuoteUseCase {
  final SupplierRepository _repository;

  AddQuoteUseCase(this._repository);

  Future<Either<Failure, void>> call(QuoteEntity quote) {
    return _repository.addQuote(quote);
  }
}

// Made with Bob
