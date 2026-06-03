import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../auth/domain/usecases/update_profile_usecase.dart';
import 'edit_profile_state.dart';

/// Cubit para gerenciar edição de perfil
@injectable
class EditProfileCubit extends Cubit<EditProfileState> {
  final UpdateProfileUseCase _updateProfileUseCase;

  EditProfileCubit(this._updateProfileUseCase)
    : super(const EditProfileInitial());

  /// Atualiza o perfil do usuário
  Future<void> updateProfile({
    required String userId,
    required String name,
    required String email,
  }) async {
    emit(const EditProfileLoading());

    final result = await _updateProfileUseCase(
      userId: userId,
      name: name,
      email: email,
    );

    result.fold(
      (failure) => emit(EditProfileError(failure.message)),
      (user) => emit(EditProfileSuccess(user)),
    );
  }
}

// Made with Bob
