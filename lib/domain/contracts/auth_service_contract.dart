// lib/domain/contracts/auth_service_contract.dart

import '../../data/models/tenant_model.dart';

/// Contrato abstrato para serviços de autenticação
/// Melhora o isolamento do ViewModel permitindo injeção de dependências
abstract class AuthServiceContract {
  /// Realiza login online
  Future<Map<String, dynamic>> login(Tenant tenant, String email, String password);

  /// Realiza login offline
  Future<String?> offlineLogin(Tenant requestedTenant, {String? email});

  /// Verifica se usuário está autenticado
  bool get isAuthenticated;

  /// Obtém usuário atual
  dynamic get currentUser;
}
