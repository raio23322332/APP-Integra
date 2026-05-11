import 'dart:async';
import 'package:flutter/widgets.dart';

import 'package:integra_app/core/navigation/navigation_constants.dart';
import 'package:integra_app/data/models/tenant_model.dart';
import 'package:integra_app/domain/services/form_validation_service.dart';
import 'package:integra_app/domain/usecases/auth/login_usecase.dart';
import 'package:integra_app/presentation/viewmodels/base/base_form_viewmodel.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';
import 'package:integra_app/services/navigation_service.dart';
import 'package:integra_app/presentation/viewmodels/auth/auth_viewmodel.dart';

/// ViewModel de login - Implementação limpa e profissional
class LoginViewModel extends BaseFormViewModel {
  // Dependências injetadas
  final LoginUseCase _loginUseCase;
  final FormValidationService _validationService;
  final AuthViewModel _authViewModel;

  // Stream de eventos para comunicação com a View
  final _eventController = StreamController<ViewModelEvent>.broadcast();
  Stream<ViewModelEvent> get events => _eventController.stream;

  // Estado privado da UI
  String _email = '';
  String _password = '';
  bool _obscurePassword = true;
  Tenant? _tenant;

  // Getters públicos para View
  String get email => _email;
  String get password => _password;
  bool get obscurePassword => _obscurePassword;
  Tenant? get tenant => _tenant;

  // Construtor com injeção de dependências
  LoginViewModel({
    required LoginUseCase loginUseCase,
    required FormValidationService validationService,
    required AuthViewModel authViewModel,
  })  : _loginUseCase = loginUseCase,
        _validationService = validationService,
        _authViewModel = authViewModel;

  // Inicializa com o tenant selecionado
  void initialize(Tenant tenant) {
    _tenant = tenant;
  }

  // Métodos de two-way binding com View
  void updateEmail(String value) {
    _email = value.trim();
    final error = _validationService.validateEmail(_email);
    setFieldError('email', error);
    if (error == null) {
      clearFieldError('general');
    }
  }

  void updatePassword(String value) {
    _password = value;
    final error = _validationService.validatePassword(_password);
    setFieldError('password', error);
    if (error == null) {
      clearFieldError('general');
    }
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  @override
  bool validateForm() {
    clearErrors();

    final validation = _validationService.validateForm(
      email: _email,
      password: _password,
      tenant: _tenant,
    );

    validation.forEach((field, error) {
      if (error != null) {
        setFieldError(field, error);
      }
    });

    return !hasErrors;
  }

  @override
  Future<void> submitForm() async {
    print('🚀 LoginViewModel.submitForm: INÍCIO DO LOGIN');
    debugPrint('🔍 LoginViewModel.submitForm: INÍCIO');
    
    if (!validateForm()) {
      print('❌ LoginViewModel: Validação falhou');
      debugPrint('🔍 LoginViewModel.submitForm: Validação falhou');
      _emitEvent(
        ShowSnackBarEvent(
          'Verifique o e-mail e a senha informados.',
          isError: true,
        ),
      );
      return;
    }

    print('✅ LoginViewModel: Validação OK - iniciando login...');
    debugPrint('🔍 LoginViewModel.submitForm: Validação OK - iniciando login...');
    await executeWithLoading(() async {
      try {
        print('🔄 LoginViewModel: Chamando AuthViewModel.login...');
        
        // ✅ CORREÇÃO: Usar AuthViewModel diretamente em vez de LoginUseCase
        final result = await _authViewModel.login(_tenant!, _email, _password);
        
        print('📊 LoginViewModel: AuthViewModel result=${result['success']}');
        debugPrint('🔍 LoginViewModel.submitForm: AuthViewModel result=${result['success']}');
        
        if (result['success'] == true) {
          print('✅ LoginViewModel: Login sucesso - navegando para home');
          debugPrint('🔍 LoginViewModel.submitForm: Login sucesso - navegando para home');
          _handleLoginSuccess('Login realizado com sucesso!');
        } else {
          print('❌ LoginViewModel: Login falhou - ${result['message']}');
          debugPrint('🔍 LoginViewModel.submitForm: Login falhou - ${result['message']}');
          setLoading(false);
          final errorMessage = result['message'] ?? 'Erro ao fazer login. Tente novamente.';
          _emitEvent(ShowSnackBarEvent(errorMessage, isError: true));
          return;
        }
      } catch (e) {
        print('💥 LoginViewModel: ERRO CAPTURADO - $e');
        debugPrint('🔍 LoginViewModel.submitForm: ERRO CAPTURADO - $e');
        setLoading(false);
        _emitEvent(ShowSnackBarEvent('Erro inesperado: $e', isError: true));
        return;
      }
    });
    
    print('🏁 LoginViewModel.submitForm: FIM');
    debugPrint('🔍 LoginViewModel.submitForm: FIM');
  }

  void _handleLoginSuccess(String message) {
    debugPrint('🔍 LoginViewModel._handleLoginSuccess: INÍCIO - message="$message"');
    // ✅ REMOVIDO: Evitar duplicação de snackbar
    // A HomeScreen já trata eventos, vamos mostrar apenas um snackbar direto
    // _emitEvent(
    //   ShowSnackBarEvent(
    //     message,
    //     isError: false,
    //   ),
    // );

    debugPrint('🔍 LoginViewModel: Navegando para home em 500ms');
    // Navega para home após login bem-sucedido
    Future.delayed(const Duration(milliseconds: 500), () {
      debugPrint('🔍 LoginViewModel: Executando navegação para home');
      // ✅ CORREÇÃO: Usar '/' em vez de '/home'
      NavigationService.instance.navigateTo('/');
    });
  }

  void _emitEvent(ViewModelEvent event) {
    if (event is ShowSnackBarEvent) {
      debugPrint('🔍 LoginViewModel._emitEvent: ${event.runtimeType} isError=${event.isError} message="${event.message}"');
    } else {
      debugPrint('🔍 LoginViewModel._emitEvent: ${event.runtimeType}');
    }
    
    if (!_eventController.isClosed) {
      _eventController.add(event);
    } else {
      debugPrint('🔍 LoginViewModel._emitEvent: eventController está fechado!');
    }
  }

  // Método público para facilitar chamada da View
  Future<bool> performLogin() async {
    try {
      await submitForm();
      return true; // Success
    } catch (e) {
      return false; // Failure
    }
  }

  // Método para navegação
  void navigateToRegister() {
    // ✅ Navegação via NavigationService (sem violar arquitetura)
    if (_tenant != null) {
      NavigationService.instance.pushTo(
        NavigationConstants.cadastro,
        extra: _tenant,
      );
    }
  }

  // Método para voltar à seleção de tenant
  void navigateToTenantSelection() {
    // ✅ Navegação via NavigationService (sem violar arquitetura)
    NavigationService.instance.navigateTo(NavigationConstants.tenantSelect);
  }

  // Método para reset do formulário
  void resetForm() {
    _email = '';
    _password = '';
    _obscurePassword = true;
    clearErrors();
    notifyListeners();
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
