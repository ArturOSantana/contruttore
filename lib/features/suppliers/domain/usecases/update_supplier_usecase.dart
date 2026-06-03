import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/supplier_entity.dart';
import '../repositories/supplier_repository.dart';

@injectable
class UpdateSupplierUseCase {
  final SupplierRepository _repository;

  UpdateSupplierUseCase(this._repository);

  Future<Either<Failure, void>> call(SupplierEntity supplier) {
    return _repository.updateSupplier(supplier);
  }
}

// Made with Bob
