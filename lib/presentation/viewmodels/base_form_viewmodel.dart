import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';

/// ✅ Classe base poderosa para ViewModels de formulários
/// Elimina duplicação de código (loading, errors, validation)
abstract class BaseFormViewModel extends ChangeNotifier {
  final _eventController = StreamController<ViewModelEvent>.broadcast();
  Stream<ViewModelEvent> get events => _eventController.stream;

  bool _isLoading = false;
  final Map<String, String?> _errors = {};

  // Getters
  bool get isLoading => _isLoading;
  Map<String, String?> get errors => Map.unmodifiable(_errors);
  bool get hasErrors => _errors.values.any((error) => error != null);

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }

  // Métodos de gerenciamento de erros
  void setFieldError(String field, String? error) {
    if (error == null) {
      _errors.remove(field);
    } else {
      _errors[field] = error;
    }
    notifyListeners();
  }

  String? getFieldError(String field) => _errors[field];

  void clearErrors() => _errors.clear();

  // Template Methods (implementar nas subclasses)
  bool validateForm();
  Future<void> submitForm();

  // Helper para operações async com loading automático
  Future<T> executeWithLoading<T>(Future<T> Function() operation) async {
    _setLoading(true);
    try {
      return await operation();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void emitEvent(ViewModelEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  void showSnackBar(String message, {bool isError = false}) {
    emitEvent(ShowSnackBarEvent(message, isError: isError));
  }
}
