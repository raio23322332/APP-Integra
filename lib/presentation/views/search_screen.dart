import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/core/utils/icon_mapper.dart';

import 'package:integra_app/data/models/category_model.dart' as models;
import 'package:integra_app/data/models/tenant_model.dart';
import 'package:integra_app/services/category_service.dart';
import 'package:integra_app/services/domain/domain_service.dart';

import 'package:integra_app/services/storage/domain_storage.dart';
import 'package:integra_app/presentation/viewmodels/auth/auth_viewmodel.dart';
import 'package:integra_app/presentation/viewmodels/search_viewmodel.dart';
import 'package:integra_app/presentation/viewmodels/home/home_viewmodel.dart';
import 'package:integra_app/presentation/widgets/common/app_loader.dart';
import 'package:integra_app/presentation/providers/recent_search_provider.dart';
import 'package:integra_app/presentation/widgets/shared/custom_snack_bar.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';
import 'package:provider/provider.dart';
import '../routes/app_router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late SearchViewModel _searchViewModel;
  late AuthViewModel _authViewModel;
  late RecentSearchProvider _recentSearchProvider;
  HomeViewModel? _homeViewModel;
  StreamSubscription? _eventSubscription;
  Tenant? _currentTenant;
  String? _authToken;
  List<models.Category> _allCategories = [];
  List<models.Category> _filteredCategories = [];
  bool _isLoadingCategories = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _searchViewModel = Provider.of<SearchViewModel>(context);
    _authViewModel = Provider.of<AuthViewModel>(context);
    _recentSearchProvider = Provider.of<RecentSearchProvider>(
      context,
      listen: false,
    );
    
    // ✅ Inicialização segura do HomeViewModel
    try {
      _homeViewModel = Provider.of<HomeViewModel>(context);
      _eventSubscription = _homeViewModel!.events.listen(_handleEvent);
    } catch (e) {
      _homeViewModel = null;
    }
    
    _loadTenantAndToken();
  }

  void _handleEvent(ViewModelEvent event) {
    if (!mounted) return;
    
    try {
      switch (event) {
        case ShowSnackBarEvent():
          if (event.isError) {
            CustomSnackBar.showError(context, event.message);
          } else {
            CustomSnackBar.showSuccess(context, event.message);
          }
          break;
        case CategoryTappedEvent():
          // ✅ Navegar para tela de serviços da categoria
          _homeViewModel!.navigationService.navigateTo('/services', extra: event.category);
          break;
        case NavigationEvent():
          if (event.extra != null) {
            context.push(event.route, extra: event.extra);
          } else {
            context.push(event.route);
          }
          break;
        default:
          break;
      }
    } catch (e) {
      debugPrint('[SearchScreen] Erro ao processar evento: $e');
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    // Filtrar categorias
    if (query.isEmpty) {
      _filteredCategories = _allCategories;
    } else {
      _filteredCategories = _allCategories.where((category) {
        return category.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    // Filtrar serviços
    if (_currentTenant != null && _authToken != null) {
      _searchViewModel.searchServices(query, _currentTenant!, _authToken!);
    } else if (query.isEmpty) {
      _searchViewModel.searchServices('', _currentTenant, _authToken);
    }

    setState(() {});
  }

  Future<void> _loadTenantAndToken() async {
    final domainStorage = Provider.of<DomainStorage>(context, listen: false);
    final domainService = Provider.of<DomainService>(context, listen: false);

    final domainName = await domainStorage.getSelectedDomain();
    _authToken = _authViewModel.currentUser?.token;

    if (domainName != null) {
      try {
        final tenants = await domainService.listTenants();
        _currentTenant = tenants.firstWhere(
          (tenant) =>
              tenant.domains.any((domain) => domain.domain == domainName),
          orElse: () => throw Exception(
            'Tenant não encontrado para o domínio: $domainName',
          ),
        );
        // Carregar categorias após obter o tenant
        await _loadCategories();
      } catch (e) {
        // Tratar erro de carregamento do Tenant
        _currentTenant = null;
      }
    } else {
      _currentTenant = null;
    }
  }

  Future<void> _loadCategories() async {
    if (_currentTenant == null || _authToken == null) {
      return;
    }

    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final categoryService = Provider.of<CategoryService>(
        context,
        listen: false,
      );
      _allCategories = await categoryService.getCategories(
        _currentTenant!,
        _authToken!,
      );
      _filteredCategories = _allCategories;
    } catch (e) {
      // Tratar erro de carregamento de categorias
      _allCategories = [];
      _filteredCategories = [];
    } finally {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    final trimmedQuery = query.trim();

    // Save to recent searches
    _recentSearchProvider.addRecentSearch(trimmedQuery);

    // Navigate to search results or perform search
    _searchController.text = trimmedQuery;
    _onSearchChanged();
  }

  void _clearSearch() {
    _searchController.clear();
    _searchViewModel.searchServices('', _currentTenant, _authToken);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go(AppRoutes.home);
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buscar Serviços'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.authText,
        automaticallyImplyLeading:false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 2.0, 16.0, 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(blurRadius: 3, color: Colors.black12),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      maxLength: 255,
                      decoration: const InputDecoration(
                        hintText: 'Buscar serviços',
                        border: InputBorder.none,
                        counterText: '',
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer2<SearchViewModel, RecentSearchProvider>(
              builder: (context, searchVM, recentProvider, child) {
                final query = _searchController.text.trim();
                final hasQuery = query.isNotEmpty;

                if (_isLoadingCategories || searchVM.isLoading) {
                  return const AppLoader();
                }

                // Show search results if there's a query
                if (hasQuery) {
                  return _buildSearchResults(searchVM);
                }

                // Show recent searches when no query
                return _buildDefaultView(recentProvider);
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDefaultView(RecentSearchProvider recentProvider) {
    // If there are recent searches, show them
    if (recentProvider.recentSearches.isNotEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text(
                  'Buscas Recentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF28669b),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    await recentProvider.clearRecentSearches();
                  },
                  child: const Text(
                    'Limpar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          ...recentProvider.recentSearches
              .take(5)
              .map(
                (search) => ListTile(
                  leading: const Icon(Icons.history, color: Colors.grey),
                  title: Text(search.query),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () =>
                        recentProvider.removeRecentSearch(search.query),
                  ),
                  onTap: () => _performSearch(search.query),
                ),
              ),
        ],
      );
    }

    // If no recent searches, show empty state
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Comece a buscar serviços',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Digite o nome do serviço que procura',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchViewModel searchVM) {
    final query = _searchController.text.trim();
    final hasCategories = _filteredCategories.isNotEmpty;
    final hasServices = searchVM.filteredServices.isNotEmpty;
    
    // Se não há resultados e o usuário digitou algo, mostra mensagem
    if (!hasCategories && !hasServices && query.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Icon(
                    Icons.search,
                    size: 32,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum serviço encontrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Não encontramos serviços correspondentes à sua busca. Tente usar termos diferentes ou verificar a grafia.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      children: [
        // Categories Section
        if (_filteredCategories.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 8),
            child: Text(
              'Categorias',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF28669b),
              ),
            ),
          ),
          ..._filteredCategories.map(
            (category) => _buildCategoryItem(
              context,
              mapCategoryIcon(category.icon),
              category.name,
              const Color(0xFF28669b),
              onTap: () {
                _recentSearchProvider.addRecentSearch(category.name);
                context.push('/services', extra: category);
              },
            ),
          ),
        ],

        // Services Section
        if (searchVM.filteredServices.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
            child: Text(
              'Serviços',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF28669b),
              ),
            ),
          ),
          ...searchVM.filteredServices.map(
            (service) {
              // ✅ Usa o mesmo padrão da home: se tiver categoria, usa ícone da categoria
              if (service.category != null) {
                return _buildServiceItem(
                  context,
                  mapCategoryIcon(service.category!.icon), // ✅ Mesmo padrão da home
                  service.title,
                  const Color(0xFF28669b),
                  onTap: () {
                    _recentSearchProvider.addRecentSearch(service.title);
                    context.push('/services', extra: service.category!);
                  },
                );
              } else {
                // ✅ Fallback: serviço sem categoria
                return _buildServiceItem(
                  context,
                  Icons.miscellaneous_services,
                  service.title,
                  const Color(0xFF28669b),
                  onTap: () {
                    debugPrint('🔍 [DEBUG] Clicou no serviço (sem categoria): ${service.title}');
                    
                    _recentSearchProvider.addRecentSearch(service.title);
                    final tempCategory = models.Category(
                      id: 0,
                      name: service.title,
                      icon: '',
                      services: [service],
                    );
                    context.push('/services', extra: tempCategory);
                  },
                );
              }
            },
          ),
        ],
      ],
    );
  }
  
  Widget _buildCategoryItem(
    BuildContext context,
    IconData icon,
    String text,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Ícone simples
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: color,
                size: 16,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Informações
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      color: Color(0xFF1F2D3D),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Categoria',
                    style: TextStyle(
                      color: const Color(0xFF263860).withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Indicador de navegação
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF263860).withValues(alpha: 0.5),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(
    BuildContext context,
    IconData icon,
    String text,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Ícone simples
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: color,
                size: 16,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Informações
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      color: Color(0xFF1F2D3D),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Serviço',
                    style: TextStyle(
                      color: const Color(0xFF263860).withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Indicador de navegação
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF263860).withValues(alpha: 0.5),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
