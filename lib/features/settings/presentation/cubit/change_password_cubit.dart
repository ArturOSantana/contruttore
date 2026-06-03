import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/usecases/change_password_usecase.dart';
import 'change_password_state.dart';

@injectable
class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final ChangePasswordUseCase _changePasswordUseCase;

  ChangePasswordCubit(this._changePasswordUseCase)
    : super(ChangePasswordInitial());

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(ChangePasswordLoading());

    final result = await _changePasswordUseCase(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    result.fold((failure) {
      String message = 'Erro ao alterar senha';
      if (failure is ServerFailure) {
        message = failure.message;
      }
      emit(ChangePasswordError(message));
    }, (_) => emit(ChangePasswordSuccess()));
  }
}

// Made with Bob
