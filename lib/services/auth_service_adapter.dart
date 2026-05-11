// lib/services/auth_service_adapter.dart

import '../domain/contracts/auth_service_contract.dart';
import '../data/models/tenant_model.dart';
import '../presentation/viewmodels/auth/auth_viewmodel.dart';

/// Adapter que implementa AuthServiceContract usando AuthViewModel
/// Permite injeção de dependências e melhora testabilidade
class AuthServiceAdapter implements AuthServiceContract {
  final AuthViewModel _authViewModel;

  AuthServiceAdapter(this._authViewModel);

  @override
  Future<Map<String, dynamic>> login(Tenant tenant, String email, String password) {
    return _authViewModel.login(tenant, email, password);
  }

  @override
  Future<String?> offlineLogin(Tenant requestedTenant, {String? email}) {
    return _authViewModel.offlineLogin(requestedTenant, email: email);
  }

  @override
  bool get isAuthenticated => _authViewModel.isAuthenticated;

  @override
  dynamic get currentUser => _authViewModel.currentUser;
}
