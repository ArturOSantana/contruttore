import 'package:bloc_test/bloc_test.dart';
import 'package:contruttore/core/error/failures.dart';
import 'package:contruttore/features/auth/domain/entities/user_entity.dart';
import 'package:contruttore/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:contruttore/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:contruttore/features/auth/domain/usecases/login_usecase.dart';
import 'package:contruttore/features/auth/domain/usecases/logout_usecase.dart';
import 'package:contruttore/features/auth/domain/usecases/register_usecase.dart';
import 'package:contruttore/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:contruttore/features/auth/presentation/cubit/auth_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockForgotPasswordUseCase extends Mock implements ForgotPasswordUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

void main() {
  late AuthCubit authCubit;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockForgotPasswordUseCase mockForgotPasswordUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;

  const tUser = UserEntity(
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
  );

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockForgotPasswordUseCase = MockForgotPasswordUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();

    authCubit = AuthCubit(
      mockLoginUseCase,
      mockRegisterUseCase,
      mockLogoutUseCase,
      mockForgotPasswordUseCase,
      mockGetCurrentUserUseCase,
    );
  });

  group('AuthCubit - Autenticação', () {
    // Teste 1: Verifica se o Cubit inicia no estado correto (AuthInitial)
    test('O estado inicial deve ser AuthInitial', () {
      expect(authCubit.state, equals(const AuthInitial()));
    });

    // Teste 2: Testa o fluxo de login com sucesso
    // O que ele faz: Simula um retorno positivo do UseCase e verifica se o Cubit emite Loading -> Authenticated
    blocTest<AuthCubit, AuthState>(
      'Deve emitir [AuthLoading, AuthAuthenticated] quando o login for bem sucedido',
      build: () {
        when(
          () => mockLoginUseCase(any(), any()),
        ).thenAnswer((_) async => const Right(tUser));
        return authCubit;
      },
      act: (cubit) => cubit.login('test@example.com', 'password'),
      expect: () => [const AuthLoading(), const AuthAuthenticated(tUser)],
    );

    // Teste 3: Testa o fluxo de login com erro
    // O que ele faz: Simula uma falha no Firebase (ex: senha errada) e verifica se emite AuthError
    blocTest<AuthCubit, AuthState>(
      'Deve emitir [AuthLoading, AuthError] quando o login falhar',
      build: () {
        when(
          () => mockLoginUseCase(any(), any()),
        ).thenAnswer((_) async => const Left(ServerFailure('Erro de conexão')));
        return authCubit;
      },
      act: (cubit) => cubit.login('test@example.com', 'wrong_password'),
      expect: () => [const AuthLoading(), const AuthError('Erro de conexão')],
    );

    // Teste 4: Testa o logout
    // O que ele faz: Garante que ao sair, o estado mude para Unauthenticated
    blocTest<AuthCubit, AuthState>(
      'Deve emitir [AuthLoading, AuthUnauthenticated] quando o logout for bem sucedido',
      build: () {
        when(
          () => mockLogoutUseCase(),
        ).thenAnswer((_) async => const Right(null));
        return authCubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
    );
  });
}
