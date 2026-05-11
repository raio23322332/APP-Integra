// lib/data/repositories/auth_repository_impl.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:integra_app/data/datasources/auth_remote_datasource.dart';
import 'package:integra_app/data/models/tenant_model.dart';

import 'package:integra_app/domain/entities/auth_response.dart';
import 'package:integra_app/domain/repositories/auth_repository.dart';

import 'package:integra_app/data/datasources/local/auth_local_datasource.dart';

import 'package:integra_app/data/models/user_model.dart';
import 'package:integra_app/services/shared_preference_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  String _getBaseUrl() {
    final String? baseFromEnv = dotenv.env['URL_BASE_API'];
    if (baseFromEnv == null) {
      throw Exception('URL_BASE_API não definida no .env');
    }
    return baseFromEnv.endsWith('/')
        ? baseFromEnv.substring(0, baseFromEnv.length - 1)
        : baseFromEnv;
  }

  String _getTenantDomain(Tenant tenant) {
    final String? tenantDomain =
        tenant.devDomain ?? tenant.primaryDomain ?? tenant.urlSubdomainBase;

    if (tenantDomain == null || tenantDomain.isEmpty) {
      throw Exception('Tenant sem domínio configurado');
    }

    return tenantDomain;
  }

  @override
  Future<AuthResponse> login({
    required Tenant tenant,
    required String email,
    required String password,
  }) async {
    final baseUrl = _getBaseUrl();
    final tenantDomain = _getTenantDomain(tenant);

    final result = await _remoteDataSource.login(
      baseUrl: baseUrl,
      tenantDomain: tenantDomain,
      credentials: {
        'email': email,
        'password': password,
        'device_name': 'flutter_app',
      },
    );

    if (!result['success']) {
      String message = result['message'] ?? 'Falha no login';
      
      // Remover "Exception:" ou "exception:" da mensagem
      if (message.toLowerCase().startsWith('exception:')) {
        message = message.substring(10).trim();
      }
      
      throw Exception(message);
    }

    final data = result['data'];
    final token = data['access_token'] ?? data['token'];

    if (token == null) {
      throw Exception('Token não encontrado na resposta');
    }

    // Salva token localmente
    await _localDataSource.saveAuthToken(token);
    // await _localDataSource.saveTenantId(tenant.id); // No longer needed as we save the full tenant object

    // Assuming AuthResponse.fromJson(data) properly populates user and tenant
    final authResponse = AuthResponse.fromJson(data);

    // Persist user: AuthResponse may contain a Map or already a model instance
    final dynamic userPayload = authResponse.user;
    if (userPayload != null) {
      if (userPayload is Map<String, dynamic>) {
        final userModel = User.fromMap(userPayload);
        await _localDataSource.saveUserData(userModel);
      } else if (userPayload is User) {
        await _localDataSource.saveUserData(userPayload);
      }
    }

    // Persist tenant if present (may be Map or Tenant)
    final dynamic tenantPayload = authResponse.tenant;
    if (tenantPayload != null) {
      if (tenantPayload is Map<String, dynamic>) {
        final tenantModel = Tenant.fromMap(tenantPayload);
        await _localDataSource.saveTenantSelection(tenantModel);
        // Salvar domínio nas SharedPreferences
        final pref = SharedPreferenceService();
        await pref.init();
        await pref.setTenantDomain(tenantDomain);
      } else if (tenantPayload is Tenant) {
        await _localDataSource.saveTenantSelection(tenantPayload);
        // Salvar domínio nas SharedPreferences
        final pref = SharedPreferenceService();
        await pref.init();
        await pref.setTenantDomain(tenantDomain);
      }
    }

    return authResponse;
  }

  @override
  Future<void> register({
    required Tenant tenant,
    required String name,
    required String email,
    required String password,
    String cpf = '',
    String phone = '',
  }) async {
    final baseUrl = _getBaseUrl();
    final tenantDomain = _getTenantDomain(tenant);

    final result = await _remoteDataSource.register(
      baseUrl: baseUrl,
      tenantDomain: tenantDomain,
      userData: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'cpf': cpf,
        'phone': phone,
        'device_name': 'flutter_app_register',
      },
    );

    if (!result['success']) {
      String message = result['message'] ?? 'Falha no registro';
      
      // Remover "Exception:" ou "exception:" da mensagem
      if (message.toLowerCase().startsWith('exception:')) {
        message = message.substring(10).trim();
      }
      
      throw Exception(message);
    }
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearAuthToken();
  }

  @override
  Future<AuthResponse> offlineLogin() async {
    final user = await _localDataSource.getUserData();
    final tenant = await _localDataSource.getSelectedTenant();
    final authToken = await _localDataSource.getAuthToken();

    if (user != null && tenant != null && authToken != null) {
      // Construct AuthResponse with model instances and an expiresAt
      return AuthResponse(
        accessToken: authToken,
        user: user,
        tenant: tenant,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );
    }
    throw Exception('Nenhuma sessão offline disponível');
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _localDataSource.getAuthToken();
    return token != null && token.isNotEmpty;
  }
}
