import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:integra_app/data/models/category_model.dart' as models;
import 'package:integra_app/data/models/tenant_model.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';
import 'package:integra_app/services/category_service.dart';
import 'package:integra_app/services/navigation_service.dart';
import 'package:integra_app/services/connectivity_service.dart';

class CategoriesViewModel extends ChangeNotifier {
  final CategoryService _service;

  CategoriesViewModel({
    CategoryService? service,
    NavigationService? navigationService,
  })  : _service = service ?? CategoryService();

  // ✅ PADRÃO: Eventos para comunicação com View
  final _eventController = StreamController<ViewModelEvent>.broadcast();
  Stream<ViewModelEvent> get events => _eventController.stream;

  void emitEvent(ViewModelEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  // State
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String get errorMessage => _errorMessage ?? 'Erro desconhecido.';
  bool get hasError => _errorMessage != null;

  List<models.Category> _categories = [];
  List<models.Category> get categories => _categories;

  bool _initialized = false;
  Timer? _syncTimer;
  StreamSubscription? _connectivitySubscription;

  /// Chame uma vez (ex.: initState da View com addPostFrameCallback)
  Future<void> init({
    required Tenant tenant,
    required String token,
  }) async {
    if (_initialized) return;
    _initialized = true;
    
    // Inicia monitoramento de conectividade
    _startConnectivityMonitoring();
    
    // Carrega categorias iniciais
    await loadCategories(tenant: tenant, token: token);
    
    // Inicia sincronização automática a cada 2 minutos
    _startAutoSync(tenant, token);
  }

  void _startConnectivityMonitoring() {
    _connectivitySubscription = ConnectivityService.connectivityStream.listen((result) {
      if (result == ConnectivityResult.wifi || result == ConnectivityResult.mobile) {
        debugPrint('🌐 Conexão restaurada, sincronizando categorias...');
        // Força sincronização quando voltar a ter internet
        if (_currentTenant != null && _currentToken != null) {
          loadCategories(
            tenant: _currentTenant!,
            token: _currentToken!,
            forceRefresh: true,
          );
        }
      }
    });
  }

  void _startAutoSync(Tenant tenant, String token) {
    _currentTenant = tenant;
    _currentToken = token;
    
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      debugPrint('🔄 Sincronização automática de categorias...');
      debugPrint('🔄 Categories atuais: ${_categories.length}');
      loadCategories(
        tenant: tenant,
        token: token,
        forceRefresh: true,
      );
    });
  }

  Tenant? _currentTenant;
  String? _currentToken;

  Future<void> loadCategories({
    required Tenant tenant,
    required String token,
    bool forceRefresh = false,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Força limpar cache se solicitado
      if (forceRefresh) {
        _service.clearCache();
      }
      
      final result = await _service.getCategories(tenant, token);
      _categories = result;
      debugPrint('📥 Categories recebidas: ${result.length}');
      debugPrint('📥 Categories atualizadas no ViewModel');
    } catch (e) {
      _categories = [];
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void reset() {
    _initialized = false;
    _isLoading = false;
    _errorMessage = null;
    _categories = [];
    notifyListeners();
  }

  // ✅ PADRÃO: Ação da UI delegada para ViewModel
  void onCategorySelected(models.Category category) {
    // ✅ PADRÃO: Emite evento para navegação
    emitEvent(CategorySelectedEvent(category));
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    _eventController.close();
    super.dispose();
  }
}
