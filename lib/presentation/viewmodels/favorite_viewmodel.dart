import 'package:flutter/foundation.dart';
import 'package:integra_app/data/dao/favorite_dao.dart';
import 'package:integra_app/data/models/favorite_model.dart';
import 'package:integra_app/services/storage/domain_storage.dart';
import 'package:integra_app/services/service_service.dart';
import 'package:integra_app/data/models/category_model.dart' as models;

/// ViewModel responsável por controlar favoritos na aplicação.
/// - Não conhece Widgets
/// - Mantém estado observável para a View
/// - Interage com o DAO (camada de dados)
class FavoriteViewModel extends ChangeNotifier {
  final FavoriteDao _favoriteDao;
  final DomainStorage _domainStorage;
  final ServiceService _serviceService;

  /// Lista de favoritos carregada do banco local
  List<Favorite> _favorites = [];

  /// Cache de serviços completos para navegação
  final Map<int, models.Service> _servicesCache = {};

  /// Indica se está carregando dados
  bool _isLoading = false;

  /// ID do tenant atual
  String? _currentTenantId;

  // Getters públicos (imutáveis para a View)
  List<Favorite> get favorites => _favorites;
  bool get isLoading => _isLoading;
  Map<int, models.Service> get servicesCache => _servicesCache;

  /// Injeção de dependência (melhor para testes)
  FavoriteViewModel({FavoriteDao? dao, DomainStorage? domainStorage, ServiceService? serviceService}) 
      : _favoriteDao = dao ?? FavoriteDao(),
        _domainStorage = domainStorage ?? DomainStorage(),
        _serviceService = serviceService ?? ServiceService();

  /// Carrega todos os favoritos salvos no banco local para o tenant atual.
  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Carrega o tenant atual
      await _loadCurrentTenant();
      
      if (_currentTenantId != null) {
        _favorites = await _favoriteDao.getFavoritesByTenant(_currentTenantId!);
      } else {
        _favorites = [];
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar favoritos: $e');
      _favorites = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega o ID do tenant atual do storage
  Future<void> _loadCurrentTenant() async {
    try {
      final tenant = await _domainStorage.getSelectedTenant();
      _currentTenantId = tenant?.id;
    } catch (e) {
      debugPrint('❌ Erro ao carregar tenant atual: $e');
      _currentTenantId = null;
    }
  }

  /// Busca dados completos do serviço e armazena no cache
  Future<models.Service?> _fetchServiceData(int serviceId) async {
    // Verifica se já está no cache
    if (_servicesCache.containsKey(serviceId)) {
      return _servicesCache[serviceId];
    }

    try {
      final tenant = await _domainStorage.getSelectedTenant();
      if (tenant == null) {
        debugPrint('❌ Tenant não disponível para buscar dados do serviço');
        return null;
      }

      // TODO: Obter token do armazenamento
      final token = await _domainStorage.getAuthToken();
      if (token == null) {
        debugPrint('❌ Token não disponível para buscar dados do serviço');
        return null;
      }

      final service = await _serviceService.getServiceById(serviceId, tenant, token);
      if (service != null) {
        _servicesCache[serviceId] = service;
        debugPrint('✅ Dados do serviço ${service.title} carregados e cacheados');
      }
      
      return service;
    } catch (e) {
      debugPrint('❌ Erro ao buscar dados completos do serviço $serviceId: $e');
      return null;
    }
  }

  /// Verifica de forma SÍNCRONA se o serviço já está favoritado na lista em memória.
  /// A lista `_favorites` deve ser carregada previamente com `loadFavorites()`.
  bool isFavorite(String serviceName) {
    // 🔥 CORREÇÃO: Para categorias da API (começam com "category_"), busca por rota
    if (serviceName.startsWith('category_')) {
      final result = _favorites.any((fav) => fav.route == serviceName);
      debugPrint('🔍 [isFavorite] API: "$serviceName" -> $result (por rota, total: ${_favorites.length})');
      return result;
    }
    
    // Busca por nome (case insensitive)
    final searchName = serviceName.toLowerCase().trim();
    final result = _favorites.any((fav) => 
        fav.serviceName.toLowerCase().trim() == searchName);
    
    debugPrint('🔍 [isFavorite] "$serviceName" -> $result (por nome, total: ${_favorites.length})');
    return result;
  }

  /// Alterna entre favorito ↔ não favorito.
  Future<void> toggleFavorite(Favorite favorite) async {
    debugPrint('🔥 [toggleFavorite] Processando: "${favorite.serviceName}"');
    
    // Garante que temos o tenant atual
    await _loadCurrentTenant();
    if (_currentTenantId == null) {
      debugPrint('❌ Tenant não disponível para favoritar');
      return;
    }

    final isFav = isFavorite(favorite.serviceName);
    debugPrint('🔥 [toggleFavorite] Já é favorito? $isFav');

    // Cria o favorito com o tenant atual
    final favoriteWithTenant = Favorite(
      id: favorite.id,
      tenantId: _currentTenantId!,
      serviceName: favorite.serviceName,
      route: favorite.route,
      iconCodePoint: favorite.iconCodePoint,
      slug: favorite.slug,
      title: favorite.title,
      idService: favorite.idService,
    );

    if (isFav) {
      await _favoriteDao.deleteFavorite(favorite.serviceName, _currentTenantId!);
      debugPrint('🔥 [toggleFavorite] Removido do banco');
      
      // Remove do cache se tiver idService
      if (favorite.idService != null) {
        _servicesCache.remove(favorite.idService);
      }
    } else {
      await _favoriteDao.insertFavorite(favoriteWithTenant);
      debugPrint('🔥 [toggleFavorite] Adicionado ao banco: ${favoriteWithTenant.toMap()}');
      
      // Busca dados completos do serviço se tiver idService
      if (favorite.idService != null) {
        await _fetchServiceData(favorite.idService!);
      }
    }

    await loadFavorites(); // Atualiza lista e notifica View
    debugPrint('🔥 [toggleFavorite] Lista recarregada: ${_favorites.length} itens');
  }

  /// 🔥 Método opcional mais MVVM:
  /// A View não precisa montar o Favorite.
  Future<void> toggleFavoriteByData({
    required String serviceName,
    required String route,
    required int iconCodePoint,
    String? slug,
    String? title,
    int? idService,
  }) async {
    // Garante que temos o tenant atual
    await _loadCurrentTenant();
    if (_currentTenantId == null) {
      debugPrint('❌ Tenant não disponível para favoritar');
      return;
    }

    final favorite = Favorite(
      serviceName: serviceName,
      route: route,
      iconCodePoint: iconCodePoint.toString(),
      tenantId: _currentTenantId!,
      slug: slug,
      title: title,
      idService: idService,
    );

    await toggleFavorite(favorite);
  }

  /// Carrega dados completos de todos os favoritos que têm idService
  Future<void> loadFavoritesServicesData() async {
    debugPrint('🔄 Carregando dados completos dos serviços favoritados...');
    
    final favoritesWithIdService = _favorites.where((f) => f.idService != null).toList();
    
    for (final favorite in favoritesWithIdService) {
      await _fetchServiceData(favorite.idService!);
    }
    
    debugPrint('✅ Dados carregados para ${favoritesWithIdService.length} serviços');
    notifyListeners();
  }
}
