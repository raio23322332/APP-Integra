import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/contracts/storage_service_contract.dart';
import '../../../data/dao/user_dao.dart';
import '../../../services/auth/auth_service.dart' as auth_service;
import '../../../services/connectivity_service.dart';
import 'auth_state.dart';

/// Classe responsável pelo gerenciamento de conectividade
/// Separa a lógica de conectividade do ViewModel principal
class ConnectivityHandler {
  final AuthState _authState;
  final StorageServiceContract _domainStorage;
  final auth_service.AuthService _authService;
  final UserDao _userDao;
  final Future<void> _ready;

  ConnectivityService? _connectivityService;

  ConnectivityHandler(
    this._authState,
    this._domainStorage,
    this._authService,
    this._userDao,
    this._ready,
  );

  /// Inicializa o handler de conectividade
  void initialize() {
    try {
      // Usando o ConnectivityService simplificado (singleton)
      // A lógica de validação de token foi movida para outro lugar
      debugPrint('[ConnectivityHandler] Usando ConnectivityService simplificado');
    } catch (e) {
      debugPrint('[ConnectivityHandler] Erro ao inicializar: $e');
    }
  }

  /// Trata o resultado da validação de token
  void _handleValidationResult(Map<String, dynamic> result) async {
    final bool valid = result['valid'] == true;
    final int? status = result['statusCode'] is int ? result['statusCode'] as int : null;

    if (!valid) {
      if (status == 401) {
        // Token expirado - limpar dados
        await _domainStorage.clearAuthToken();
        _authState.clearUser();
        _authState.setError('Sessão expirada. Por favor, faça login novamente.');
      } else {
        // Outros erros - verificar se há token
        final token = await _domainStorage.getAuthToken();
        if (token == null || token.isEmpty) {
          debugPrint('[ConnectivityHandler] validateTokenAndSync: No token found. Ensuring user is logged out.');
          if (_authState.currentUser != null) {
            _authState.clearUser();
          }
        } else {
          debugPrint('[ConnectivityHandler] validateTokenAndSync: invalid but non-401 (status=$status). Preserving token for retry.');
        }
      }
    } else {
      // Token válido - recarregar usuário se necessário
      if (_authState.currentUser == null) {
        _authState.setCurrentUser(await _userDao.getCurrentUser());
      }
    }
  }

  /// Libera recursos
  void dispose() {
    // ConnectivityService simplificado não precisa dispose
    debugPrint('[ConnectivityHandler] Disposed');
  }
}
