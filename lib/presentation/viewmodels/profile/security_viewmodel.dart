// lib/presentation/viewmodels/profile/security_viewmodel.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../widgets/shared/view_model_event.dart';
import '../../../services/http/profile_http.dart';

/// ViewModel para a tela de segurança e senha
/// Gerencia estado e ações de atualização de senha seguindo MVVM
class SecurityViewModel extends ChangeNotifier {
  final ProfileHttp _profileHttp = ProfileHttp();

  // Stream para eventos de feedback
  final _eventController = StreamController<ViewModelEvent>.broadcast();
  Stream<ViewModelEvent> get events => _eventController.stream;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }

  // ------------------------------------------------------------ AÇÕES

  /// Atualiza a senha do usuário
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    try {
      _setLoading(true);
      
      final response = await _profileHttp.updatePassword(
        currentPassword: currentPassword,
        password: newPassword,
        passwordConfirmation: passwordConfirmation,
      );

      if (response.statusCode == 200) {
        _emitEvent(ShowSnackBarEvent('Senha atualizada com sucesso!', isError: false));
        
        // Pequeno delay para mostrar o SnackBar antes de navegar
        await Future.delayed(const Duration(milliseconds: 1500));
        _emitEvent(NavigateBackEvent());
      } else {
        _handleError(response);
      }
    } catch (e) {
      // ✅ Verifica se é erro de conexão/internet
      if (e is http.ClientException || 
          e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('No address associated with hostname') ||
          e.toString().contains('Network is unreachable')) {
        
        // ✅ Emite evento para mostrar diálogo de sem internet
        _emitEvent(ShowNoInternetDialogEvent(
          message: 'Não foi possível conectar ao servidor. Verifique sua conexão com a internet e tente novamente.',
        ));
      } else {
        // ✅ Para outros erros, mostra SnackBar normal
        _emitEvent(ShowSnackBarEvent('Erro ao atualizar senha: $e', isError: true));
      }
    } finally {
      _setLoading(false);
    }
  }

  // ------------------------------------------------------------ MÉTODOS PRIVADOS

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleError(http.Response response) {
    try {
      if (response.body.isEmpty) {
        _emitEvent(ShowSnackBarEvent('Erro desconhecido do servidor', isError: true));
        return;
      }
      
      final responseData = json.decode(response.body);
      
      if (responseData['message'] != null) {
        _emitEvent(ShowSnackBarEvent(responseData['message'], isError: true));
      }
      
      if (responseData['errors'] != null) {
        final errors = responseData['errors'] as Map<String, dynamic>;
        final errorMessages = <String>[];
        
        errors.forEach((key, value) {
          if (value is List) {
            errorMessages.addAll(value.cast<String>());
          } else if (value is String) {
            errorMessages.add(value);
          }
        });
        
        if (errorMessages.isNotEmpty) {
          _emitEvent(ShowSnackBarEvent(errorMessages.first, isError: true));
        }
      }
    } catch (e) {
      _emitEvent(ShowSnackBarEvent('Erro ao processar resposta do servidor', isError: true));
    }
  }

  void _emitEvent(ViewModelEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }
}
