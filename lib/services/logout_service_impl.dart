// lib/services/logout_service_impl.dart

import 'package:integra_app/domain/contracts/logout_service.dart';
import 'package:integra_app/presentation/viewmodels/auth/auth_viewmodel.dart';

/// Implementação concreta do LogoutService usando AuthViewModel
class LogoutServiceImpl implements LogoutService {
  final AuthViewModel _authViewModel;

  LogoutServiceImpl(this._authViewModel);

  @override
  Future<void> logout() async {
    await _authViewModel.logout();
  }
}
