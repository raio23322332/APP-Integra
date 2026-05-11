import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // se não usar nada de Material, pode remover
import 'package:integra_app/data/models/category_model.dart';
import 'package:integra_app/data/models/tenant_model.dart';


import 'package:integra_app/services/search_service.dart';

class SearchViewModel extends ChangeNotifier {
  final SearchService _searchService;

  List<Service> _filteredServices = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isDisposed = false;

  List<Service> get filteredServices => _filteredServices;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  SearchViewModel(this._searchService);

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  Future<void> searchServices(
    String query,
    Tenant? tenant,
    String? token,
  ) async {
    if (_isDisposed) return;
    
    // Se limpou a busca, limpa a lista também
    if (query.isEmpty) {
      _filteredServices = [];
      _errorMessage = '';
      notifyListeners();
      return;
    }

    if (tenant == null || token == null) {
      _errorMessage =
          'Tenant ou token de autenticação não disponíveis para a busca.';
      _filteredServices = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Adicionar delay mínimo para melhor feedback visual
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (_isDisposed) return;
      
      _filteredServices = await _searchService.filterServices(
        query,
        tenant,
        token,
      );
    } catch (e) {
      _errorMessage = 'Erro ao buscar serviços: $e';
      _filteredServices = [];
      debugPrint('[SearchViewModel] Erro na busca: $e');
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void clearSearch() {
    if (_isDisposed) return;
    _filteredServices = [];
    _errorMessage = '';
    _isLoading = false;
    notifyListeners();
  }
}
