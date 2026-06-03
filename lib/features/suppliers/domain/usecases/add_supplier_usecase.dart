import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/supplier_entity.dart';
import '../repositories/supplier_repository.dart';

@injectable
class AddSupplierUseCase {
  final SupplierRepository _repository;

  AddSupplierUseCase(this._repository);

  Future<Either<Failure, void>> call(SupplierEntity supplier) async {
    // Validar CNPJ se fornecido
    if (supplier.cnpj != null && supplier.cnpj!.isNotEmpty) {
      final isValidResult = await _repository.validateCNPJ(supplier.cnpj!);
      final isValid = isValidResult.fold((failure) => false, (valid) => valid);

      if (!isValid) {
        return Left(ValidationFailure('CNPJ inválido'));
      }
    }

    return _repository.addSupplier(supplier);
  }
}

// Made with Bob
