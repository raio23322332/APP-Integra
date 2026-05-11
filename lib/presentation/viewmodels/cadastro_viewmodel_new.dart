import 'dart:async';
import 'dart:convert';    
import 'package:http/http.dart' as http;
import 'package:integra_app/core/navigation/navigation_constants.dart';
import 'package:integra_app/data/models/tenant_model.dart';
import 'package:integra_app/presentation/viewmodels/auth/auth_viewmodel.dart';
import 'package:integra_app/presentation/viewmodels/base_form_viewmodel.dart';
import 'package:integra_app/services/navigation_service.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';

class PasswordRulesState {
  final bool min6;
  final bool upperLower;
  final bool number;
  final bool special;
  final bool match;

  const PasswordRulesState({
    required this.min6,
    required this.upperLower,
    required this.number,
    required this.special,
    required this.match,
  });

  bool get isStrong => min6 && upperLower && number && special;
}

class CadastroViewModel extends BaseFormViewModel {
  final NavigationService _navigationService;
  final AuthViewModel _authViewModel;

  CadastroViewModel({
    required NavigationService navigationService,
    required AuthViewModel authViewModel,
  }) : _navigationService = navigationService,
       _authViewModel = authViewModel;

  // Form fields
  String _name = '';
  String _email = '';
  String _password = '';
  String _passwordConfirmation = '';
  String _cpf = '';
  String _phone = '';
  
  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // Field errors
  final Map<String, String> _fieldErrors = {};
  String? getFieldError(String field) => _fieldErrors[field];
  
  // Terms acceptance
  bool _termsAccepted = false;
  bool get termsAccepted => _termsAccepted;
  
  // Password rules
  PasswordRulesState _rules = const PasswordRulesState(
    min6: false,
    upperLower: false,
    number: false,
    special: false,
    match: false,
  );

  // Getters
  String get name => _name;
  String get email => _email;
  String get password => _password;
  String get passwordConfirmation => _passwordConfirmation;
  String get cpf => _cpf;
  String get phone => _phone;
  PasswordRulesState get rules => _rules;

  // Password visibility
  bool _obscurePassword = true;
  bool _obscurePasswordConfirmation = true;
  
  bool get obscurePassword => _obscurePassword;
  bool get obscurePasswordConfirmation => _obscurePasswordConfirmation;
  
  final _eventController = StreamController<ViewModelEvent>.broadcast();
  Stream<ViewModelEvent> get events => _eventController.stream;
  
  bool _isDisposed = false;
  
  @override
  void dispose() {
    _eventController.close();
    _isDisposed = true;
    super.dispose();
  }
  
  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }
  
  void updateName(String value) {
    _name = value.trim();
    _clearFieldError('name');
    notifyListeners();
  }
  
  void updateEmail(String value) {
    _email = value.trim();
    _clearFieldError('email');
    notifyListeners();
  }
  
  void updatePassword(String value) {
    _password = value;
    _clearFieldError('password');
    _clearFieldError('password_confirmation');
    _recalcRules();
    notifyListeners();
  }
  
  void updatePasswordConfirmation(String value) {
    _passwordConfirmation = value;
    _clearFieldError('password_confirmation');
    _recalcRules();
    notifyListeners();
  }
  
  void updateCpf(String value) {
    _cpf = value.trim();
    _clearFieldError('cpf');
    notifyListeners();
  }
  
  void updatePhone(String value) {
    _phone = value.trim();
    _clearFieldError('phone');
    notifyListeners();
  }
  
  void setTermsAccepted(bool value) {
    _termsAccepted = value;
    notifyListeners();
  }
  
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }
  
  void togglePasswordConfirmationVisibility() {
    _obscurePasswordConfirmation = !_obscurePasswordConfirmation;
    notifyListeners();
  }
  
  void _clearFieldError(String field) {
    if (_fieldErrors.containsKey(field)) {
      _fieldErrors.remove(field);
      notifyListeners();
    }
  }
  
  void _clearAllErrors() {
    if (_fieldErrors.isNotEmpty) {
      _fieldErrors.clear();
      notifyListeners();
    }
  }
  
  void _setFieldError(String field, String error) {
    _fieldErrors[field] = error;
    notifyListeners();
  }
  
  void _setGeneralError(String error) {
    _setFieldError('general', error);
  }
  
  void _recalcRules() {
    final senha = _password;
    final confirmar = _passwordConfirmation;

    _rules = PasswordRulesState(
      min6: senha.length >= 6,
      upperLower: senha.contains(RegExp(r'[a-z]')) && senha.contains(RegExp(r'[A-Z]')),
      number: senha.contains(RegExp(r'[0-9]')),
      special: senha.contains(RegExp(r'[!@#\$&*~]')),
      match: senha.isNotEmpty && senha == confirmar,
    );
  }
  
  bool _validateForm() {
    _clearAllErrors();
    bool isValid = true;
    
    // Name validation
    if (_name.isEmpty) {
      _setFieldError('name', 'O nome é obrigatório');
      isValid = false;
    } else if (_name.length < 3) {
      _setFieldError('name', 'O nome deve ter pelo menos 3 caracteres');
      isValid = false;
    }
    
    // CPF validation
    if (_cpf.isEmpty) {
      _setFieldError('cpf', 'O CPF é obrigatório');
      isValid = false;
    }
    
    // Phone validation
    if (_phone.isEmpty) {
      _setFieldError('phone', 'O telefone é obrigatório');
      isValid = false;
    }
    
    // Email validation
    if (_email.isEmpty) {
      _setFieldError('email', 'O e-mail é obrigatório');
      isValid = false;
    } else if (!_email.contains('@') || !_email.contains('.')) {
      _setFieldError('email', 'Digite um e-mail válido');
      isValid = false;
    }
    
    // Password validation
    if (_password.isEmpty) {
      _setFieldError('password', 'A senha é obrigatória');
      isValid = false;
    } else if (_password.length < 6) {
      _setFieldError('password', 'A senha deve ter pelo menos 6 caracteres');
      isValid = false;
    }
    
    // Password confirmation validation
    if (_passwordConfirmation.isEmpty) {
      _setFieldError('password_confirmation', 'A confirmação de senha é obrigatória');
      isValid = false;
    } else if (_password != _passwordConfirmation) {
      _setFieldError('password_confirmation', 'As senhas não coincidem');
      isValid = false;
    }
    
    // Terms validation
    if (!_termsAccepted) {
      _setGeneralError('Você deve aceitar os Termos de Uso e Aviso de Privacidade');
      isValid = false;
    }
    
    return isValid;
  }
  
  Future<void> submit({
    required Tenant tenant,
    required bool formIsValid,
    required String email,
    required String password,
    required String name,
    required String cpf,
    required String phone,
  }) async {
    if (!_validateForm()) {
      return;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await http.post(
        Uri.parse('https://your-domain.com/api/v1/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        _emitEvent(ShowSnackBarEvent('Cadastro realizado com sucesso! Verifique seu e-mail.', isError: false));
        
        // Navigate to login after successful registration
        await Future.delayed(const Duration(seconds: 2));
        _navigationService.navigateTo(NavigationConstants.login);
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage = 'Erro ao realizar cadastro';
        
        if (responseData is Map && responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        } else if (responseData is Map && responseData.containsKey('errors')) {
          final errors = responseData['errors'];
          if (errors is Map) {
            errorMessage = errors.values.first?.toString() ?? errorMessage;
          }
        }
        
        _setGeneralError(errorMessage);
      }
    } on TimeoutException {
      _setGeneralError('Tempo limite excedido. Verifique sua conexão.');
    } catch (error) {
      _setGeneralError('Erro de conexão. Tente novamente mais tarde.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void _emitEvent(ViewModelEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  // Validation methods for backward compatibility
  String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) return 'O nome é obrigatório.';
    if (name.trim().length < 3) return 'O nome deve ter pelo menos 3 caracteres';
    return null;
  }

  String? validateCpf(String? cpf) {
    if (cpf == null || cpf.trim().isEmpty) return 'O CPF é obrigatório.';
    return null;
  }

  String? validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return 'O telefone é obrigatório.';
    return null;
  }

  String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) return 'O e-mail é obrigatório.';
    if (!email.contains('@') || !email.contains('.')) return 'Digite um e-mail válido';
    return null;
  }

  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) return 'A senha é obrigatória.';
    if (password.length < 6) return 'A senha deve ter pelo menos 6 caracteres.';
    if (!rules.isStrong) return 'A senha não atende aos requisitos.';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirme sua senha.';
    if (!rules.match) return 'As senhas não coincidem.';
    return null;
  }

  @override
  bool validateForm() {
    return !hasErrors;
  }

  @override
  Future<void> submitForm() async {
    // Não implementado diretamente, pois submit é chamado da View com parâmetros
  }
}
