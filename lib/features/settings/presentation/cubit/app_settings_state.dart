import 'package:equatable/equatable.dart';
import '../../domain/entities/app_settings_entity.dart';

/// Estados do AppSettingsCubit
abstract class AppSettingsState extends Equatable {
  const AppSettingsState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AppSettingsInitial extends AppSettingsState {}

/// Carregando configurações
class AppSettingsLoading extends AppSettingsState {}

/// Configurações carregadas
class AppSettingsLoaded extends AppSettingsState {
  final AppSettingsEntity settings;

  const AppSettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// Erro ao carregar/salvar configurações
class AppSettingsError extends AppSettingsState {
  final String message;

  const AppSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Made with Bob
