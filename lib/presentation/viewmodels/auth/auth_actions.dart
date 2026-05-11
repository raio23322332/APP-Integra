import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/contracts/storage_service_contract.dart';
import '../../../data/dao/user_dao.dart';
import '../../../data/models/tenant_model.dart';
import '../../../data/models/user_model.dart';
import '../../../services/auth/auth_service.dart' as auth_service;
import 'auth_state.dart';

/// Classe responsável pelas ações de autenticação
/// Separa a lógica de negócio do estado
class AuthActions {
  final AuthState _authState;
  final StorageServiceContract _domainStorage;
  final auth_service.AuthService _authService;
  final UserDao _userDao;
  final Completer<void> _readyCompleter;

  AuthActions(
    this._authState,
    this._domainStorage,
    this._authService,
    this._userDao,
    this._readyCompleter,
  );

  // ------------------------------------------------------------ LOGIN
  Future<Map<String, dynamic>> login(
    Tenant tenant,
    String email,
    String password,
  ) async {
    print('🔐 AuthActions.login: INÍCIO - email=$email');
    _authState.clearError();

    final result = await _authService.login(tenant, email, password);
    print('🔐 AuthActions: AuthService result=${result['success']}');

    if (result['success'] == true) {
      print('✅ AuthActions: Login sucesso - processando usuário');
      final token = result['access_token'] as String;
      final userData = result['user'] as Map<String, dynamic>;

      final loggedUser = User(
        id: userData['id'] as int?,
        email: email,
        token: token,
        name: userData['name'] ?? '',
        cpf: userData['cpf'] ?? '',
        roles: (userData['roles'] as List?)?.map((e) => e.toString()).toList() ?? [],
        permissions: (userData['permissions'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );

      await _userDao.saveUser(loggedUser);
      _authState.setCurrentUser(loggedUser, fromLogin: true);
      print('🎯 AuthActions: Chamando setCurrentUser com fromLogin=true');

      return {'success': true, 'reason': result['reason'] ?? 'ok'};
    } else {
      print('❌ AuthActions: Login falhou - ${result['message']}');
      _authState.setError(result['message'] ?? 'Erro ao fazer login.');
      // _authState.clearUser(); // NÃO limpe o usuário em uma falha simples de login (ex: senha errada).
                               // Isso estava causando o redirecionamento para a tela de tenancy,
                               // pois o AuthState mudava para não autenticado e o router reconstruía a rota.
      return {
        'success': false,
        'reason': result['reason'] ?? 'unknown',
        'message': _authState.errorMessage,
      };
    }
  }

  // ------------------------------------------------------------ REGISTER
  Future<String?> register(
    Tenant tenant,
    String email,
    String password,
    String name,
    String cpf,
    String phone,
  ) async {
    _authState.clearError();

    final result = await _authService.register(
      tenant,
      email,
      password,
      name,
      cpf,
      phone,
    );

    if (result['success'] == true) {
      return null; // Sucesso
    } else {
      _authState.setError(result['message'] ?? 'Erro desconhecido ao registrar.');
      return _authState.errorMessage;
    }
  }

  // ------------------------------------------------------------ LOGOUT
  Future<void> logout() async {
    await _authService.logout();
    await _userDao.deleteUser();
    await _domainStorage.clearUserData(); // Limpar dados do usuário no secure storage
    _authState.clearUser();
  }

  // ------------------------------------------------------------ OFFLINE LOGIN
  Future<String?> offlineLogin(Tenant requestedTenant, {String? email}) async {
    debugPrint('[AuthActions] offlineLogin: Iniciando login offline');
    _authState.clearError();

    final storedDomain = await _domainStorage.getSelectedDomain();
    debugPrint('[AuthActions] offlineLogin: storedDomain = $storedDomain');
    if (storedDomain == null) {
      _authState.setError('Nenhuma sessão offline disponível.');
      return _authState.errorMessage;
    }

    final requestedDomain = requestedTenant.devDomain ??
                           requestedTenant.primaryDomain ??
                           requestedTenant.urlSubdomainBase;
    debugPrint('[AuthActions] offlineLogin: requestedDomain = $requestedDomain');

    if (requestedDomain == null || requestedDomain.isEmpty) {
      _authState.setError('Tenant sem domínio configurado.');
      return _authState.errorMessage;
    }

    if (storedDomain != requestedDomain) {
      _authState.setError('Sessão offline disponível apenas para o tenant previamente usado.');
      return _authState.errorMessage;
    }

    final result = await _authService.offlineLogin();
    debugPrint('[AuthActions] offlineLogin: resultado do _authService.offlineLogin = $result');

    if (result['success'] == true) {
      final userMap = result['user'] as Map<String, dynamic>?;
      debugPrint('[AuthActions] offlineLogin: userMap = $userMap');

      if (userMap != null) {
        if (email != null && email.trim().isNotEmpty) {
          final storedEmail = (userMap['email'] ?? '').toString().trim().toLowerCase();
          if (storedEmail.isEmpty || storedEmail != email.trim().toLowerCase()) {
            _authState.setError('As credenciais não correspondem à sessão offline disponível.');
            return _authState.errorMessage;
          }
        }

        final user = User(
          id: userMap['id'] as int?,
          email: (userMap['email'] ?? '') as String,
          token: (userMap['token'] as String?) ?? '',
          name: userMap['name'] as String?,
          cpf: userMap['cpf'] as String?,
          roles: (userMap['roles'] is String)
              ? (userMap['roles'] as String).split(',').where((e) => e.isNotEmpty).toList()
              : (userMap['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          permissions: (userMap['permissions'] is String)
              ? (userMap['permissions'] as String).split(',').where((e) => e.isNotEmpty).toList()
              : (userMap['permissions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        );

        debugPrint('[AuthActions] offlineLogin: Salvando usuário: ${user.email}');
        await _userDao.saveUser(user);
        _authState.setCurrentUser(user, fromLogin: false); // Offline login não seta justLoggedIn

        debugPrint('[AuthActions] offlineLogin: Usuário definido no estado, isAuthenticated = ${_authState.isAuthenticated}');
        debugPrint('[AuthActions] offlineLogin: currentUser = ${_authState.currentUser?.email}');
        return null;
      }

      _authState.setError(result['message'] ?? 'Login offline falhou.');
      return _authState.errorMessage;
    }

    _authState.setError(result['message'] ?? 'Nenhuma sessão offline disponível.');
    return _authState.errorMessage;
  }

  // ------------------------------------------------------------ SESSION MANAGEMENT
  Future<void> loadCurrentUser() async {
    debugPrint('[AuthActions] loadCurrentUser: iniciando restauração de usuário');

    _authState.setCurrentUser(await _userDao.getCurrentUser());
    debugPrint('[AuthActions] loadCurrentUser: usuário no SQLite? ${_authState.currentUser != null}');

    if (_authState.currentUser == null) {
      await _restoreUserFromSecureStorage();
    } else {
      await _updateTokenFromSecureStorageIfNeeded();
    }

    // Validação final - não limpar sessões offline
    if (_authState.currentUser != null && _authState.currentUser!.token.isEmpty) {
      // Verificar se há dados do usuário salvos (modo offline)
      final storedUser = await _domainStorage.getUserData();
      if (storedUser != null) {
        debugPrint('[AuthActions] loadCurrentUser: usuário sem token mas com dados offline -> mantendo sessão');
        // Manter a sessão para modo offline
      } else {
        debugPrint('[AuthActions] loadCurrentUser: usuário sem token e sem dados -> limpando sessão local');
        _authState.clearUser();
      }
    }

    if (!_readyCompleter.isCompleted) {
      try {
        _readyCompleter.complete();
      } catch (_) {}
    }
  }

  Future<void> _restoreUserFromSecureStorage() async {
    try {
      final storedUser = await _domainStorage.getUserData();
      final storedToken = await _domainStorage.getAuthToken();
      debugPrint('[AuthActions] loadCurrentUser: storedUser? ${storedUser != null} storedToken? ${storedToken != null}');

      if (storedUser != null) {
        final userFromStorage = User.fromMap(storedUser);
        final merged = User(
          id: userFromStorage.id,
          email: userFromStorage.email,
          token: userFromStorage.token.isNotEmpty ? userFromStorage.token : (storedToken ?? ''),
          name: userFromStorage.name,
          cpf: userFromStorage.cpf,
          roles: userFromStorage.roles,
          permissions: userFromStorage.permissions,
        );

        await _userDao.saveUser(merged);
        _authState.setCurrentUser(merged);
        debugPrint('[AuthActions] Usuário restaurado do secure storage e salvo no SQLite.');
      }
    } catch (e) {
      debugPrint('[AuthActions] Erro ao restaurar usuário: $e');
    }
  }

  Future<void> _updateTokenFromSecureStorageIfNeeded() async {
    try {
      if (_authState.currentUser!.token.isEmpty) {
        final storedToken = await _domainStorage.getAuthToken();
        if (storedToken != null && storedToken.isNotEmpty) {
          final updated = User(
            id: _authState.currentUser!.id,
            email: _authState.currentUser!.email,
            token: storedToken,
            name: _authState.currentUser!.name,
            cpf: _authState.currentUser!.cpf,
            roles: _authState.currentUser!.roles,
            permissions: _authState.currentUser!.permissions,
          );
          await _userDao.saveUser(updated);
          _authState.setCurrentUser(updated);
          debugPrint('[AuthActions] Token mesclado do secure storage no usuário do DB.');
        }
      }
    } catch (_) {}
  }

  Future<void> deleteCurrentUser() async {
    await _userDao.deleteUser();
    _authState.clearUser();
  }

  // ------------------------------------------------------------ PERMISSIONS
  bool hasPermission(String permission) {
    return _authState.currentUser?.permissions.contains(permission) ?? false;
  }

  bool hasRole(String role) {
    return _authState.currentUser?.roles.contains(role) ?? false;
  }
}
