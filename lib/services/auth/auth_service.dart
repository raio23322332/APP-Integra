import 'package:integra_app/data/models/tenant_model.dart';
import 'token_validator.dart';
import 'credentials_handler.dart';
import 'offline_auth_handler.dart';

class AuthService {
  final TokenValidator _tokenValidator;
  final CredentialsHandler _credentialsHandler;
  final OfflineAuthHandler _offlineAuthHandler;

  AuthService({
    required TokenValidator tokenValidator,
    required CredentialsHandler credentialsHandler,
    required OfflineAuthHandler offlineAuthHandler,
  }) : _tokenValidator = tokenValidator,
       _credentialsHandler = credentialsHandler,
       _offlineAuthHandler = offlineAuthHandler;

  Future<Map<String, dynamic>> validateTokenAndSync() async {
    return await _tokenValidator.validateAndSync();
  }

  Future<Map<String, dynamic>> login(
    Tenant tenant,
    String email,
    String password,
  ) async {
    return await _credentialsHandler.login(tenant, email, password);
  }

  Future<Map<String, dynamic>> offlineLogin() async {
    return await _offlineAuthHandler.offlineLogin();
  }

  Future<void> logout() async {
    await _credentialsHandler.logout();
  }

  Future<Map<String, dynamic>> register(
    Tenant tenant,
    String email,
    String password,
    String name,
    String cpf,
    String phone,
  ) async {
    return await _credentialsHandler.register(
      tenant,
      email,
      password,
      name,
      cpf,
      phone,
    );
  }
}
