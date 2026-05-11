import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:integra_app/data/models/user_model.dart';
import 'package:integra_app/services/local/user_service.dart';
import 'package:integra_app/presentation/viewmodels/auth/auth_viewmodel.dart';

class UserViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final AuthViewModel _authViewModel; // Para obter o token

  List<User> _users = [];
  List<User> get users => _users;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserViewModel(this._authViewModel);

  // Helper para obter o token
  String? get _token => _authViewModel.currentUser?.token;

  // 1. READ: Listar usuários
  Future<void> fetchUsers() async {
    if (_token == null) {
      _errorMessage = 'Usuário não autenticado.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await _userService.getUsers(_token!);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. CREATE: Criar novo usuário
  Future<bool> createUser(Map<String, dynamic> userData) async {
    if (_token == null) {
      _errorMessage = 'Usuário não autenticado.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userService.createUser(_token!, userData);
      await fetchUsers(); // Atualiza a lista após a criação
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. UPDATE: Atualizar usuário
  Future<bool> updateUser(int userId, Map<String, dynamic> userData) async {
    if (_token == null) {
      _errorMessage = 'Usuário não autenticado.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userService.updateUser(_token!, userId, userData);
      await fetchUsers(); // Atualiza a lista após a atualização
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. DELETE: Deletar usuário
  Future<bool> deleteUser(int userId) async {
    if (_token == null) {
      _errorMessage = 'Usuário não autenticado.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userService.deleteUser(_token!, userId);
      _users.removeWhere((user) => user.id == userId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
