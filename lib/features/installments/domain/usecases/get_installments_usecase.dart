import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/installment_entity.dart';
import '../repositories/installment_repository.dart';

@injectable
class GetInstallmentsUseCase {
  final InstallmentRepository _repository;

  GetInstallmentsUseCase(this._repository);

  Future<Either<Failure, List<InstallmentEntity>>> call(String projectId) {
    return _repository.getInstallments(projectId);
  }
}

// Made with Bob
