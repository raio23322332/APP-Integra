// lib/domain/services/login_authentication_service.dart

import 'package:flutter/foundation.dart';
import 'package:integra_app/data/models/user_model.dart';
import 'package:integra_app/data/models/tenant_model.dart';
import 'package:integra_app/core/contracts/auth_service_contract.dart';
import 'package:integra_app/domain/contracts/auth_service_contract.dart' show AuthServiceContract;

/// Serviço responsável pela lógica de autenticação de login
/// Separa a responsabilidade de autenticação do ViewModel
class LoginAuthenticationService {
  final AuthServiceContract _authService;

  LoginAuthenticationService(this._authService);

  /// Executa o fluxo completo de autenticação (online → offline fallback)
  Future<AuthenticationResult> authenticate({
    required Tenant tenant,
    required String email,
    required String password,
  }) async {
    try {
      // Tenta login online primeiro
      debugPrint('🔐 LoginAuthenticationService: Chamando _authService.login');
      final loginResult = await _authService.login(tenant, email, password);
      debugPrint('🔐 LoginAuthenticationService: loginResult=$loginResult');

      if (loginResult['success'] == true) {
        debugPrint('🔐 LoginAuthenticationService: Login sucesso - processando dados');
        // ✅ DEBUG: Verificar campos antes do type cast
        debugPrint('🔐 LoginAuthenticationService: loginResult keys=${loginResult.keys.toList()}');
        debugPrint('🔐 LoginAuthenticationService: access_token=${loginResult['access_token']} (${loginResult['access_token'].runtimeType})');
        debugPrint('🔐 LoginAuthenticationService: user=${loginResult['user']} (${loginResult['user'].runtimeType})');
        
        // ✅ CORREÇÃO: Verificar se access_token não é null
        if (loginResult['access_token'] == null) {
          debugPrint('❌ LoginAuthenticationService: access_token é null');
          return AuthenticationResult.failure('Token de acesso não recebido');
        }
        
        final token = loginResult['access_token'] as String;
        
        // ✅ CORREÇÃO: Verificar se user não é null
        if (loginResult['user'] == null) {
          debugPrint('❌ LoginAuthenticationService: user é null');
          return AuthenticationResult.failure('Dados do usuário não recebidos');
        }
        
        final userData = loginResult['user'] as Map<String, dynamic>;

        debugPrint('🔐 LoginAuthenticationService: token="$token" userData=$userData');

        final loggedUser = User(
          id: userData['id'] as int?,
          email: email,
          token: token,
          name: userData['name'] ?? '',
          cpf: userData['cpf'] ?? '',
          roles: (userData['roles'] as List?)?.map((e) => e.toString()).toList() ?? [],
          permissions: (userData['permissions'] as List?)?.map((e) => e.toString()).toList() ?? [],
        );

        debugPrint('✅ LoginAuthenticationService: Sucesso completo - user=${loggedUser.email}');
        return AuthenticationResult.success(
          type: AuthType.online,
          message: 'Login realizado com sucesso!',
          user: loggedUser,
        );
      } else {
        // Falha online - verifica se pode tentar offline
        final reason = loginResult['reason'] ?? '';
        if (_shouldTryOffline(reason)) {
          return await _tryOfflineAuthentication(tenant, email);
        } else {
          return AuthenticationResult.failure(
            loginResult['message'] ?? 'Erro de autenticação',
          );
        }
      }
    } catch (e) {
      // Erro de rede - tenta offline
      if (_isNetworkError(e)) {
        return await _tryOfflineAuthentication(tenant, email);
      } else {
        return AuthenticationResult.failure(
          'Erro inesperado: ${e.toString()}',
        );
      }
    }
  }

  /// Tenta autenticação offline
  Future<AuthenticationResult> _tryOfflineAuthentication(
    Tenant tenant,
    String email,
  ) async {
    try {
      final offlineResult = await _authService.offlineLogin(tenant, email: email);

      if (offlineResult == null) {
        return AuthenticationResult.success(
          type: AuthType.offline,
          message: 'Login offline realizado com sucesso!',
        );
      } else {
        return AuthenticationResult.failure(
          _getOfflineErrorMessage(offlineResult),
        );
      }
    } catch (e) {
      return AuthenticationResult.failure(
        'Erro no modo offline: ${e.toString()}',
      );
    }
  }

  /// Verifica se deve tentar login offline baseado na razão da falha
  bool _shouldTryOffline(String reason) {
    return reason.toLowerCase().contains('network') ||
        reason.toLowerCase().contains('connection') ||
        reason.toLowerCase().contains('timeout') ||
        reason.toLowerCase().contains('dns') ||
        reason.toLowerCase().contains('failed host lookup');
  }

  /// Verifica se o erro é de rede
  bool _isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('socket') ||
        errorString.contains('dns');
  }

  /// Converte mensagens de erro offline para mensagens user-friendly
  String _getOfflineErrorMessage(String error) {
    if (error.contains('Nenhuma sessão offline disponível')) {
      return 'Modo offline indisponível. Primeiro login requer conexão com internet.';
    } else if (error.contains('disponível apenas para o tenant')) {
      return 'Login offline disponível apenas para o último município utilizado.';
    } else if (error.contains('correspondem')) {
      return 'Email não corresponde à sessão offline disponível.';
    } else {
      return error;
    }
  }
}

/// Tipos de autenticação
enum AuthType { online, offline }

/// Resultado da autenticação
class AuthenticationResult {
  final bool success;
  final AuthType? type;
  final String? message;
  final String? error;
  final User? user;

  const AuthenticationResult.success({
    required this.type,
    required this.message,
    this.user,
  })  : success = true,
        error = null;

  const AuthenticationResult.failure(this.error)
      : success = false,
        type = null,
        message = null,
        user = null;
}
