// lib/core/contracts/storage_service_contract.dart

/// Contrato abstrato para serviços de armazenamento local
/// Define a interface que todos os serviços de storage devem implementar
abstract class StorageServiceContract {
  /// Salva token de autenticação
  Future<void> saveAuthToken(String token);

  /// Recupera token de autenticação
  Future<String?> getAuthToken();

  /// Remove token de autenticação
  Future<void> clearAuthToken();

  /// Salva dados do usuário
  Future<void> saveUserData(Map<String, dynamic> userData);

  /// Recupera dados do usuário
  Future<Map<String, dynamic>?> getUserData();

  /// Limpa dados do usuário
  Future<void> clearUserData();

  /// Salva domínio selecionado
  Future<void> saveSelectedDomain(String domain);

  /// Recupera domínio selecionado
  Future<String?> getSelectedDomain();
}
