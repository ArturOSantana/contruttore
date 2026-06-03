import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// Estados do EditProfileCubit
abstract class EditProfileState extends Equatable {
  const EditProfileState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class EditProfileInitial extends EditProfileState {
  const EditProfileInitial();
}

/// Estado de carregamento
class EditProfileLoading extends EditProfileState {
  const EditProfileLoading();
}

/// Estado de sucesso
class EditProfileSuccess extends EditProfileState {
  final UserEntity user;

  const EditProfileSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

/// Estado de erro
class EditProfileError extends EditProfileState {
  final String message;

  const EditProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

// Made with Bob
