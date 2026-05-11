import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../core/helpers/console_log.dart';

/// Classe responsável apenas pelo estado de autenticação
/// Mantém a separação de responsabilidades no padrão MVVM
class AuthState extends ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null && _currentUser!.token.isNotEmpty;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _justLoggedIn = false;
  bool get justLoggedIn => _justLoggedIn;

  // Método para atualizar o usuário atual
  void setCurrentUser(User? user, {bool fromLogin = false}) {
    _currentUser = user;
    ConsoleLog.debug('👤 AuthState.setCurrentUser: ${user?.email ?? 'null'} (authenticated: $isAuthenticated) fromLogin=$fromLogin');
    
    // ✅ CORREÇÃO: Só setar justLoggedIn se for explicitamente do login
    if (fromLogin) {
      setJustLoggedIn(true);
    }
    
    notifyListeners();
  }

  // Método para limpar erro
  void clearError() {
    _errorMessage = null;
    ConsoleLog.debug('🧹 AuthState.clearError');
    // Não notificar para evitar redirecionamento durante falhas de login
    // notifyListeners();
  }

  // Método para definir erro
  void setError(String message) {
    _errorMessage = message;
    ConsoleLog.debug('❌ AuthState.setError: $message');
    // Não notificar para evitar redirecionamento durante falhas de login
    // notifyListeners();
  }

  // Método para limpar usuário
  void clearUser() {
    _currentUser = null;
    _justLoggedIn = false;
    ConsoleLog.debug('🗑️ AuthState.clearUser: usuário removido');
    notifyListeners();
  }

  // Método para marcar que acabou de fazer login
  void setJustLoggedIn(bool value) {
    _justLoggedIn = value;
    ConsoleLog.debug('🎯 AuthState.setJustLoggedIn: $value');
    notifyListeners();
  }
}
