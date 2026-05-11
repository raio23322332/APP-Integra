import 'package:flutter/foundation.dart';
import 'package:integra_app/services/storage/domain_storage.dart';

/// Gerencia login offline usando dados armazenados localmente
class OfflineAuthHandler {
  final DomainStorage _storage;

  OfflineAuthHandler(this._storage);

  /// Tenta efetuar login offline com dados armazenados
  Future<Map<String, dynamic>> offlineLogin() async {
    try {
      final user = await _storage.getUserData();
      final tenant = await _storage.getSelectedTenant();

      // Allow offline login if user and tenant are present in storage.
      // Token validation happens when connectivity is restored.
      if (user != null && tenant != null) {
        final authToken = await _storage.getAuthToken();
        return {
          'success': true,
          'user': user.toMap(),
          'tenant': tenant.toMap(),
          'access_token': authToken,
          'message': 'Login offline realizado com sucesso',
        };
      }
      
      return {
        'success': false,
        'message': 'Nenhuma sessão offline disponível',
      };
    } catch (e) {
      debugPrint('[OfflineAuthHandler] Erro ao fazer login offline: $e');
      return {
        'success': false,
        'message': 'Erro ao fazer login offline: $e',
      };
    }
  }
}
