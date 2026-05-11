import '../data/models/category_model.dart';
import '../data/models/tenant_model.dart';
import '../core/contracts/search_service_contract.dart';
import '../core/contracts/category_service_contract.dart';
import '../core/contracts/domain_service_contract.dart';
import '../core/contracts/storage_service_contract.dart';

class SearchService implements SearchServiceContract {
  final CategoryServiceContract _categoryService;
  final DomainServiceContract _domainService;
  final StorageServiceContract _storage;

  // Cache para armazenar todos os serviços e evitar chamadas repetidas à API
  List<Service>? _allServicesCache;

  SearchService({
    required CategoryServiceContract categoryService,
    required DomainServiceContract domainService,
    required StorageServiceContract storage,
  }) : _categoryService = categoryService,
       _domainService = domainService,
       _storage = storage;

  /// Implementação do contrato SearchServiceContract
  @override
  Future<List<Service>> searchServices(String searchTerm, String token) async {
    return await filterServices(searchTerm, await _getCurrentTenant(), token);
  }

  /// Obtém uma lista plana de todos os serviços de todas as categorias.
  Future<List<Service>> getAllServices(Tenant tenant, String token) async {
    // ✅ Força limpar cache para garantir dados frescos
    _allServicesCache = null;
    
    final categories = await _categoryService.getCategories(tenant, token);

    // Mapeia as categorias para uma lista plana de serviços
    // ✅ Preenche o campo category de cada serviço com a referência à categoria pai
    final allServices = <Service>[];
    for (final category in categories) {
      for (final service in category.services) {
        // Cria uma cópia do serviço com a referência da categoria preenchida
        final serviceWithCategory = Service(
          id: service.id,
          title: service.title,
          slug: service.slug,
          type: service.type,
          address: service.address,
          cost: service.cost,
          duration: service.duration,
          users: service.users,
          responsible: service.responsible,
          unit: service.unit,
          lastUpdate: service.lastUpdate,
          timesAccessed: service.timesAccessed, // Adicionando campo obrigatório
          createdAt: service.createdAt,
          updatedAt: service.updatedAt,
          deletedAt: service.deletedAt,
          isExternal: service.isExternal,
          lat: service.lat,
          lng: service.lng,
          url: service.url,
          sections: service.sections,
          category: category, // ✅ Preenche com a categoria pai (com ícone da API)
        );
        allServices.add(serviceWithCategory);
      }
    }

    _allServicesCache = allServices;
    return allServices;
  }

  /// Filtra a lista de serviços por nome ou categoria.
  Future<List<Service>> filterServices(String query, Tenant tenant, String token) async {
    final allServices = await getAllServices(tenant, token);

    if (query.isEmpty) {
      // Se a busca estiver vazia, retorna uma lista vazia ou todos os serviços,
      // dependendo da UX desejada. Por enquanto, retorna vazio para não poluir a tela.
      return [];
    }

    final lowerCaseQuery = query.toLowerCase();

    // A filtragem é feita pelo título do serviço.
    // Se a API suportasse busca por categoria, a lógica seria diferente.
    return allServices.where((service) {
      return service.title.toLowerCase().contains(lowerCaseQuery);
    }).toList();
  }

  /// Obtém o tenant atual
  Future<Tenant> _getCurrentTenant() async {
    final tenants = await _domainService.listTenants();
    return tenants.isNotEmpty ? tenants.first : throw Exception('Nenhum tenant disponível');
  }
}
