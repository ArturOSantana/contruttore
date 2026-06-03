import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/supplier_entity.dart';
import '../repositories/supplier_repository.dart';

@injectable
class GetSuppliersUseCase {
  final SupplierRepository _repository;

  GetSuppliersUseCase(this._repository);

  Future<Either<Failure, List<SupplierEntity>>> call(String projectId) {
    return _repository.getSuppliers(projectId);
  }
}

// Made with Bob
