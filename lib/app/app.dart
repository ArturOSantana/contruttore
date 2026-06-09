import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:contruttore/app/router/app_router.dart';
import 'package:contruttore/app/theme/app_theme.dart';
import 'package:contruttore/core/services/notification_service.dart';
import 'package:contruttore/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:contruttore/injection_container.dart';

/// Widget raiz do aplicativo Costruttore
class CostruttoreApp extends StatefulWidget {
  const CostruttoreApp({super.key});

  @override
  State<CostruttoreApp> createState() => _CostruttoreAppState();
}

class _CostruttoreAppState extends State<CostruttoreApp> {
  late final NotificationService _notificationService;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _notificationService = getIt<NotificationService>();
    _router = AppRouter.router;

    // Configurar callback para deep links
    _notificationService.onNotificationTap = _handleNotificationTap;
  }

  void _handleNotificationTap(String? route) {
    if (route != null && route.isNotEmpty) {
      // Aguardar frame para garantir que o contexto está pronto
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _router.go(route);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: MaterialApp.router(
        title: 'Costruttore',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
        ],
        locale: const Locale('pt', 'BR'),
      ),
    );
  }
}

// Made with Bob
