import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/supplier_repository.dart';

@injectable
class DeleteSupplierUseCase implements UseCase<void, DeleteSupplierParams> {
  final SupplierRepository repository;

  DeleteSupplierUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteSupplierParams params) async {
    return await repository.deleteSupplier(params.projectId, params.supplierId);
  }
}

class DeleteSupplierParams {
  final String projectId;
  final String supplierId;

  DeleteSupplierParams({required this.projectId, required this.supplierId});
}

// Made with Bob
