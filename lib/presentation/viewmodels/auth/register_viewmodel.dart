import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:integra_app/core/navigation/navigation_constants.dart';
import 'package:integra_app/services/navigation_service.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';

class RegisterViewModel extends ChangeNotifier {
  final NavigationService _navigationService;
  
  RegisterViewModel(this._navigationService);

  // Form fields
  String _name = '';
  String _email = '';
  String _password = '';
  String _passwordConfirmation = '';
  
  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // Field errors
  final Map<String, String> _fieldErrors = {};
  String? getFieldError(String field) => _fieldErrors[field];
  
  // Getters
  String get name => _name;
  String get email => _email;
  String get password => _password;
  String get passwordConfirmation => _passwordConfirmation;
  
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
    notifyListeners();
  }
  
  void updatePasswordConfirmation(String value) {
    _passwordConfirmation = value;
    _clearFieldError('password_confirmation');
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
    
    return isValid;
  }
  
  Future<void> performRegister() async {
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
          'name': _name,
          'email': _email,
          'password': _password,
          'password_confirmation': _passwordConfirmation,
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
  
  void navigateToLogin() {
    _navigationService.navigateTo(NavigationConstants.login);
  }
  
  void _emitEvent(ViewModelEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }
}
