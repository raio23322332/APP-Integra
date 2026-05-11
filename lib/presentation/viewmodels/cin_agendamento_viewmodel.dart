import 'dart:async';
import 'package:flutter/material.dart';
import 'package:integra_app/presentation/viewmodels/base/base_viewmodel.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';

enum AgendamentoStep {
  dados,
  verificacao,
  posto,
  horario,
}

enum FormError {
  none,
  nomeVazio,
  nomeIncompleto,
  cpfVazio,
  cpfInvalido,
  emailVazio,
  emailInvalido,
  celularVazio,
  celularInvalido,
  motivoVazio,
  erroProcessamento,
}

extension FormErrorExtension on FormError {
  String get message {
    switch (this) {
      case FormError.nomeVazio:
        return 'Informe seu nome.';
      case FormError.nomeIncompleto:
        return 'Informe nome e sobrenome.';
      case FormError.cpfVazio:
        return 'Informe seu CPF.';
      case FormError.cpfInvalido:
        return 'CPF deve ter 11 dígitos.';
      case FormError.emailVazio:
        return 'Informe seu e-mail.';
      case FormError.emailInvalido:
        return 'E-mail inválido.';
      case FormError.celularVazio:
        return 'Informe seu celular.';
      case FormError.celularInvalido:
        return 'Celular inválido.';
      case FormError.motivoVazio:
        return 'Selecione o motivo.';
      case FormError.erroProcessamento:
        return 'Erro ao processar. Tente novamente.';
      default:
        return '';
    }
  }
}

class CinAgendamentoFormState {
  final String nome;
  final String cpf;
  final String email;
  final String celular;
  final String? motivo;
  final AgendamentoStep currentStep;
  final FormError error;

  const CinAgendamentoFormState({
    this.nome = '',
    this.cpf = '',
    this.email = '',
    this.celular = '',
    this.motivo,
    this.currentStep = AgendamentoStep.dados, // Valor padrão
    this.error = FormError.none,
  });

  CinAgendamentoFormState copyWith({
    String? nome,
    String? cpf,
    String? email,
    String? celular,
    String? motivo,
    AgendamentoStep? currentStep, // Pode ser nulo para manter valor atual
    FormError? error,
  }) {
    return CinAgendamentoFormState(
      nome: nome ?? this.nome,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      celular: celular ?? this.celular,
      motivo: motivo ?? this.motivo,
      currentStep: currentStep ?? this.currentStep, // Não pode ser nulo aqui
      error: error ?? this.error,
    );
  }
}

class CinAgendamentoViewModel extends BaseViewModel {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CinAgendamentoFormState _state = const CinAgendamentoFormState();
  CinAgendamentoFormState get state => _state;

  // Controladores
  final TextEditingController _nomeCtrl = TextEditingController();
  final TextEditingController _cpfCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _celCtrl = TextEditingController();

  TextEditingController get nomeCtrl => _nomeCtrl;
  TextEditingController get cpfCtrl => _cpfCtrl;
  TextEditingController get emailCtrl => _emailCtrl;
  TextEditingController get celCtrl => _celCtrl;

  // FormKey para validação encapsulada
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  final List<String> motives = const [
    'Primeira via',
    'Segunda via - Perda/Roubo',
    'Segunda via - Mudança de dados',
  ];

  CinAgendamentoViewModel() {
    _setupTextControllers();
  }

  void _setupTextControllers() {
    _nomeCtrl.text = _state.nome;
    _cpfCtrl.text = _state.cpf;
    _emailCtrl.text = _state.email;
    _celCtrl.text = _state.celular;

    _nomeCtrl.addListener(() => setNome(_nomeCtrl.text));
    _cpfCtrl.addListener(() => setCpf(_cpfCtrl.text));
    _emailCtrl.addListener(() => setEmail(_emailCtrl.text));
    _celCtrl.addListener(() => setCelular(_celCtrl.text));
  }

  // Setters
  void setNome(String value) {
    _state = _state.copyWith(nome: value, error: FormError.none);
    notifyListeners();
  }

  void setCpf(String value) {
    _state = _state.copyWith(cpf: value, error: FormError.none);
    notifyListeners();
  }

  void setEmail(String value) {
    _state = _state.copyWith(email: value, error: FormError.none);
    notifyListeners();
  }

  void setCelular(String value) {
    _state = _state.copyWith(celular: value, error: FormError.none);
    notifyListeners();
  }

  void setMotivo(String? value) {
    _state = _state.copyWith(motivo: value, error: FormError.none);
    notifyListeners();
  }

  void setCurrentStep(AgendamentoStep step) {
    _state = _state.copyWith(currentStep: step);
    notifyListeners();
  }

  // Validações encapsuladas
  String? _validateNome(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return FormError.nomeVazio.message;
    if (v.split(' ').length < 2) return FormError.nomeIncompleto.message;
    return null;
  }

  String? _validateCpf(String? value) {
    final v = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (v.isEmpty) return FormError.cpfVazio.message;
    if (v.length != 11) return FormError.cpfInvalido.message;
    return null;
  }

  String? _validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return FormError.emailVazio.message;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
    if (!ok) return FormError.emailInvalido.message;
    return null;
  }

  String? _validateCelular(String? value) {
    final v = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (v.isEmpty) return FormError.celularVazio.message;
    if (v.length < 10) return FormError.celularInvalido.message;
    return null;
  }

  String? _validateMotivo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return FormError.motivoVazio.message;
    }
    return null;
  }

  // Validações públicas para o FormField
  String? validateNome(String? value) => _validateNome(value);
  String? validateCpf(String? value) => _validateCpf(value);
  String? validateEmail(String? value) => _validateEmail(value);
  String? validateCelular(String? value) => _validateCelular(value);
  String? validateMotivo(String? value) => _validateMotivo(value);

  // Validação completa do formulário
  bool _validateForm() {
    final errors = [
      _validateNome(_state.nome),
      _validateCpf(_state.cpf),
      _validateEmail(_state.email),
      _validateCelular(_state.celular),
      _validateMotivo(_state.motivo),
    ];

    for (final error in errors) {
      if (error != null) {
        // Encontrar qual FormError corresponde à mensagem
        final errorCode = FormError.values.firstWhere(
          (e) => e.message == error,
          orElse: () => FormError.none,
        );
        _state = _state.copyWith(error: errorCode);
        notifyListeners();
        return false;
      }
    }

    _state = _state.copyWith(error: FormError.none);
    return true;
  }

  // Método principal de lógica de negócio
  Future<void> submitForm() async {
    // Validação via ViewModel
    if (!_validateForm()) {
      emitEvent(ShowSnackBarEvent(_state.error.message, isError: true));
      return;
    }

    _startLoading();

    try {
      await _processForm();
      _handleSuccess();
    } catch (e) {
      _handleError(e.toString());
    } finally {
      _stopLoading();
    }
  }

  Future<void> _processForm() async {
    await Future.delayed(const Duration(milliseconds: 250));
  }

  void _handleSuccess() {
    // Avança para próximo passo
    setCurrentStep(AgendamentoStep.verificacao);
    
    // Emite evento de navegação
    emitEvent(NavigationEvent('/cin-verificacao', extra: _state));
  }

  void _handleError(String error) {
    _state = _state.copyWith(error: FormError.erroProcessamento);
    notifyListeners();
    emitEvent(ShowSnackBarEvent(_state.error.message, isError: true));
  }

  void _startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _cpfCtrl.dispose();
    _emailCtrl.dispose();
    _celCtrl.dispose();
    super.dispose();
  }
}