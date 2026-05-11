// lib/domain/services/form_validation_service.dart

import 'package:integra_app/domain/services/login_form_validator.dart';

/// Serviço centralizado para validação de formulários
/// Segue diretrizes MVVM: lógica de validação separada da UI
class FormValidationService {

  /// Valida campo de email
  String? validateEmail(String value) {
    return LoginFormValidator.validateEmail(value);
  }

  /// Valida campo de senha
  String? validatePassword(String value) {
    return LoginFormValidator.validatePassword(value);
  }

  /// Valida tenant
  String? validateTenant(dynamic tenant) {
    return LoginFormValidator.validateTenant(tenant);
  }

  /// Valida formulário completo
  Map<String, String?> validateForm({
    required String email,
    required String password,
    required dynamic tenant,
  }) {
    return LoginFormValidator.validateForm(
      email: email,
      password: password,
      tenant: tenant,
    );
  }

  /// Verifica se formulário tem erros
  bool hasErrors(Map<String, String?> validationResult) {
    return validationResult.values.any((error) => error != null && error.isNotEmpty);
  }

  /// Verifica se deve limpar erro geral baseado nos campos
  bool shouldClearGeneralError(Map<String, String?> allFieldsErrors) {
    // Se algum campo agora está válido, pode limpar erro geral
    return allFieldsErrors.values.any((error) => error == null);
  }
}
