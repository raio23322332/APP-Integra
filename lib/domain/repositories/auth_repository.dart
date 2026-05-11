// lib/domain/repositories/auth_repository.dart

import 'package:integra_app/data/models/tenant_model.dart';
import 'package:integra_app/domain/entities/auth_response.dart';


abstract class AuthRepository {
  Future<AuthResponse> login({
    required Tenant tenant,
    required String email,
    required String password,
  });

  Future<void> register({
    required Tenant tenant,
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
  });

  Future<AuthResponse> offlineLogin();

  Future<void> logout();
  
  Future<bool> isAuthenticated();
}




