// lib/domain/usecases/home/load_categories_usecase.dart


import 'package:integra_app/core/contracts/category_service_contract.dart';
import 'package:integra_app/core/contracts/domain_service_contract.dart';
import 'package:integra_app/core/contracts/storage_service_contract.dart';
import 'package:integra_app/data/models/category_model.dart' as models;
import 'package:integra_app/data/models/tenant_model.dart';

/// UseCase para carregar categorias
/// Encapsula a lógica de negócio de carregamento de categorias
class LoadCategoriesUseCase {
  final CategoryServiceContract _categoryService;
  final DomainServiceContract _domainService;
  final StorageServiceContract _storage;

  LoadCategoriesUseCase({
    required CategoryServiceContract categoryService,
    required DomainServiceContract domainService,
    required StorageServiceContract storage,
  }) : _categoryService = categoryService,
       _domainService = domainService,
       _storage = storage;

  /// Executa o caso de uso de carregamento de categorias
  /// Retorna Either<HomeFailure, List<Category>>
  Future<LoadCategoriesResult> execute() async {
    try {
      final tenant = await _loadCurrentTenant();
      if (tenant == null) {
        return LoadCategoriesResult.failure('Nenhum tenant configurado');
      }

      final token = await _storage.getAuthToken();
      if (token == null || token.isEmpty) {
        return LoadCategoriesResult.failure('Usuário não autenticado');
      }

      final categories = await _categoryService.getCategories(tenant, token);
      return LoadCategoriesResult.success(categories);

    } catch (e) {
      return LoadCategoriesResult.failure('Erro ao carregar categorias: ${e.toString()}');
    }
  }

  /// Carrega o tenant atual do armazenamento
  Future<Tenant?> _loadCurrentTenant() async {
    try {
      final tenants = await _domainService.listTenants();
      // Lógica para determinar o tenant atual (pode ser do storage ou primeiro da lista)
      return tenants.isNotEmpty ? tenants.first : null;
    } catch (e) {
      return null;
    }
  }
}

/// Resultado da operação de carregamento de categorias
class LoadCategoriesResult {
  final bool isSuccess;
  final List<models.Category>? categories;
  final String? errorMessage;

  LoadCategoriesResult._({
    required this.isSuccess,
    this.categories,
    this.errorMessage,
  });

  /// Resultado de sucesso
  factory LoadCategoriesResult.success(List<models.Category> categories) {
    return LoadCategoriesResult._(
      isSuccess: true,
      categories: categories,
    );
  }

  /// Resultado de falha
  factory LoadCategoriesResult.failure(String message) {
    return LoadCategoriesResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}
