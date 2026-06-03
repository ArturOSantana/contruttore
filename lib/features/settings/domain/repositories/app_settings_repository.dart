import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_settings_entity.dart';

/// Interface do repositório de configurações do app
abstract class AppSettingsRepository {
  /// Busca as configurações do usuário
  Future<Either<Failure, AppSettingsEntity>> getSettings(String userId);

  /// Salva as configurações do usuário
  Future<Either<Failure, void>> saveSettings(AppSettingsEntity settings);

  /// Atualiza uma configuração específica
  Future<Either<Failure, void>> updateSetting(
    String userId,
    String key,
    dynamic value,
  );
}

// Made with Bob
