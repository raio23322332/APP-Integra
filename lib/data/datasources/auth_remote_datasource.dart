// lib/data/datasources/remote/auth_remote_datasource.dart
abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login({
    required String baseUrl,
    required String tenantDomain,
    required Map<String, dynamic> credentials,
  });

  Future<Map<String, dynamic>> register({
    required String baseUrl,
    required String tenantDomain,
    required Map<String, dynamic> userData,
  });
}