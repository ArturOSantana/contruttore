import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/constants/app_constants.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Verificar se é primeira vez do usuário
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    // Verificar se tutorial já foi completado
    final box = await Hive.openBox('app_settings');
    final tutorialCompleted =
        box.get(AppConstants.keyTutorialCompleted, defaultValue: false) as bool;

    if (!mounted) return;

    if (!tutorialCompleted) {
      // Primeira vez - mostrar tutorial
      context.go(RouteNames.tutorial);
    } else {
      // Não é primeira vez - verificar autenticação
      context.read<AuthCubit>().checkAuthStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Se tem projeto ativo, vai para home
          if (state.user.currentProjectId != null) {
            context.go(RouteNames.home);
          } else {
            // Se não tem projeto, vai para onboarding conversacional
            context.go(RouteNames.conversationalWelcome);
          }
        } else if (state is AuthUnauthenticated) {
          // Não autenticado, vai para login
          context.go(RouteNames.login);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ou nome do app
              Text(
                'Costruttore',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              // Loading indicator
              CircularProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

// Made with Bob
