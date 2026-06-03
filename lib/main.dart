import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';
import 'core/services/notification_service.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'injection_container.dart';

void main() async {
  // Garante que os bindings do Flutter estão inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa formatação de datas em português
  await initializeDateFormatting('pt_BR', null);

  // Configura orientação da tela (apenas portrait)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configura a barra de status
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Inicializa o Firebase
  await Firebase.initializeApp();

  // Inicializa o Hive para cache local
  await Hive.initFlutter();

  // Configura injeção de dependências
  await configureDependencies();

  // Inicializa o serviço de notificações
  final notificationService = getIt<NotificationService>();
  await notificationService.initialize();

  // Salva FCM token se usuário estiver autenticado
  try {
    final authRepository = getIt<AuthRepository>();
    final userResult = await authRepository.getCurrentUser();

    userResult.fold((failure) => print('Erro ao obter usuário: $failure'), (
      user,
    ) async {
      if (user != null) {
        final token = await notificationService.getToken();
        if (token != null) {
          await authRepository.saveFcmToken(user.id, token);
          print('FCM token salvo com sucesso');
        }
      }
    });
  } catch (e) {
    print('Erro ao salvar FCM token: $e');
  }

  // Inicia o aplicativo
  runApp(const CostruttoreApp());
}

// Made with Bob
