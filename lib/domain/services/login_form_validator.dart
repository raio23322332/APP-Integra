// lib/domain/services/login_form_validator.dart

/// Serviço responsável pela validação de formulários de login
/// Separa a responsabilidade de validação do ViewModel
class LoginFormValidator {
  /// Valida email do usuário
  static String? validateEmail(String value) {
    if (value.isEmpty) return 'Por favor, insira seu e-mail.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'Por favor, insira um e-mail válido.';
    }
    return null;
  }

  /// Valida senha do usuário
  static String? validatePassword(String value) {
    if (value.isEmpty) return 'A senha é obrigatória.';
    if (value.length < 8) return 'A senha deve ter pelo menos 8 caracteres.';
    return null;
  }

  /// Valida tenant
  static String? validateTenant(dynamic tenant) {
    if (tenant == null) return 'Tenant não configurado';
    return null;
  }

  /// Valida formulário completo
  static Map<String, String?> validateForm({
    required String email,
    required String password,
    required dynamic tenant,
  }) {
    return {
      'email': validateEmail(email),
      'password': validatePassword(password),
      'tenant': validateTenant(tenant),
    };
  }
}
