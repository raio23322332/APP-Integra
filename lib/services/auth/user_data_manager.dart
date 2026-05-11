import 'package:flutter/foundation.dart';
import 'package:integra_app/data/models/user_model.dart';
import 'package:integra_app/services/storage/domain_storage.dart';

/// Gerencia atualização e sincronização de dados do usuário
class UserDataManager {
  final DomainStorage _storage;

  UserDataManager(this._storage);

  /// Atualiza dados do usuário baseado na resposta da API
  /// Se o payload não contém token, usa o token fornecido
  Future<void> updateFromResponse(
    Map<String, dynamic> responseData,
    String? currentToken,
  ) async {
    try {
      final userData = responseData['user'] ?? responseData['data'] ?? responseData;
      
      if (userData != null && userData is Map<String, dynamic>) {
        final user = User(
          id: userData['id'] as int?,
          email: (userData['email'] ?? '') as String,
          token: currentToken ?? '',
          name: userData['name'] as String?,
          cpf: userData['cpf'] as String?,
          roles: (userData['roles'] as List?)
              ?.map((e) => e.toString())
              .toList() ?? [],
          permissions: (userData['permissions'] as List?)
              ?.map((e) => e.toString())
              .toList() ?? [],
        );
        
        await _storage.saveUserData(user);
        debugPrint('[UserDataManager] Usuário atualizado: ${user.email}');
      }
    } catch (e) {
      debugPrint('[UserDataManager] Erro ao atualizar dados do usuário: $e');
    }
  }

  /// Extrai dados do usuário da resposta da API
  User? extractUserFromResponse(
    Map<String, dynamic> responseData,
    String token,
  ) {
    try {
      final userData = responseData['user'] ?? responseData['data'] ?? responseData;
      
      if (userData != null && userData is Map<String, dynamic>) {
        return User(
          id: userData['id'] as int?,
          email: (userData['email'] ?? '') as String,
          token: token,
          name: userData['name'] as String?,
          cpf: userData['cpf'] as String?,
          roles: (userData['roles'] as List?)
              ?.map((e) => e.toString())
              .toList() ?? [],
          permissions: (userData['permissions'] as List?)
              ?.map((e) => e.toString())
              .toList() ?? [],
        );
      }
    } catch (e) {
      debugPrint('[UserDataManager] Erro ao extrair usuário: $e');
    }
    
    return null;
  }
}
