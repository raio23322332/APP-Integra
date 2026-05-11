// lib/domain/usecases/home/search_services_usecase.dart


import 'package:integra_app/core/contracts/search_service_contract.dart';
import 'package:integra_app/core/contracts/storage_service_contract.dart';
import 'package:integra_app/data/models/category_model.dart' as models;

/// UseCase para buscar serviços
/// Encapsula a lógica de negócio de busca de serviços
class SearchServicesUseCase {
  final SearchServiceContract _searchService;
  final StorageServiceContract _storage;

  SearchServicesUseCase({
    required SearchServiceContract searchService,
    required StorageServiceContract storage,
  }) : _searchService = searchService,
       _storage = storage;

  /// Executa a busca de serviços por termo
  Future<SearchServicesResult> execute(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      return SearchServicesResult.success([]);
    }

    try {
      final token = await _storage.getAuthToken();
      if (token == null || token.isEmpty) {
        return SearchServicesResult.failure('Usuário não autenticado');
      }

      final services = await _searchService.searchServices(searchTerm, token);
      return SearchServicesResult.success(services);

    } catch (e) {
      return SearchServicesResult.failure('Erro na busca: ${e.toString()}');
    }
  }
}

/// Resultado da operação de busca de serviços
class SearchServicesResult {
  final bool isSuccess;
  final List<models.Service>? services;
  final String? errorMessage;

  SearchServicesResult._({
    required this.isSuccess,
    this.services,
    this.errorMessage,
  });

  /// Resultado de sucesso
  factory SearchServicesResult.success(List<models.Service> services) {
    return SearchServicesResult._(
      isSuccess: true,
      services: services,
    );
  }

  /// Resultado de falha
  factory SearchServicesResult.failure(String message) {
    return SearchServicesResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}
