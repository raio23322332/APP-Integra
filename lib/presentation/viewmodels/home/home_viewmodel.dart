// lib/presentation/viewmodels/home/home_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:integra_app/data/models/category_model.dart' as models;
import 'package:integra_app/data/models/home_item_model.dart';
import 'package:integra_app/data/models/tenant_model.dart';
import 'package:integra_app/presentation/routes/app_router.dart';
import 'package:integra_app/presentation/viewmodels/auth/auth_viewmodel.dart';
import 'package:integra_app/presentation/viewmodels/search_viewmodel.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:integra_app/services/category_service.dart';
import 'package:integra_app/services/domain/domain_service.dart';
import 'package:integra_app/services/navigation_service.dart';
import 'package:integra_app/services/storage/domain_storage.dart';
import 'package:integra_app/core/utils/icon_mapper.dart';

class HomeViewModel extends ChangeNotifier {
  final DomainStorage domainStorage;
  final DomainService domainService;
  final CategoryService categoryService;
  final AuthViewModel authViewModel;
  final SearchViewModel searchViewModel;
  final NavigationService navigationService;

  final _eventController = StreamController<ViewModelEvent>.broadcast();
  Stream<ViewModelEvent> get events => _eventController.stream;

  bool _isDisposed = false;

  HomeViewModel({
    required this.domainStorage,
    required this.domainService,
    required this.categoryService,
    required this.authViewModel,
    required this.searchViewModel,
    required this.navigationService,
  });

  // Estado
  Tenant? _currentTenant;
  String? _authToken;
  bool _isLoadingCategories = false;
  String? _categoriesError;
  List<models.Category> _categories = [];
  bool _isOffline = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Getters
  Tenant? get currentTenant => _currentTenant;
  String? get authToken => _authToken;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get categoriesError => _categoriesError;
  List<models.Category> get categories => List.unmodifiable(_categories);
  bool get isOffline => _isOffline;

  // Serviços mais acessados de todas as categorias (sem API extra)
  List<models.Service> get mostAccessedServices {
    final allServices = <models.Service>[];
    
    // Coleta todos os serviços de todas as categorias
    for (final category in _categories) {
      allServices.addAll(category.services);
    }
    
    // Ordena por timesAccessed descendente e pega os top 5 (todos os serviços)
    allServices.sort((a, b) => b.timesAccessed.compareTo(a.timesAccessed));
    return allServices.take(5).toList();
  }

  // Serviços mais acessados que permitem solicitação (para os destaques)
  List<models.Service> get mostAccessedServicesWithRequest {
    final allServices = <models.Service>[];
    
    // Coleta todos os serviços de todas as categorias
    for (final category in _categories) {
      allServices.addAll(category.services);
    }
    
    // Filtra apenas serviços que permitem solicitação
    final servicesWithRequest = allServices.where((service) => service.canOpenRequest).toList();
    
    // Ordena por timesAccessed descendente e pega os top 5
    servicesWithRequest.sort((a, b) => b.timesAccessed.compareTo(a.timesAccessed));
    return servicesWithRequest.take(5).toList();
  }

  /// ✅ Encontra a categoria de um serviço e retorna seu ícone
  String? getServiceCategoryIcon(models.Service service) {
    debugPrint('🔍 [HomeVM] Procurando categoria para serviço: ${service.title} (ID: ${service.id})');
    debugPrint('🔍 [HomeVM] Total de categorias disponíveis: ${_categories.length}');
    
    for (final category in _categories) {
      debugPrint('🔍 [HomeVM] Verificando categoria: ${category.name} com ${category.services.length} serviços');
      if (category.services.any((s) => s.id == service.id)) {
        debugPrint('✅ [HomeVM] Encontrado! Serviço ${service.title} está na categoria ${category.name} com ícone: ${category.icon}');
        return category.icon;
      }
    }
    debugPrint('❌ [HomeVM] Categoria não encontrada para o serviço: ${service.title}');
    return null; // Retorna null se não encontrar a categoria
  }

  @override
  void dispose() {
    _isDisposed = true;
    _eventController.close();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  void emitEvent(ViewModelEvent event) {
    if (_isDisposed || _eventController.isClosed) return;
    _eventController.add(event);
  }

  /// Chamado quando a Home é aberta
  Future<void> init() async {
    searchViewModel.clearSearch(); // ✅ Limpa estado da busca ao inicializar home
    
    // Inicia monitoramento de conectividade
    _startConnectivityMonitoring();
    
    await _loadTenantAndToken();
    
    // Tenta carregar categorias (a lógica interna agora prioriza o local e silencia erros)
    await loadCategories();
    
    // ✅ Resetar campo de busca toda vez que home iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchViewModel.clearSearch();
    });
  }

  void _startConnectivityMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      final bool wasOffline = _isOffline;
      _isOffline = result == ConnectivityResult.none;
      
      if (wasOffline && !_isOffline) {
        debugPrint('[HomeViewModel] Conexão restaurada, atualizando categorias...');
        loadCategories();
      }
      
      notifyListeners();
    });
    
    // Checagem inicial
    Connectivity().checkConnectivity().then((result) {
      _isOffline = result == ConnectivityResult.none;
      notifyListeners();
    });
  }

  /// Chamado quando a Home recebe foco (volta de outras telas)
  void onFocusGained() {
    // searchViewModel.clearSearch(); // ✅ COMENTADO: Limpa busca ao voltar para home
  }

  Future<void> _loadTenantAndToken() async {
    // Tenta pegar o token do AuthViewModel
    _authToken = authViewModel.currentUser?.token;

    // Tenta pegar o tenant salvo no storage
    final selectedTenant = await domainStorage.getSelectedTenant();
    
    // Verificar se o tenant mudou para limpar categorias antigas
    if (selectedTenant != null && _currentTenant != null && 
        selectedTenant.id != _currentTenant!.id) {
      // Tenant mudou, limpar categorias antigas
      final oldDomain = _currentTenant?.primaryDomain ?? 
                       _currentTenant?.devDomain ?? 
                       _currentTenant?.urlSubdomainBase;
      if (oldDomain != null) {
        categoryService.clearCacheForTenant(oldDomain);
        debugPrint('[HomeViewModel] Cache limpo para tenant anterior: $oldDomain');
      }
      
      // Limpar categorias atuais para forçar recarregamento
      _categories = [];
    }
    
    if (selectedTenant != null) {
      _currentTenant = selectedTenant;
      debugPrint('[HomeViewModel] Tenant carregado do storage: ${_currentTenant?.id}');
    }

    // Se ainda não temos token ou tenant, não podemos prosseguir com a API, 
    // mas o loadCategories ainda tentará o banco local se tivermos ao menos o tenant.
    if (_currentTenant == null || _authToken == null) {
      debugPrint('[HomeViewModel] Aviso: Tenant ou Token ainda não disponíveis para API.');
      return;
    }

    // Tenta atualizar os dados do tenant via serviço se houver conexão
    if (!_isOffline) {
      try {
        final domainName = _currentTenant?.primaryDomain;
        if (domainName != null) {
          final tenants = await domainService.listTenants();
          _currentTenant = tenants.firstWhere(
            (tenant) => tenant.domains.any((d) => d.domain == domainName),
            orElse: () => _currentTenant!,
          );
        }
      } catch (e) {
        debugPrint('[HomeViewModel] Erro ao atualizar tenant da API (usando local): $e');
      }
    }
  }

  Future<void> loadCategories() async {
    // 1. Tenta carregar do banco local IMEDIATAMENTE se tivermos o tenant (mesmo sem token)
    if (_currentTenant != null && _categories.isEmpty) {
      final localData = await categoryService.getLocalCategories(_currentTenant!);
      if (localData.isNotEmpty) {
        _categories = localData;
        _categoriesError = null; // Limpa erro se temos dados locais
        notifyListeners();
        debugPrint('[HomeViewModel] Dados locais carregados preventivamente.');
      }
    }

    // Se não temos tenant ou token, não podemos chamar a API
    if (_currentTenant == null || _authToken == null) {
      // Silenciamos o erro se já temos dados locais ou se estamos apenas inicializando
      _categoriesError = null;
      notifyListeners();
      return;
    }

    // Se estamos offline e já temos dados (seja do banco ou memória), não fazemos mais nada
    if (_isOffline && _categories.isNotEmpty) {
      _categoriesError = null;
      notifyListeners();
      return;
    }

    // Só mostra loading se realmente não tivermos NADA para mostrar
    _isLoadingCategories = _categories.isEmpty;
    // NÃO limpamos o _categoriesError aqui para não causar "piscada" na UI se já tivermos dados
    notifyListeners();

    try {
      final result = await categoryService.getCategories(
        _currentTenant!,
        _authToken!,
      );
      
      if (result.isNotEmpty) {
        _categories = result;
        _categoriesError = null; // Sucesso na API, limpa erro
      }
    } catch (e) {
      debugPrint('[HomeViewModel] Erro ao carregar categorias da API: $e');
      
      // 2. Se a API falhar, tentamos o banco local de novo como última instância
      final fallbackData = await categoryService.getLocalCategories(_currentTenant!);
      if (fallbackData.isNotEmpty) {
        _categories = fallbackData;
        _categoriesError = null; // Temos dados locais, então NÃO é um erro para o usuário
      } else {
        // Só mostra erro se realmente não houver dados locais nem da API
        _categoriesError = 'Sem conexão e sem dados salvos.';
      }
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  void onSearchChanged(String query) {
    if (_currentTenant == null || _authToken == null) {
      debugPrint('[HomeViewModel] Busca ignorada: sem tenant ou token.');
      return;
    }

    searchViewModel.searchServices(query, _currentTenant!, _authToken!);
  }

  /// Lida com o toque em um item da lista de categorias dinâmicas.
  void onCategoryTapped(models.Category category) {
    emitEvent(CategoryTappedEvent(category));
  }

  /// Lida com o toque em um item do resultado da busca.
  void onSearchResultTapped(models.Service service) {
    final tempCategory = models.Category(
      id: DateTime.now().millisecondsSinceEpoch,
      name: service.title,
      icon:
          service.category?.icon ??
          'search', // Usa o ícone da categoria do serviço
      services: [service],
    );

    // Limpa a busca ao entrar no serviço
    clearSearchWhenTapped();

    emitEvent(CategoryTappedEvent(tempCategory));
  }

  /// ✅ Lida com o toque em um serviço mais acessado
  void onMostAccessedServiceTapped(models.Service service) {
    // Encontra a categoria do serviço ou cria uma temporária
    final category = _categories.firstWhere(
      (cat) => cat.services.any((s) => s.id == service.id),
      orElse: () => models.Category(
        id: service.category?.id ?? 0,
        name: service.category?.name ?? 'Serviço',
        icon: service.category?.icon ?? 'category',
      ),
    );
    
    navigationService.navigateToServiceDetails(service, category);
  }

  /// Limpa a busca quando clica em um serviço
  void clearSearchWhenTapped() {
    searchViewModel.clearSearch();
  }

  /// Método auxiliar para snackbars
  void showSnackBar(String message, {bool isError = false}) {
    emitEvent(ShowSnackBarEvent(message, isError: isError));
  }

  /// ✅ PADRÃO: Navegação direta via NavigationService
  void navigateToFavorites() {
    navigationService.navigateTo(AppRoutes.favorites);
  }

  void navigateToMeuIpva() {
    navigationService.navigateTo('/meu-ipva');
  }

  
  /// ✅ PADRÃO: Método para itens de destaque com mensagens específicas
  void onHighlightItemTapped({
    required String route,
    required String title,
    String? descricao,
    String? slug,
  }) {
    final message = _getHighlightMessage(title);
    if (message != null) {
      emitEvent(ShowSnackBarEvent(message));
      Future.delayed(const Duration(milliseconds: 1500), () {
        // Passa os dados via 'extra' - usa pushTo para empilhar
        navigationService.pushTo(
          route,
          extra: {'title': descricao, 'slug': slug},
        );
      });
    } else {
      // Para solicitações, usa pushTo para manter a pilha de navegação
      navigationService.pushTo(
        route,
        extra: {'title': descricao, 'slug': slug},
      );
    }
  }

  /// Método auxiliar para obter mensagens específicas dos destaques
  String? _getHighlightMessage(String title) {
    switch (title) {
      case "Reparo de Iluminação":
        return "Serviço para reportar falhas em postes de luz. Sua solicitação será analisada pela prefeitura.";
      case "Pavimentação":
        // return "Serviço para solicitar reparos em pavimentação e vias públicas.";
        return null; // Snack bar comentado para Pavimentação
      case "Poda de Árvore":
        return "Serviço para solicitar poda ou remoção de árvores em vias públicas.";
      default:
        return null;
    }
  }

  /// Método auxiliar para webview
  void openWebView(String title, String url) {
    navigationService.navigateTo(
      '/webview',
      extra: {'title': title, 'url': url},
    );
  }

  /// 🚀 NOVO: Navegação com transições fluidas (requer context)
  Future<void> navigateToServiceWithTransition(
    BuildContext context,
    models.Category category,
  ) async {
    // Volta para navegação normal - usar a tela existente de categorias
    navigationService.pushTo('/services', extra: category);
  }

  Future<void> navigateToWebViewWithTransition(
    BuildContext context,
    String title,
    String url,
  ) async {
    // Volta para navegação normal - usar a tela existente de webview
    navigationService.navigateTo(
      '/webview',
      extra: {'title': title, 'url': url},
    );
  }

  Future<void> navigateToHighlightWithTransition(
    BuildContext context,
    String route,
    String title,
  ) async {
    final message = _getHighlightMessage(title);
    if (message != null) {
      emitEvent(ShowSnackBarEvent(message));
      Future.delayed(const Duration(milliseconds: 1500), () {
        navigationService.navigateTo(route);
      });
    } else {
      navigationService.navigateTo(route);
    }
  }

  // ✅ MOVIDO do HomeUIAdapter - dados hardcoded agora no ViewModel
 /// Retorna itens de destaque dinâmicos baseados nos serviços mais acessados
  List<HomeItem> getHighlightItems() {
    const accentOrange = Color(0xFFD5692B);
    const highlightTeal = Color(0xFF248e95);

    final items = <HomeItem>[];
    
    // Item fixo para Últimas Entregas
    items.add(HomeItem(
      icon: FontAwesomeIcons.box,
      title: "Últimas Entregas",
      color: accentOrange,
    ));

    // Adiciona serviços mais acessados dinamicamente
    final services = mostAccessedServicesWithRequest.take(3).toList(); // Top 3 serviços
    
    for (final service in services) {
      final categoryIcon = getServiceCategoryIcon(service);
      final serviceIcon = mapCategoryIcon(categoryIcon ?? 'category');
      
      items.add(HomeItem(
        icon: serviceIcon,
        title: service.title,
        color: highlightTeal,
        route: AppRoutes.SolicitacaoView,
        canFavorite: false, // Serviços da API não podem ser favoritados
        onTap: () => onHighlightItemTapped(
          route: AppRoutes.SolicitacaoView,
          title: service.title,
          descricao: service.title,
          slug: service.slug, // Usa o slug dinâmico do serviço
        ),
      ));
    }

    return items;
  }

  }
