import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthCubit(
    this._loginUseCase,
    this._registerUseCase,
    this._logoutUseCase,
    this._forgotPasswordUseCase,
    this._getCurrentUserUseCase,
  ) : super(const AuthInitial());

  /// Verifica o status de autenticação atual
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());

    final result = await _getCurrentUserUseCase();

    result.fold((failure) => emit(const AuthUnauthenticated()), (user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    });
  }

  /// Realiza login com email e senha
  Future<void> login(String email, String password) async {
    emit(const AuthLoading());

    final result = await _loginUseCase(email, password);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  /// Registra um novo usuário
  Future<void> register(String name, String email, String password) async {
    emit(const AuthLoading());

    final result = await _registerUseCase(name, email, password);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  /// Realiza logout do usuário
  Future<void> logout() async {
    emit(const AuthLoading());

    final result = await _logoutUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  /// Envia email de recuperação de senha
  Future<void> forgotPassword(String email) async {
    emit(const AuthLoading());

    final result = await _forgotPasswordUseCase(email);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(
        const AuthSuccess(
          'Email de recuperação enviado! Verifique sua caixa de entrada.',
        ),
      ),
    );
  }

  /// Limpa o estado de erro ou sucesso
  void clearMessage() {
    if (state is AuthError || state is AuthSuccess) {
      emit(const AuthUnauthenticated());
    }
  }
}

// Made with Bob
