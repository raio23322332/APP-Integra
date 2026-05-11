import 'dart:convert'; // Added for JSON encoding/decoding
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:integra_app/core/helpers/console_log.dart';
import 'package:integra_app/domain/mappers/mapper_service.dart';
import 'package:integra_app/data/dao/tenant_config_dao.dart';
import 'package:integra_app/data/models/tenant_model.dart';

import 'package:integra_app/data/models/user_model.dart'; // IMPORTANT: Using the canonical User model

class DomainStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userObjectKey =
      'user_object'; // Single key for serialized User object

  final TenantConfigDao _tenantConfigDao = TenantConfigDao();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> init() async {
    // A inicialização do banco de dados agora é tratada pelo LocalDatabase.
    // Este método pode ser usado para qualquer inicialização futura específica do DomainStorage.
  }

  Future<void> saveSelectedDomain(String domain) async {
    try {
      await _tenantConfigDao.saveSelectedDomain(domain);
    } catch (e) {
      debugPrint("Erro ao salvar domínio: $e");
    }
  }

  Future<String?> getSelectedDomain() async {
    try {
      return await _tenantConfigDao.getSelectedDomain();
    } catch (e) {
      debugPrint("Erro ao recuperar domínio: $e");
      return null;
    }
  }

  Future<void> saveAuthToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
      debugPrint(
        '[DomainStorage] saveAuthToken: token salvo com sucesso (len=${token.length})',
      );
    } catch (e) {
      debugPrint("Erro ao salvar token: $e");
    }
  }

  Future<String?> getAuthToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token != null && token.isNotEmpty) {
        debugPrint(
          '[DomainStorage] getAuthToken: token encontrado (len=${token.length})',
        );
      } else {
        debugPrint('[DomainStorage] getAuthToken: nenhum token encontrado');
      }
      return token;
    } catch (e) {
      debugPrint("Erro ao ler token: $e");
      return null;
    }
  }

  Future<void> clearAuthToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      debugPrint(
        '[DomainStorage] clearAuthToken: token apagado do secure storage',
      );
    } catch (e) {
      debugPrint("Erro ao limpar token: $e");
    }
  }

  // Modified saveUserData to store whole User object as JSON
  Future<void> saveUserData(User user) async {
    try {
      final userJson = jsonEncode(MapperService.userToMap(user));
      await _secureStorage.write(key: _userObjectKey, value: userJson);
      debugPrint(
        '[DomainStorage] saveUserData: usuário salvo no secure storage (len=${userJson.length})',
      );
    } catch (e) {
      debugPrint("Erro ao salvar dados do usuário: $e");
    }
  }

  // Modified getUserData to retrieve and deserialize the User object from JSON
  Future<User?> getUserData() async {
    try {
      final userJson = await _secureStorage.read(key: _userObjectKey);
      if (userJson == null || userJson.isEmpty) {
        ConsoleLog.debug(
            '🔐 DomainStorage: Nenhum dado de usuário encontrado no secure storage');
        return null;
      }
      ConsoleLog.debug(
          '🔐 DomainStorage: Usuário encontrado no secure storage');
      debugPrint(
        '[DomainStorage] getUserData: encontrado JSON do usuário (len=${userJson.length})',
      );
      final user = User.fromMap(jsonDecode(userJson));
      ConsoleLog.debug(
          '🔐 DomainStorage: Usuário recuperado - Email: ${user.email}, Name: ${user.name}');
      return user;
    } catch (e) {
      ConsoleLog.error("Erro ao recuperar dados do usuário: $e");
    }
    return null;
  }

  // Modified clearUserData to clear the single User object key
  Future<void> clearUserData() async {
    try {
      await _secureStorage.delete(key: _userObjectKey);
    } catch (e) {
      ConsoleLog.error("Erro ao limpar dados do usuário: $e");
    }
  }

  Future<void> clearUserSession() async {
    await _tenantConfigDao
        .clearTenantConfig(); // Clears selected domain/tenant, preserves cached tenants
    await clearAuthToken(); // Clears only the auth token
  }

  Future<void> saveTenantSelection(Tenant tenant) async {
    try {
      await _tenantConfigDao.saveTenantSelection(tenant);
    } catch (e) {
      ConsoleLog.error("Erro ao salvar tenant: $e");
    }
  }

  Future<Tenant?> getSelectedTenant() async {
    try {
      return await _tenantConfigDao.getSelectedTenant();
    } catch (e) {
      ConsoleLog.error("Erro ao recuperar tenant: $e");
      return null;
    }
  }
}
