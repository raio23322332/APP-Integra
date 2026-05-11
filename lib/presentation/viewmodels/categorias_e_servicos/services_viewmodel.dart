import 'dart:async';
import 'package:flutter/foundation.dart' hide Category;
import 'package:integra_app/services/navigation_service.dart';
import 'package:integra_app/data/models/category_model.dart';
import 'package:integra_app/presentation/viewmodels/favorite_viewmodel.dart';
import 'package:integra_app/data/models/favorite_model.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';

class ServicesViewModel extends ChangeNotifier {
  final Category _category;
  final NavigationService _navigationService;
  final FavoriteViewModel _favoriteViewModel;

  ServicesViewModel(this._category, this._navigationService, this._favoriteViewModel) {
    // Carregar favoritos existentes ao inicializar
    _initializeFavorites();
  }

  // Inicializa os favoritos de forma assíncrona
  Future<void> _initializeFavorites() async {
    try {
      await _favoriteViewModel.loadFavorites();
      
      // Atualizar estado isFavorite dos serviços baseado nos favoritos carregados
      _updateServicesFavoriteStatus();
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erro ao carregar favoritos: $e');
    }
  }

  // Atualiza o status isFavorite de cada serviço baseado nos favoritos carregados
  void _updateServicesFavoriteStatus() {
    for (int i = 0; i < _category.services.length; i++) {
      final service = _category.services[i];
      final isFav = _favoriteViewModel.isFavorite(service.title);
      
      if (service.isFavorite != isFav) {
        _category.services[i] = Service(
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
          timesAccessed: service.timesAccessed,
          createdAt: service.createdAt,
          updatedAt: service.updatedAt,
          deletedAt: service.deletedAt,
          isExternal: service.isExternal,
          lat: service.lat,
          lng: service.lng,
          url: service.url,
          sections: service.sections,
          category: service.category,
          description: service.description,
          isFavorite: isFav, // Usa o status real do banco
        );
      }
    }
  }

  // ✅ PADRÃO: Eventos para comunicação com View
  final _eventController = StreamController<ViewModelEvent>.broadcast();
  Stream<ViewModelEvent> get events => _eventController.stream;

  void emitEvent(ViewModelEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  String get appBarTitle => _category.name;
  String get exp => 'Consulte os serviços relacionados a ${_category.name}';

  String get icon => _category.icon;

  Category get category => _category;

  bool get hasServices => _category.services.isNotEmpty;

  int get total => _category.services.length;

  List<Service> get services => _category.services;

  String get emptyTitle => 'Nenhum serviço encontrado.';
  String get emptySubtitle =>
      'Não há serviços disponíveis nesta categoria no momento.';

  // ✅ PADRÃO: Ação da UI delegada para ViewModel
  void onServiceSelected(Service service) {
    // ✅ PADRÃO: Navegação via NavigationService
    _navigationService.navigateToServiceDetails(service, _category);
  }

  // ✅ MELHOR ABORDAGEM: Lógica híbrida de favoritar/desfavoritar serviço
  Future<void> toggleFavorite(Service service) async {
    Service? updatedService;
    
    try {
      // 1. Atualizar estado local imediatamente (performance)
      final serviceIndex = _category.services.indexWhere((s) => s.id == service.id);
      if (serviceIndex != -1) {
        updatedService = Service(
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
          timesAccessed: service.timesAccessed,
          createdAt: service.createdAt,
          updatedAt: service.updatedAt,
          deletedAt: service.deletedAt,
          isExternal: service.isExternal,
          lat: service.lat,
          lng: service.lng,
          url: service.url,
          sections: service.sections,
          category: service.category,
          description: service.description,
          isFavorite: !service.isFavorite, // Inverte o estado
        );

        // Atualiza a lista local imediatamente
        _category.services[serviceIndex] = updatedService;
        notifyListeners();
      }

      // 2. Salvar no banco de forma assíncrona (persistência)
      final favorite = Favorite(
        serviceName: service.title,
        route: '/service-detail',
        iconCodePoint: _category.icon.toString(),
        slug: service.slug,
        title: service.title,
        tenantId: '', // Será preenchido no FavoriteViewModel
        idService: service.id, // Adiciona o ID do serviço
      );

      await _favoriteViewModel.toggleFavorite(favorite);
      
      // 3. Cache local para performance (opcional)
      await _saveFavoritesLocally();
      
      // 4. Feedback para usuário
      final message = updatedService?.isFavorite == true 
          ? 'Serviço favoritado com sucesso!' 
          : 'Serviço removido dos favoritos';
      emitEvent(ShowSnackBarEvent(message, isError: false));
      
      debugPrint('✅ Serviço ${service.title} atualizado nos favoritos');
    } catch (e) {
      debugPrint('❌ Erro ao favoritar serviço: $e');
      emitEvent(ShowSnackBarEvent('Erro ao favoritar serviço', isError: true));
    }
  }

  // ✅ NOVO: Salvar favoritos localmente
  Future<void> _saveFavoritesLocally() async {
    try {
      final favoriteServices = _category.services
          .where((service) => service.isFavorite)
          .map((service) => service.id)
          .toList();
      
      // Aqui você pode salvar no SharedPreferences, Hive, etc.
      // Por enquanto, apenas log
      debugPrint('💾 Favoritos salvos: $favoriteServices');
    } catch (e) {
      debugPrint('❌ Erro ao salvar favoritos: $e');
    }
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
