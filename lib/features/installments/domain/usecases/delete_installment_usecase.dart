import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/installment_repository.dart';

@injectable
class DeleteInstallmentUseCase
    implements UseCase<void, DeleteInstallmentParams> {
  final InstallmentRepository repository;

  DeleteInstallmentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteInstallmentParams params) async {
    return await repository.deleteInstallment(
      params.projectId,
      params.installmentId,
    );
  }
}

class DeleteInstallmentParams {
  final String projectId;
  final String installmentId;

  DeleteInstallmentParams({
    required this.projectId,
    required this.installmentId,
  });
}
