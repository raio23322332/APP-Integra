import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:integra_app/data/models/tenant_model.dart';
import 'package:integra_app/services/storage/domain_storage.dart';
import 'package:integra_app/services/auth/user_data_manager.dart';
import 'package:integra_app/services/category_service.dart';

import '../shared_preference_service.dart';

/// Gerencia operações de autenticação: login, register e logout
class CredentialsHandler {
  final DomainStorage _storage;
  final UserDataManager _userDataManager;

  final pref = SharedPreferenceService();

  CredentialsHandler(this._storage, this._userDataManager);

  /// Realiza login no tenant via IP do servidor
  Future<Map<String, dynamic>> login(
    Tenant tenant,
    String email,
    String password,
  ) async {
    try {
      final String? tenantDomain =
          tenant.devDomain ?? tenant.primaryDomain ?? tenant.urlSubdomainBase;

      if (tenantDomain == null || tenantDomain.isEmpty) {
        return {'success': false, 'message': 'Tenant sem domínio configurado.'};
      }

      final String? baseFromEnv = dotenv.env['URL_BASE_API'];
      if (baseFromEnv == null) {
        throw Exception('URL_BASE_API não definida no arquivo .env');
      }

      final String baseUrl = baseFromEnv.endsWith('/')
          ? baseFromEnv.substring(0, baseFromEnv.length - 1)
          : baseFromEnv;

      final Uri loginUrl = Uri.parse('$baseUrl/api/v1/auth/login');

      debugPrint('🔐 Login URL (IP): $loginUrl');
      debugPrint('🌐 Host (tenant): $tenantDomain');

      final response = await http.post(
        loginUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Host': tenantDomain,
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
          'device_name': 'flutter_app',
        }),
      );

      final responseData = jsonDecode(response.body);
      String? accessToken = responseData['access_token'];
      debugPrint('Status Code Recebido: ${response.statusCode}');
      debugPrint('BODY (login): ${response.body}');

      if (response.statusCode == 200) {
        await pref.init();
        if (accessToken != null) {
          await pref.create(
            accessToken: accessToken,
            successStatus: true,
            tenantDomain: tenantDomain,
            subBaseUrl: tenant.urlSubdomainBase.toString(),
          );
        }
        return await _handleLoginSuccess(
          responseData,
          tenant,
          tenantDomain,
          email,
        );
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'reason': 'invalid_credentials',
          'message': 'Credenciais inválidas. Verifique suas credenciais.',
        };
      }

      final errorMessage =
          responseData['message'] ??
          'Erro desconhecido. Status: ${response.statusCode}';

      debugPrint('❌ Erro no login: $errorMessage');

      return {
        'success': false,
        'reason': 'server_error',
        'message': errorMessage,
      };
    } catch (e) {
      debugPrint('Ocorreu um erro na requisição: $e');
      return {
        'success': false,
        'reason': 'network',
        'message':
            'Erro ao conectar com a API. Verifique a rede e o servidor: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _handleLoginSuccess(
    Map<String, dynamic> responseData,
    Tenant tenant,
    String tenantDomain,
    String email,
  ) async {
    final String? token = responseData['access_token'] ?? responseData['token'];

    if (token != null) {
      debugPrint('✅ Login bem-sucedido!');
      debugPrint('Token: $token');

      // Salva token e tenant
      await _storage.saveAuthToken(token);
      if (tenantDomain.isNotEmpty) {
        await _storage.saveSelectedDomain(tenantDomain);
        await _storage.saveTenantSelection(tenant);
      }

      // Atualiza dados do usuário
      final userData = responseData['user'];
      if (userData != null && userData is Map<String, dynamic>) {
        await _userDataManager.updateFromResponse(responseData, token);
      }

      // Sincroniza categorias em background após login bem-sucedido
      _syncCategories(tenant, token);

      return {
        'success': true,
        'reason': 'ok',
        'access_token': token,
        'user': responseData['user'] ?? {},
      };
    } else {
      debugPrint(
        'Falha no login: Resposta do servidor não contém um token válido.',
      );
      return {
        'success': false,
        'reason': 'no_token',
        'message': 'Resposta do servidor não contém um token válido.',
      };
    }
  }

  /// Sincroniza as categorias do tenant em background
  void _syncCategories(Tenant tenant, String token) {
    try {
      debugPrint('[CredentialsHandler] Iniciando sincronização de categorias em background...');
      CategoryService().getCategories(tenant, token).then((_) {
        debugPrint('[CredentialsHandler] Sincronização de categorias concluída com sucesso.');
      }).catchError((e) {
        debugPrint('[CredentialsHandler] Erro na sincronização de categorias em background: $e');
      });
    } catch (e) {
      debugPrint('[CredentialsHandler] Falha ao disparar sincronização de categorias: $e');
    }
  }

  /// Realiza registro no tenant
  Future<Map<String, dynamic>> register(
    Tenant tenant,
    String email,
    String password,
    String name,
    String cpf,
    String phone,
  ) async {
    try {
      final String? tenantDomain =
          tenant.devDomain ?? tenant.primaryDomain ?? tenant.urlSubdomainBase;

      if (tenantDomain == null || tenantDomain.isEmpty) {
        return {'success': false, 'message': 'Tenant sem domínio configurado.'};
      }

      final String? baseFromEnv = dotenv.env['URL_BASE_API'];
      if (baseFromEnv == null) {
        throw Exception('URL_BASE_API não definida no arquivo .env');
      }

      final String baseUrl = baseFromEnv.endsWith('/')
          ? baseFromEnv.substring(0, baseFromEnv.length - 1)
          : baseFromEnv;

      final Uri registerUrl = Uri.parse('$baseUrl/api/v1/auth/register');

      debugPrint("🔐 URL de Registro (IP): $registerUrl");
      debugPrint("🌐 Host (tenant): $tenantDomain");

      final response = await http.post(
        registerUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Host': tenantDomain,
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'cpf': cpf,
          'phone': phone,
          'device_name': 'flutter_app_register',
        }),
      );

      final responseData = jsonDecode(response.body);
      debugPrint('Status Code Recebido no Registro: ${response.statusCode}');
      debugPrint('BODY (registro): ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('✅ Registro bem-sucedido!');
        return {'success': true, 'data': responseData};
      } else {
        final errorMessage =
            responseData['message'] ??
            'Erro desconhecido. Status: ${response.statusCode}';
        debugPrint('Falha no registro: ${response.statusCode}');
        debugPrint('Erro: $errorMessage');
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      debugPrint('Ocorreu um erro na requisição de registro: $e');
      return {
        'success': false,
        'message':
            'Erro ao conectar com a API para registro. Verifique a rede e o servidor: $e',
      };
    }
  }

  /// Faz logout no servidor (melhor esforço)
  Future<void> logout() async {
    try {
      final authToken = await _storage.getAuthToken();
      final tenant = await _storage.getSelectedTenant();

      final String? baseFromEnv = dotenv.env['URL_BASE_API'];
      final String baseUrl = (baseFromEnv ?? '').endsWith('/')
          ? (baseFromEnv ?? '').substring(0, (baseFromEnv ?? '').length - 1)
          : (baseFromEnv ?? '');

      final tenantDomain =
          tenant?.devDomain ??
          tenant?.primaryDomain ??
          tenant?.urlSubdomainBase;

      if (authToken != null &&
          authToken.isNotEmpty &&
          tenantDomain != null &&
          tenantDomain.isNotEmpty &&
          baseUrl.isNotEmpty) {
        try {
          final Uri logoutUrl = Uri.parse('$baseUrl/api/v1/auth/logout');
          debugPrint(
            '[CredentialsHandler] logout: POSTing to $logoutUrl with Host=$tenantDomain',
          );

          await http.post(
            logoutUrl,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
              'Host': tenantDomain,
              'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode(<String, String>{}),
          );

          debugPrint('[CredentialsHandler] logout: logout remoto realizado');
        } catch (e) {
          debugPrint(
            '[CredentialsHandler] logout: erro ao chamar endpoint de logout: $e',
          );
        }
      } else {
        debugPrint(
          '[CredentialsHandler] logout: sem token/tenant/baseUrl - pulando chamada remota',
        );
      }
    } catch (e) {
      debugPrint('[CredentialsHandler] logout: erro geral: $e');
    } finally {
      // Clear local token anyway
      await _storage.clearAuthToken();
      debugPrint('[CredentialsHandler] logout: token limpo localmente');
    }
  }
}
