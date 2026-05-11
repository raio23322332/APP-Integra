// lib/presentation/viewmodels/profile/edit_profile_viewmodel.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../widgets/shared/view_model_event.dart';
import '../../../services/http/profile_http.dart';
import '../auth/auth_viewmodel.dart';

/// ViewModel para a tela de editar perfil
/// Gerencia estado e ações de edição de dados do usuário seguindo MVVM
class EditProfileViewModel extends ChangeNotifier {
  final ProfileHttp _profileHttp = ProfileHttp();
  final AuthViewModel _authViewModel;

  // Stream para eventos de feedback
  final _eventController = StreamController<ViewModelEvent>.broadcast();
  Stream<ViewModelEvent> get events => _eventController.stream;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  bool _disposed = false; // Flag para controlar disposed state
  bool _isNavigating = false; // Flag para evitar múltiplas navegações
  bool get mounted => !_disposed; // Propriedade para verificar se está ativo

  // Controllers para os campos
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _cpfController;

  // Armazena o último ID de usuário para detectar mudanças
  int? _lastUserId;

  // Getter público para acessar o último ID de usuário
  int? get lastUserId => _lastUserId;

  TextEditingController get nameController => _nameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get cpfController => _cpfController;

  EditProfileViewModel({required AuthViewModel authViewModel}) 
      : _authViewModel = authViewModel {
    _initializeControllers();
  }

  void _initializeControllers() {
    final user = _authViewModel.currentUser;
    _lastUserId = user?.id;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _cpfController = TextEditingController(text: user?.cpf ?? '');
  }

  /// Atualiza os controllers com os dados atuais do usuário
  /// Chamado quando o usuário é alterado (troca de conta)
  void updateControllersWithCurrentUser() {
    final user = _authViewModel.currentUser;
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
    _cpfController.text = user?.cpf ?? '';
    _lastUserId = user?.id;
    notifyListeners();
  }

  /// Verifica se o usuário mudou e atualiza os controllers se necessário
  void checkAndUpdateControllersIfNeeded() {
    if (_disposed) return;
    
    final currentUser = _authViewModel.currentUser;
    if (currentUser?.id != _lastUserId) {
      print('🔄 EditProfileViewModel: Usuário mudou de $_lastUserId para ${currentUser?.id}');
      _updateControllersWithoutNotification();
      _lastUserId = currentUser?.id;
    }
  }

  /// Atualiza os controllers sem chamar notifyListeners() para evitar erro de build
  void _updateControllersWithoutNotification() {
    final user = _authViewModel.currentUser;
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
    _cpfController.text = user?.cpf ?? '';
  }

  @override
  void dispose() {
    _disposed = true;
    _eventController.close();
    _nameController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ AÇÕES

  /// Atualiza os dados do perfil
  Future<void> updateProfile() async {
    if (_disposed || _isNavigating) return; // Evita múltiplas execuções
    
    try {
      _setLoading(true);
      _isNavigating = true; // Marca como navegando
      
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      
      print('🔄 EditProfileViewModel: Iniciando atualização');
      print('🔄 EditProfileViewModel: Name="$name", Email="$email"');
      
      final response = await _profileHttp.updateProfile(
        name: name,
        email: email,
      );

      if (_disposed) return; // Verifica após operação assíncrona

      print('🔄 EditProfileViewModel: Response Status: ${response.statusCode}');
      print('🔄 EditProfileViewModel: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        _emitEvent(ShowSnackBarEvent('Dados atualizados com sucesso!', isError: false));
        
        // Não chama loadCurrentUser() pois os dados já foram atualizados no ProfileHttp
        // Isso evita o redirecionamento indevido para a tela de tenant
        print('✅ EditProfileViewModel: Dados atualizados com sucesso, sem chamar loadCurrentUser()');
        
        // Força notificação para atualizar a UI que depende do AuthViewModel
        _authViewModel.notifyListeners();
        
        // Delay mínimo apenas para o SnackBar aparecer
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (_disposed) return; // Verificação final antes de navegar
        
        _emitEvent(NavigationEvent('/secondary-profile')); // Navega para a tela de perfil
      } else {
        print('❌ EditProfileViewModel: Erro na atualização - Status: ${response.statusCode}');
        _handleError(response);
      }
    } catch (e) {
      print('❌ EditProfileViewModel: Exceção na atualização: $e');
      if (!_disposed) {
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
          _emitEvent(ShowSnackBarEvent('Erro ao atualizar perfil: $e', isError: true));
        }
      }
    } finally {
      if (!_disposed) {
        _setLoading(false);
        _isNavigating = false; // Libera flag de navegação
      }
    }
  }

  /// Solicita a exclusão da conta
  Future<void> deleteAccount({required String password}) async {
    if (_disposed || _isNavigating) return; // Evita múltiplas execuções
    
    try {
      _setLoading(true);
      _isNavigating = true; // Marca como navegando
      
      final response = await _profileHttp.deleteAccount(password: password);
      
      if (_disposed) return; // Verifica após operação assíncrona
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        _emitEvent(ShowSnackBarEvent('Conta excluída com sucesso!', isError: false));
        
        // Faz logout após excluir conta
        await _authViewModel.logout();
        
        if (_disposed) return; // Verificação final
        
        _emitEvent(NavigateToLoginEvent());
      } else {
        _handleError(response);
      }
      
    } catch (e) {
      if (!_disposed) {
        _emitEvent(ShowSnackBarEvent('Erro ao excluir conta: $e', isError: true));
      }
    } finally {
      if (!_disposed) {
        _setLoading(false);
        _isNavigating = false; // Libera flag de navegação
      }
    }
  }

  // ------------------------------------------------------------ MÉTODOS PRIVADOS

  void _setLoading(bool loading) {
    if (_disposed) return;
    _isLoading = loading;
    notifyListeners();
  }

  void _handleError(http.Response response) {
    if (_disposed) return;
    
    print('❌ EditProfileViewModel: Tratando erro - Status: ${response.statusCode}');
    print('❌ EditProfileViewModel: Response Body: ${response.body}');
    
    try {
      if (response.body.isEmpty) {
        _emitEvent(ShowSnackBarEvent('Erro desconhecido do servidor (resposta vazia)', isError: true));
        return;
      }
      
      final responseData = json.decode(response.body);
      print('❌ EditProfileViewModel: Response Data: $responseData');
      
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
      
      // Se nenhuma mensagem específica foi encontrada, mostra o status code
      if (responseData['message'] == null && responseData['errors'] == null) {
        _emitEvent(ShowSnackBarEvent('Erro ao atualizar perfil (Status: ${response.statusCode})', isError: true));
      }
    } catch (e) {
      print('❌ EditProfileViewModel: Erro ao processar resposta: $e');
      _emitEvent(ShowSnackBarEvent('Erro ao processar resposta do servidor: ${response.statusCode}', isError: true));
    }
  }

  void _emitEvent(ViewModelEvent event) {
    if (_disposed || _eventController.isClosed) {
      return;
    }
    _eventController.add(event);
  }
}
