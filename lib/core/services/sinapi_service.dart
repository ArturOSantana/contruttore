import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import '../models/sinapi_reference.dart';

@lazySingleton
class SinapiService {
  static const String _boxName = 'sinapi_cache';
  Box<Map>? _box;

  /// Inicializa o cache local
  Future<void> initialize() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  /// Busca referência SINAPI por código
  Future<SinapiReference?> getReference(String code) async {
    if (_box == null) await initialize();

    final data = _box!.get(code);
    if (data == null) return null;

    return SinapiReference.fromMap(Map<String, dynamic>.from(data));
  }

  /// Busca referências por descrição (busca parcial)
  Future<List<SinapiReference>> searchByDescription(String query) async {
    if (_box == null) await initialize();

    final results = <SinapiReference>[];
    final lowerQuery = query.toLowerCase();

    for (final key in _box!.keys) {
      final data = _box!.get(key);
      if (data != null) {
        final ref = SinapiReference.fromMap(Map<String, dynamic>.from(data));
        if (ref.description.toLowerCase().contains(lowerQuery)) {
          results.add(ref);
        }
      }
    }

    return results;
  }

  /// Salva referência no cache
  Future<void> saveReference(SinapiReference reference) async {
    if (_box == null) await initialize();
    await _box!.put(reference.code, reference.toMap());
  }

  /// Salva múltiplas referências (para seed inicial)
  Future<void> saveReferences(List<SinapiReference> references) async {
    if (_box == null) await initialize();

    for (final ref in references) {
      await _box!.put(ref.code, ref.toMap());
    }
  }

  /// Limpa cache
  Future<void> clearCache() async {
    if (_box == null) await initialize();
    await _box!.clear();
  }

  /// Verifica se há dados no cache
  Future<bool> hasData() async {
    if (_box == null) await initialize();
    return _box!.isNotEmpty;
  }
}

// Made with Bob
