// lib/data/datasources/local/auth_local_datasource_impl.dart
import 'package:integra_app/data/models/tenant_model.dart';
import 'package:integra_app/services/storage/domain_storage.dart';
import 'package:integra_app/data/datasources/local/auth_local_datasource.dart';
import 'package:integra_app/data/models/user_model.dart';


class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final DomainStorage _domainStorage;

  AuthLocalDataSourceImpl(this._domainStorage);

  @override
  Future<void> saveAuthToken(String token) async {
    await _domainStorage.saveAuthToken(token);
  }

  @override
  Future<String?> getAuthToken() async {
    return await _domainStorage.getAuthToken();
  }

  @override
  Future<void> saveTenantId(String tenantId) async {
    // Implemente se necessário, ou use:
    // await _domainStorage.saveSelectedTenantId(tenantId);
  }

  @override
  Future<void> clearAuthToken() async {
    await _domainStorage.clearAuthToken();
  }

  @override
  Future<User?> getUserData() async {
    return await _domainStorage.getUserData();
  }

  @override
  Future<Tenant?> getSelectedTenant() async {
    return await _domainStorage.getSelectedTenant();
  }

  @override
  Future<void> saveUserData(User user) async {
    await _domainStorage.saveUserData(user);
  }

  @override
  Future<void> saveTenantSelection(Tenant tenant) async {
    await _domainStorage.saveTenantSelection(tenant);
  }
}





