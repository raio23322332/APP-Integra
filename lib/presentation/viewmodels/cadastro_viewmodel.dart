import 'package:integra_app/data/models/tenant_model.dart';
import 'package:integra_app/domain/usecases/auth/register_usecase.dart';
import 'package:integra_app/presentation/routes/app_router.dart';
import 'package:integra_app/presentation/viewmodels/auth/auth_viewmodel.dart';
import 'package:integra_app/presentation/viewmodels/base_form_viewmodel.dart';
import 'package:integra_app/services/navigation_service.dart';

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
  final RegisterUseCase _registerUseCase;
  final AuthViewModel _authViewModel;

  CadastroViewModel({
    required RegisterUseCase registerUseCase,
    required AuthViewModel authViewModel,
  })  : _registerUseCase = registerUseCase,
        _authViewModel = authViewModel;

  bool _termsAccepted = false;

  String _password = '';
  String _confirmPassword = '';

  PasswordRulesState _rules = const PasswordRulesState(
    min6: false,
    upperLower: false,
    number: false,
    special: false,
    match: false,
  );

  // Getters herdados: isLoading, errorMessage, hasErrors, events
  PasswordRulesState get rules => _rules;
  bool get termsAccepted => _termsAccepted;

  void setTermsAccepted(bool value) {
    _termsAccepted = value;
    notifyListeners();
  }

  // ===== Bind de inputs =====
  void onPasswordChanged(String value) {
    _password = value;
    _recalcRules();
  }

  void onConfirmPasswordChanged(String value) {
    _confirmPassword = value;
    _recalcRules();
  }

  void _recalcRules() {
    final senha = _password;
    final confirmar = _confirmPassword;

    _rules = PasswordRulesState(
      min6: senha.length >= 6,
      upperLower:
          senha.contains(RegExp(r'[a-z]')) && senha.contains(RegExp(r'[A-Z]')),
      number: senha.contains(RegExp(r'[0-9]')),
      special: senha.contains(RegExp(r'[!@#\$&*~]')),
      match: senha.isNotEmpty && senha == confirmar,
    );

    notifyListeners();
  }

  // ===== Validações =====
  String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) return 'O nome é obrigatório.';
    return null;
  }

  String? validateCpf(String? cpf) {
    if (cpf == null || cpf.trim().isEmpty) return 'O CPF é obrigatório.';
    return null;
  }

  String? validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'O telefone é obrigatório.';
    }
    return null;
  }

  String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) return 'O e-mail é obrigatório.';
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

  // ✅ Ação principal (termos + register + feedback + navegação)
  Future<void> submit({
    required Tenant tenant,
    required bool formIsValid,
    required String email,
    required String password,
    required String name,
    required String cpf,
    required String phone,
  }) async {
    if (!_termsAccepted) {
      showSnackBar('Você deve aceitar os Termos de Uso.', isError: true);
      return;
    }

    if (!formIsValid) return;

    await executeWithLoading(() async {
      // ✅ Usar RegisterUseCase ao invés de AuthViewModel diretamente
      await _registerUseCase.execute(
        tenant: tenant,
        name: name,
        email: email,
        password: password,
        cpf: cpf,
        phone: phone,
      );

      showSnackBar(
        'Cadastro realizado com sucesso! Redirecionando para o login...',
        isError: false,
      );

      // ✅ Navegação via NavigationService (sem violar arquitetura)
      NavigationService.instance.navigateTo(AppRoutes.login, extra: tenant);
    }).catchError((e) {
      showSnackBar('Erro inesperado: ${e.toString()}', isError: true);
    });
  }

  // Implementações obrigatórias do BaseFormViewModel
  @override
  bool validateForm() {
    // Lógica de validação geral se necessário
    return !hasErrors;
  }

  @override
  Future<void> submitForm() async {
    // Não usado diretamente, pois submit é chamado da View com parâmetros
    // Mas pode ser usado para validação + submit se params forem armazenados
  }
}
