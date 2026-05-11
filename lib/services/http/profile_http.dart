// services/http/profile_http.dart
// ✅ SERVIÇO HTTP PARA GERENCIAMENTO DE PERFIL E SENHA

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../shared_preference_service.dart';
import '../../core/helpers/console_log.dart';
import '../storage/domain_storage.dart';
import '../../data/models/user_model.dart';
import '../../data/dao/user_dao.dart';
import '../../data/dao/tenant_config_dao.dart';

class ProfileHttp {
  final SharedPreferenceService _pref = SharedPreferenceService();
  final TenantConfigDao _tenantDao = TenantConfigDao();
  final DomainStorage _domainStorage = DomainStorage();
  final UserDao _userDao = UserDao();

  // ✅ OBTER TENANT DOMAIN (BD Local com fallback para SharedPreferences)
  Future<String> _getTenantDomain() async {
    try {
      // Tenta obter do banco de dados local primeiro
      final dbDomain = await _tenantDao.getSelectedDomain();
      if (dbDomain?.isNotEmpty == true) {
        ConsoleLog.informacao('🏢 Tenant do BD: $dbDomain');
        return dbDomain!;
      }
      
      // Fallback para SharedPreferences
      final prefDomain = _pref.getTenantDomain();
      if (prefDomain?.isNotEmpty == true) {
        ConsoleLog.informacao('💾 Tenant do SharedPreferences: $prefDomain');
        return prefDomain!;
      }
      
      ConsoleLog.error('❌ Nenhum tenant domain encontrado');
      return '';
    } catch (e) {
      ConsoleLog.error('❌ Erro ao obter tenant domain: $e');
      // Fallback final para SharedPreferences
      return _pref.getTenantDomain() ?? '';
    }
  }

  // ✅ OBTER DADOS DO PERFIL
  Future<http.Response> getProfile() async {
    await _pref.init();

    final token = _pref.getAccessToken();
    final tenantDomain = await _getTenantDomain();
    final baseUrl = dotenv.env['URL_BASE_API'];
    
    if (token == null || baseUrl == null) {
      throw Exception('Configuração inválida');
    }

    final correctedTenant = _getCorrectedTenantDomain(tenantDomain);
    final url = _normalizeUrl(baseUrl, 'api/v1/profile');

    final response = await http.get(
      Uri.parse(url),
      headers: _getHeaders(token, correctedTenant),
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('Timeout na requisição'),
    );

    ConsoleLog.informacao('📥 Profile GET Status: ${response.statusCode}');
    ConsoleLog.informacao('📥 Profile GET Body: ${response.body}');
    
    return response;
  }

  // ✅ ATUALIZAR DADOS DO PERFIL
  Future<http.Response> updateProfile({
    required String name,
    required String email,
  }) async {
    await _pref.init();

    final token = _pref.getAccessToken();
    final tenantDomain = await _getTenantDomain();
    final baseUrl = dotenv.env['URL_BASE_API'];
    
    if (token == null || baseUrl == null) {
      throw Exception('Configuração inválida');
    }

    final correctedTenant = _getCorrectedTenantDomain(tenantDomain);
    final url = _normalizeUrl(baseUrl, 'api/v1/profile');

    final response = await http.put(
      Uri.parse(url),
      headers: _getHeaders(token, correctedTenant),
      body: jsonEncode({
        'name': name,
        'email': email,
      }),
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('Timeout na requisição'),
    );

    ConsoleLog.informacao('📤 Profile PUT Status: ${response.statusCode}');
    ConsoleLog.informacao('📤 Profile PUT Body: ${response.body}');
    print('📤 Profile PUT Status: ${response.statusCode}');
    print('📤 Profile PUT Body: ${response.body}');
    
    // Se a atualização foi bem-sucedida, atualiza os dados no storage local
    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);
        ConsoleLog.informacao('📤 Response Data: ${responseData.toString()}');
        print('📤 Response Data: ${responseData.toString()}');
        print('📤 Response Keys: ${responseData.keys.toList()}');
        
        // Tenta diferentes chaves possíveis para os dados do usuário
        dynamic userData = responseData['user'] ?? 
                          responseData['data'] ?? 
                          responseData['profile'] ??
                          responseData;
        
        if (userData != null && userData != responseData) {
          ConsoleLog.informacao('📤 User Data Before Save: ${userData.toString()}');
          print('📤 User Data Before Save: ${userData.toString()}');
          
          // Converte Map para User se necessário
          User userToSave;
          if (userData is Map<String, dynamic>) {
            userToSave = User.fromMap(userData);
          } else if (userData is User) {
            userToSave = userData;
          } else {
            ConsoleLog.error('❌ Tipo de dado de usuário inválido: ${userData.runtimeType}');
            print('❌ Tipo de dado de usuário inválido: ${userData.runtimeType}');
            return response;
          }
          
          await _userDao.saveUser(userToSave); // Salva no SQLite
          await _domainStorage.saveUserData(userToSave); // Salva também no Secure Storage
          ConsoleLog.informacao('✅ Dados do usuário atualizados no SQLite e Secure Storage');
          print('✅ Dados do usuário atualizados no SQLite e Secure Storage');
        } else {
          // Se o servidor não retornou os dados, busca do servidor
          ConsoleLog.informacao('🔄 Servidor não retornou dados, buscando perfil atualizado...');
          print('🔄 Servidor não retornou dados, buscando perfil atualizado...');
          
          try {
            final profileResponse = await getProfile();
            if (profileResponse.statusCode == 200) {
              final profileData = json.decode(profileResponse.body);
              if (profileData['user'] != null) {
                final userFromProfile = User.fromMap(profileData['user']);
                await _userDao.saveUser(userFromProfile); // Salva no SQLite
                await _domainStorage.saveUserData(userFromProfile); // Salva também no Secure Storage
                ConsoleLog.informacao('✅ Dados atualizados via getProfile() no SQLite e Secure Storage');
                print('✅ Dados atualizados via getProfile() no SQLite e Secure Storage');
              }
            }
          } catch (e) {
            ConsoleLog.error('❌ Erro ao buscar perfil atualizado: $e');
            print('❌ Erro ao buscar perfil atualizado: $e');
          }
        }
      } catch (e) {
        ConsoleLog.error('❌ Erro ao atualizar dados no storage: $e');
        print('❌ Erro ao atualizar dados no storage: $e');
      }
    }
    
    return response;
  }

  // ✅ ATUALIZAR SENHA
  Future<http.Response> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _pref.init();

    final token = _pref.getAccessToken();
    final tenantDomain = await _getTenantDomain();
    final baseUrl = dotenv.env['URL_BASE_API'];
    
    if (token == null || baseUrl == null) {
      throw Exception('Configuração inválida');
    }

    final correctedTenant = _getCorrectedTenantDomain(tenantDomain);
    final url = _normalizeUrl(baseUrl, 'api/v1/profile/password');

    final response = await http.put(
      Uri.parse(url),
      headers: _getHeaders(token, correctedTenant),
      body: jsonEncode({
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('Timeout na requisição'),
    );

    ConsoleLog.informacao('🔐 Password PUT Status: ${response.statusCode}');
    ConsoleLog.informacao('🔐 Password PUT Body: ${response.body}');
    
    return response;
  }

  // ✅ EXCLUIR CONTA
  Future<http.Response> deleteAccount({required String password}) async {
    await _pref.init();

    final token = _pref.getAccessToken();
    final tenantDomain = await _getTenantDomain();
    final baseUrl = dotenv.env['URL_BASE_API'];
    
    if (token == null || baseUrl == null) {
      throw Exception('Configuração inválida');
    }

    final correctedTenant = _getCorrectedTenantDomain(tenantDomain);
    final url = _normalizeUrl(baseUrl, 'api/v1/profile');

    final response = await http.delete(
      Uri.parse(url),
      headers: _getHeaders(token, correctedTenant),
      body: jsonEncode({
        'password': password,
      }),
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('Timeout na requisição'),
    );

    ConsoleLog.informacao('🗑️ Account DELETE Status: ${response.statusCode}');
    ConsoleLog.informacao('🗑️ Account DELETE Body: ${response.body}');
    
    return response;
  }

  String _getCorrectedTenantDomain(String? tenantDomain) {
    // Retorna o tenant domain salvo no app, sem fallback para valor fixo
    return tenantDomain?.isNotEmpty == true ? tenantDomain! : '';
  }

  Map<String, String> _getHeaders(String token, String tenantDomain) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Host': tenantDomain,
    };
  }

  String _normalizeUrl(String baseUrl, String path) {
    if (!baseUrl.startsWith('http')) {
      baseUrl = baseUrl.contains('localhost') ? 'http://$baseUrl' : 'https://$baseUrl';
    }
    
    if (baseUrl.contains('localhost') && !baseUrl.contains(':8002')) {
      baseUrl = baseUrl.contains(':') ? baseUrl : '$baseUrl:8002';
    }
    
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    
    return '$cleanBaseUrl/$cleanPath';
  }
}
