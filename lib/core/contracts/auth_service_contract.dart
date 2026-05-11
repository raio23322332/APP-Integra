// lib/core/contracts/auth_service_contract.dart

import 'package:integra_app/data/models/tenant_model.dart';

/// Contrato abstrato para serviços de autenticação
/// Permite desacoplar ViewModels da implementação concreta do AuthViewModel
abstract class AuthService {
  /// Faz logout do usuário atual
  Future<void> logout();

  /// Carrega dados do usuário atual
  Future<void> loadCurrentUser();

  /// Tenta login offline para o tenant especificado
  Future<String?> offlineLogin(Tenant tenant, {String? email});

  /// Verifica se há usuário autenticado
  bool get isAuthenticated;
}
