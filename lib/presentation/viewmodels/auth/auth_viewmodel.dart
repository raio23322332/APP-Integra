import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/contracts/storage_service_contract.dart';
import '../../../data/dao/user_dao.dart';
import '../../../data/models/tenant_model.dart';
import '../../../data/models/user_model.dart';
import '../../../presentation/widgets/shared/custom_snack_bar.dart';
import '../../../services/auth/auth_service.dart' as auth_service;
import 'auth_state.dart';
import 'auth_actions.dart';
import 'connectivity_handler.dart';

/// ViewModel principal de autenticação - refatorado para MVVM
/// Agora usa composição para delegar responsabilidades específicas
class AuthViewModel extends ChangeNotifier {
  // Composição: AuthViewModel delega para classes especializadas
  late final AuthState _authState;
  late final AuthActions _authActions;
  late final ConnectivityHandler _connectivityHandler;

  // Flag para controlar notificações em lote
  bool _isBatchUpdating = false;
  bool _needsNotify = false;

  // Flag para controlar o estado de inicialização
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  AuthViewModel(StorageServiceContract domainStorage, auth_service.AuthService authService) {
    // Cria estado compartilhado
    _authState = AuthState();

    // Cria completer para sincronização
    final readyCompleter = Completer<void>();

    // Cria ações e conectividade com estado compartilhado
    _authActions = AuthActions(
      _authState,
      domainStorage,
      authService,
      UserDao(),
      readyCompleter,
    );
    _connectivityHandler = ConnectivityHandler(
      _authState,
      domainStorage,
      authService,
      UserDao(),
      readyCompleter.future,
    );

    // Inicializa conectividade
    _connectivityHandler.initialize();

    // Quando o completer terminar, a inicialização está concluída.
    readyCompleter.future.then((_) {
      if (_isInitializing) {
        _isInitializing = false;
        notifyListeners(); // Notifica o router que pode prosseguir
      }
    });

    // Escuta mudanças de estado para notificar listeners
    _authState.addListener(notifyListeners);
  }

  // Delegate getters to state
  User? get currentUser => _authState.currentUser;
  bool get isAuthenticated => _authState.isAuthenticated;
  String? get errorMessage => _authState.errorMessage;

  // ------------------------------------------------------------
  // Delegate actions to specialized classes
  // ------------------------------------------------------------
  Future<Map<String, dynamic>> login(
    Tenant tenant,
    String email,
    String password,
  ) => _authActions.login(tenant, email, password);

  Future<String?> register(
    Tenant tenant,
    String email,
    String password,
    String name,
    String cpf,
    String phone,
  ) => _authActions.register(tenant, email, password, name, cpf, phone);

  Future<void> logout() => _authActions.logout();

  Future<void> loadCurrentUser() => _authActions.loadCurrentUser();

  Future<String?> offlineLogin(Tenant requestedTenant, {String? email}) =>
      _authActions.offlineLogin(requestedTenant, email: email);

  Future<void> deleteCurrentUser() => _authActions.deleteCurrentUser();

  // ------------------------------------------------------------ PERMISSIONS
  bool hasPermission(String permission) => _authActions.hasPermission(permission);
  bool hasRole(String role) => _authActions.hasRole(role);

  // ------------------------------------------------------------ LOGIN STATUS
  bool get justLoggedIn => _authState.justLoggedIn;
  void clearJustLoggedIn() => _authState.setJustLoggedIn(false);

  // ------------------------------------------------------------ SNACKBAR
  void showLoginSuccessSnackBar(BuildContext context) {
    print('🎯 AuthViewModel.showLoginSuccessSnackBar: justLoggedIn=${_authState.justLoggedIn}');
    debugPrint('🔍 AuthViewModel.showLoginSuccessSnackBar: justLoggedIn=${_authState.justLoggedIn}');
    // ✅ CORREÇÃO: Verificar se ainda está logado para evitar duplicação
    if (_authState.justLoggedIn) {
      print('✅ AuthViewModel: Mostrando snackbar de sucesso');
      debugPrint('🔍 AuthViewModel: Mostrando snackbar de sucesso');
      CustomSnackBar.showSuccess(context, 'Login realizado com sucesso! Bem-vindo!');
      print('🧹 AuthViewModel: Limpando justLoggedIn');
      debugPrint('🔍 AuthViewModel: Limpando justLoggedIn');
      clearJustLoggedIn();
    } else {
      print('❌ AuthViewModel: justLoggedIn é false, não mostrando snackbar');
      debugPrint('🔍 AuthViewModel: justLoggedIn é false, não mostrando snackbar');
    }
  }

  void showLoginErrorSnackBar(BuildContext context, String message) {
    CustomSnackBar.showError(context, message);
  }

  // ------------------------------------------------------------ USER MANAGEMENT
  Future<void> saveUserAfterLogin(User user) async {
    // Salvar usuário no banco local
    final userDao = UserDao();
    await userDao.saveUser(user);
    // Atualizar estado sem notificar (evita redirecionamento prematuro)
    _authState.setCurrentUser(user, fromLogin: true);
    // Notificar apenas após sucesso completo do login
    notifyListeners();
  }

  // Métodos para controlar notificações em lote
  void startBatchUpdate() {
    _isBatchUpdating = true;
    _needsNotify = false;
  }

  void endBatchUpdate() {
    _isBatchUpdating = false;
    if (_needsNotify) {
      super.notifyListeners();
      _needsNotify = false;
    }
  }

  @override
  void notifyListeners() {
    if (_isBatchUpdating) {
      _needsNotify = true;
    } else {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectivityHandler.dispose();
    super.dispose();
  }
}
