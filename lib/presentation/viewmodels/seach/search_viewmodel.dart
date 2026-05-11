// lib/presentation/viewmodels/search/search_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:integra_app/data/models/category_model.dart' as models;
import 'package:integra_app/data/models/tenant_model.dart';

class SearchState {
  final String query;
  final bool isLoading;
  final String errorMessage;
  final List<models.Service> filteredServices;

  const SearchState({
    this.query = '',
    this.isLoading = false,
    this.errorMessage = '',
    this.filteredServices = const [],
  });

  SearchState copyWith({
    String? query,
    bool? isLoading,
    String? errorMessage,
    List<models.Service>? filteredServices,
  }) {
    return SearchState(
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      filteredServices: filteredServices ?? this.filteredServices,
    );
  }
}

class SearchViewModel extends ChangeNotifier {
  final Future<List<models.Service>> Function(String, Tenant, String) _searchFunction;
  
  SearchState _state = const SearchState();
  SearchState get state => _state;

  SearchViewModel({
    required Future<List<models.Service>> Function(String, Tenant, String) searchFunction,
  }) : _searchFunction = searchFunction;

  void updateQuery(String query) {
    _state = _state.copyWith(query: query);
    notifyListeners();
  }

  Future<void> searchServices(String query, Tenant tenant, String authToken) async {
    if (query.isEmpty) {
      _state = _state.copyWith(
        filteredServices: [],
        errorMessage: '',
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(isLoading: true, errorMessage: '');
    notifyListeners();

    try {
      final results = await _searchFunction(query, tenant, authToken);
      
      _state = _state.copyWith(
        isLoading: false,
        filteredServices: results,
        errorMessage: '',
      );
      
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Erro na busca: $e',
        filteredServices: [],
      );
    }
    
    notifyListeners();
  }

  void clearResults() {
    _state = _state.copyWith(
      query: '',
      filteredServices: [],
      errorMessage: '',
    );
    notifyListeners();
  }

  void clearError() {
    _state = _state.copyWith(errorMessage: '');
    notifyListeners();
  }
}




