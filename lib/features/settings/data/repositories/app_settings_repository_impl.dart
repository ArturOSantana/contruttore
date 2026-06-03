import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/repositories/app_settings_repository.dart';
import '../models/app_settings_model.dart';

/// Implementação do repositório de configurações usando Firebase
@LazySingleton(as: AppSettingsRepository)
class AppSettingsRepositoryImpl implements AppSettingsRepository {
  final FirebaseFirestore _firestore;

  AppSettingsRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, AppSettingsEntity>> getSettings(String userId) async {
    try {
      print(
        '🔵 [AppSettingsRepository] Buscando configurações do usuário: $userId',
      );

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('app_settings')
          .get();

      if (!doc.exists) {
        print(
          '⚠️ [AppSettingsRepository] Configurações não encontradas, criando padrão...',
        );
        // Se não existir, criar configurações padrão
        final defaultSettings = AppSettingsEntity.defaults(userId);
        await saveSettings(defaultSettings);
        return Right(defaultSettings);
      }

      final settings = AppSettingsModel.fromMap(doc.data()!);
      print('✅ [AppSettingsRepository] Configurações carregadas com sucesso');
      return Right(settings);
    } on FirebaseException catch (e) {
      print('❌ [AppSettingsRepository] Erro Firebase: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Erro ao buscar configurações'));
    } catch (e) {
      print('❌ [AppSettingsRepository] Erro inesperado: $e');
      return Left(ServerFailure('Erro ao buscar configurações: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(AppSettingsEntity settings) async {
    try {
      print(
        '🔵 [AppSettingsRepository] Salvando configurações do usuário: ${settings.userId}',
      );

      final model = AppSettingsModel.fromEntity(settings);
      await _firestore
          .collection('users')
          .doc(settings.userId)
          .collection('settings')
          .doc('app_settings')
          .set(model.toMap());

      print('✅ [AppSettingsRepository] Configurações salvas com sucesso');
      return const Right(null);
    } on FirebaseException catch (e) {
      print('❌ [AppSettingsRepository] Erro Firebase: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Erro ao salvar configurações'));
    } catch (e) {
      print('❌ [AppSettingsRepository] Erro inesperado: $e');
      return Left(ServerFailure('Erro ao salvar configurações: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSetting(
    String userId,
    String key,
    dynamic value,
  ) async {
    try {
      print(
        '🔵 [AppSettingsRepository] Atualizando configuração: $key = $value',
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('app_settings')
          .update({key: value, 'updatedAt': DateTime.now().toIso8601String()});

      print('✅ [AppSettingsRepository] Configuração atualizada com sucesso');
      return const Right(null);
    } on FirebaseException catch (e) {
      print('❌ [AppSettingsRepository] Erro Firebase: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Erro ao atualizar configuração'));
    } catch (e) {
      print('❌ [AppSettingsRepository] Erro inesperado: $e');
      return Left(ServerFailure('Erro ao atualizar configuração: $e'));
    }
  }
}

// Made with Bob
