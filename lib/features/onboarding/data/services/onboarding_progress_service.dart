import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/conversational_onboarding_progress.dart';

/// Serviço para salvar e recuperar o progresso do onboarding
/// Usa SharedPreferences para persistência local
class OnboardingProgressService {
  static const String _progressKey = 'conversational_onboarding_progress';
  final SharedPreferences _prefs;

  OnboardingProgressService(this._prefs);

  /// Salva o progresso atual
  Future<void> saveProgress(ConversationalOnboardingProgress progress) async {
    try {
      final json = progress.toJson();
      final jsonString = jsonEncode(json);
      await _prefs.setString(_progressKey, jsonString);
      print('✅ Progresso salvo: step ${progress.currentStepIndex}');
    } catch (e) {
      print('❌ Erro ao salvar progresso: $e');
      rethrow;
    }
  }

  /// Recupera o progresso salvo
  Future<ConversationalOnboardingProgress?> loadProgress() async {
    try {
      final jsonString = _prefs.getString(_progressKey);
      if (jsonString == null) {
        print('ℹ️ Nenhum progresso salvo encontrado');
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final progress = ConversationalOnboardingProgress.fromJson(json);
      print('✅ Progresso recuperado: step ${progress.currentStepIndex}');
      return progress;
    } catch (e) {
      print('❌ Erro ao carregar progresso: $e');
      return null;
    }
  }

  /// Limpa o progresso salvo (após completar o onboarding)
  Future<void> clearProgress() async {
    try {
      await _prefs.remove(_progressKey);
      print('✅ Progresso limpo');
    } catch (e) {
      print('❌ Erro ao limpar progresso: $e');
      rethrow;
    }
  }

  /// Verifica se existe progresso salvo
  bool hasProgress() {
    return _prefs.containsKey(_progressKey);
  }

  /// Retorna a data da última atualização do progresso
  DateTime? getLastUpdateDate() {
    try {
      final jsonString = _prefs.getString(_progressKey);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final lastUpdated = json['lastUpdated'] as String?;
      if (lastUpdated == null) return null;

      return DateTime.parse(lastUpdated);
    } catch (e) {
      print('❌ Erro ao obter data de atualização: $e');
      return null;
    }
  }
}

// Made with ❤️ by Bob

// Made with Bob
