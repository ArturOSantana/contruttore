import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/repositories/app_settings_repository.dart';
import 'app_settings_state.dart';

/// Cubit responsável por gerenciar as configurações do app
@injectable
class AppSettingsCubit extends Cubit<AppSettingsState> {
  final AppSettingsRepository _repository;

  AppSettingsCubit(this._repository) : super(AppSettingsInitial());

  /// Carrega as configurações do usuário
  Future<void> loadSettings(String userId) async {
    print('🔵 [AppSettingsCubit] Carregando configurações do usuário: $userId');
    emit(AppSettingsLoading());

    final result = await _repository.getSettings(userId);

    result.fold(
      (failure) {
        print(
          '❌ [AppSettingsCubit] Erro ao carregar configurações: ${failure.message}',
        );
        emit(AppSettingsError(failure.message));
      },
      (settings) {
        print('✅ [AppSettingsCubit] Configurações carregadas com sucesso');
        emit(AppSettingsLoaded(settings));
      },
    );
  }

  /// Atualiza uma configuração específica
  Future<void> updateSetting(String key, dynamic value) async {
    final currentState = state;
    if (currentState is! AppSettingsLoaded) {
      print(
        '⚠️ [AppSettingsCubit] Tentativa de atualizar sem configurações carregadas',
      );
      return;
    }

    print('🔵 [AppSettingsCubit] Atualizando configuração: $key = $value');

    // Atualiza localmente primeiro (otimistic update)
    final updatedSettings = _updateSettingsLocally(
      currentState.settings,
      key,
      value,
    );
    emit(AppSettingsLoaded(updatedSettings));

    // Salva no Firebase
    final result = await _repository.updateSetting(
      currentState.settings.userId,
      key,
      value,
    );

    result.fold(
      (failure) {
        print(
          '❌ [AppSettingsCubit] Erro ao salvar configuração: ${failure.message}',
        );
        // Reverte para o estado anterior
        emit(AppSettingsLoaded(currentState.settings));
        emit(AppSettingsError(failure.message));
      },
      (_) {
        print('✅ [AppSettingsCubit] Configuração salva com sucesso');
      },
    );
  }

  /// Atualiza as configurações localmente
  AppSettingsEntity _updateSettingsLocally(
    AppSettingsEntity settings,
    String key,
    dynamic value,
  ) {
    switch (key) {
      case 'notificationsEnabled':
        return settings.copyWith(
          notificationsEnabled: value as bool,
          updatedAt: DateTime.now(),
        );
      case 'alertsEnabled':
        return settings.copyWith(
          alertsEnabled: value as bool,
          updatedAt: DateTime.now(),
        );
      case 'educationalAlertsEnabled':
        return settings.copyWith(
          educationalAlertsEnabled: value as bool,
          updatedAt: DateTime.now(),
        );
      case 'maxPushPerDay':
        return settings.copyWith(
          maxPushPerDay: value as int,
          updatedAt: DateTime.now(),
        );
      default:
        return settings;
    }
  }

  /// Salva todas as configurações
  Future<void> saveSettings(AppSettingsEntity settings) async {
    print('🔵 [AppSettingsCubit] Salvando todas as configurações');
    emit(AppSettingsLoading());

    final result = await _repository.saveSettings(settings);

    result.fold(
      (failure) {
        print(
          '❌ [AppSettingsCubit] Erro ao salvar configurações: ${failure.message}',
        );
        emit(AppSettingsError(failure.message));
      },
      (_) {
        print('✅ [AppSettingsCubit] Configurações salvas com sucesso');
        emit(AppSettingsLoaded(settings));
      },
    );
  }
}

// Made with Bob
