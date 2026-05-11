// lib/data/datasources/local/auth_local_datasource.dart

import 'package:integra_app/data/models/tenant_model.dart';
import 'package:integra_app/data/models/user_model.dart';


abstract class AuthLocalDataSource {
  Future<void> saveAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> saveTenantId(String tenantId);
  Future<void> clearAuthToken();
  Future<User?> getUserData();
  Future<Tenant?> getSelectedTenant();
  Future<void> saveUserData(User user);
  Future<void> saveTenantSelection(Tenant tenant);
}





