// lib/presentation/viewmodels/profile/profile_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/shared/view_model_event.dart';
import '../auth/auth_viewmodel.dart';
import '../../../services/navigation_service.dart';

/// ViewModel para a tela de perfil
/// Gerencia estado e ações da tela de perfil seguindo MVVM
class ProfileViewModel extends ChangeNotifier {
  final AuthViewModel _authViewModel;
  final NavigationService _navigationService;
  late VoidCallback _authListener;

  ProfileViewModel({
    required AuthViewModel authViewModel,
    required NavigationService navigationService,
  })  : _authViewModel = authViewModel,
        _navigationService = navigationService {
    // Ouve mudanças no AuthViewModel para notificar listeners do ProfileViewModel
    _authListener = () {
      print('🔄 ProfileViewModel: AuthViewModel mudou, notificando listeners');
      print('🔄 ProfileViewModel: Usuário atual: ${_authViewModel.currentUser?.toString()}');
      notifyListeners();
    };
    _authViewModel.addListener(_authListener);
  }

  // Stream para eventos de navegação e feedback
  final _eventController = StreamController<ViewModelEvent>.broadcast();
  Stream<ViewModelEvent> get events => _eventController.stream;

  // Delegate para AuthViewModel
  dynamic get currentUser => _authViewModel.currentUser;
  bool get isAuthenticated => _authViewModel.isAuthenticated;
  AuthViewModel get authViewModel => _authViewModel;

  @override
  void dispose() {
    print('🔄 ProfileViewModel: Removendo listener do AuthViewModel');
    _authViewModel.removeListener(_authListener);
    _eventController.close();
    super.dispose();
  }

  // ------------------------------------------------------------ AÇÕES

  /// Navega para a lista de protocolos/solicitações
  void navigateToProtocols() {
    _navigationService.navigateTo('/minhas-solicitacoes');
  }

  /// Realiza logout e navega para login
  Future<void> logout() async {
    try {
      await _authViewModel.logout();
      // ✅ Navegação via evento - permite que a View decida como navegar
      _emitEvent(NavigateToLoginEvent());
    } catch (e) {
      _emitEvent(ShowSnackBarEvent('Erro ao fazer logout: $e', isError: true));
    }
  }

  /// Placeholder para edição de perfil (futuro)
  void navigateToProfileEdit() {
    _navigationService.pushTo('/edit-profile');
  }

  /// Navega para as configurações de segurança e senha
  void navigateToSecuritySettings() {
    _navigationService.pushTo('/security');
  }

  void _emitEvent(ViewModelEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }
}
