import 'package:hive_flutter/hive_flutter.dart';
import '../storage/local_storage_service.dart';

/// Implementação do serviço de armazenamento local usando Hive.
///
/// Esta classe gerencia caixas (boxes) separadas para diferentes tipos de dados,
/// como seleção de tenant e preferências do usuário, garantindo que a abertura
/// e o fechamento das caixas sejam manuseados de forma eficiente.
class HiveLocalStorageService implements LocalStorageService {
  static const String _tenantBoxName = 'tenantBox';
  static const String _preferencesBoxName = 'preferencesBox';
  static const String _tenantKey = 'tenantId';
  static const String _preferencesKey = 'userPreferences';

  // Mantém as caixas abertas para evitar reabri-las desnecessariamente.
  Box<String>? _tenantBox;
  Box<Map<dynamic, dynamic>>? _preferencesBox;

  Future<Box<String>> _getTenantBox() async {
    _tenantBox ??= await Hive.openBox<String>(_tenantBoxName);
    return _tenantBox!;
  }

  Future<Box<Map<dynamic, dynamic>>> _getPreferencesBox() async {
    _preferencesBox ??= await Hive.openBox<Map<dynamic, dynamic>>(
      _preferencesBoxName,
    );
    return _preferencesBox!;
  }

  @override
  Future<void> saveTenantSelection(String tenantId) async {
    final box = await _getTenantBox();
    await box.put(_tenantKey, tenantId);
  }

  @override
  Future<String?> getTenantSelection() async {
    final box = await _getTenantBox();
    return box.get(_tenantKey);
  }

  @override
  Future<void> saveUserPreferences(Map<String, dynamic> prefs) async {
    final box = await _getPreferencesBox();
    await box.put(_preferencesKey, prefs);
  }

  @override
  Future<Map<String, dynamic>?> getUserPreferences() async {
    final box = await _getPreferencesBox();
    final result = box.get(_preferencesKey);
    if (result != null) {
      // Garante que o mapa retornado tenha as chaves e valores com os tipos corretos.
      return result.cast<String, dynamic>();
    }
    return null;
  }

  /// Fecha todas as caixas abertas para liberar recursos.
  Future<void> closeBoxes() async {
    await _tenantBox?.close();
    await _preferencesBox?.close();
  }
}
