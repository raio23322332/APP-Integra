// lib/presentation/viewmodels/base/base_form_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// ViewModel base para formulários com validação e estado de loading
abstract class BaseFormViewModel extends ChangeNotifier {
  bool _isLoading = false;
  final Map<String, String?> _errors = {};

  /// Estado de loading do formulário
  bool get isLoading => _isLoading;

  /// Mapa de erros de validação por campo
  Map<String, String?> get errors => Map.unmodifiable(_errors);

  /// Verifica se há algum erro de validação
  bool get hasErrors => _errors.values.any((error) => error != null && error.isNotEmpty);

  /// Define o estado de loading
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Define erro para um campo específico
  void setFieldError(String field, String? error) {
    if (error == null || error.isEmpty) {
      _errors.remove(field);
    } else {
      _errors[field] = error;
    }
    notifyListeners();
  }

  /// Limpa todos os erros de validação
  void clearErrors() {
    _errors.clear();
    notifyListeners();
  }

  /// Limpa erro de um campo específico
  void clearFieldError(String field) {
    _errors.remove(field);
    notifyListeners();
  }

  /// Obtém erro de um campo específico
  String? getFieldError(String field) => _errors[field];

  /// Template method para validação completa do formulário
  bool validateForm();

  /// Template method para submissão do formulário
  Future<void> submitForm();

  /// Método helper para executar operações assíncronas com loading
  Future<T> executeWithLoading<T>(Future<T> Function() operation) async {
    print('⚙️ BaseFormViewModel.executeWithLoading: INÍCIO');
    debugPrint('🔍 BaseFormViewModel.executeWithLoading: INÍCIO');
    setLoading(true);
    try {
      print('⚙️ BaseFormViewModel: Executando operation...');
      final result = await operation();
      print('✅ BaseFormViewModel: Operation concluída com sucesso');
      return result;
    } catch (e) {
      // Captura exceção para não propagar e causar redirecionamento
      print('❌ BaseFormViewModel.executeWithLoading: Erro capturado - $e');
      debugPrint('BaseFormViewModel.executeWithLoading: Erro capturado - $e');
      rethrow; // Relança para tratamento específico no ViewModel
    } finally {
      setLoading(false);
    }
  }
}
